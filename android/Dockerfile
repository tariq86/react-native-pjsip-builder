FROM ubuntu:latest

##############################
# Download dependencies
##############################

RUN dpkg --add-architecture i386 && \
    apt-get -y upgrade && \
    apt-get -y dist-upgrade && \
    apt-get update

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install \
    software-properties-common git curl bzip2 gcc g++ binutils make autoconf openssl \
    libssl-dev ant libopus0 libpcre3 libpcre3-dev build-essential nasm libc6:i386 libstdc++6:i386 zlib1g:i386 \
    openjdk-8-jdk unzip bison

##############################
# Configuration
##############################

# ENV TARGET_ARCHS "armeabi armeabi-v7a x86 mips arm64-v8a x86_64 mips64"
ENV TARGET_ARCHS "armeabi-v7a x86 arm64-v8a x86_64"
ENV ANDROID_NDK_DOWNLOAD_URL "https://dl.google.com/android/repository/android-ndk-r21d-linux-x86_64.zip"
ENV ANDROID_SDK_DOWNLOAD_URL "https://dl.google.com/android/repository/tools_r25.2.5-linux.zip"
ENV ANDROID_SETUP_APIS "26"
ENV ANDROID_TARGET_API 26

ENV PJSIP_DOWNLOAD_URL "https://github.com/pjsip/pjproject/archive/2.10.tar.gz"

ENV SWIG_DOWNLOAD_URL "https://github.com/swig/swig/archive/v4.0.2.tar.gz"

ENV OPENSSL_DOWNLOAD_URL "https://github.com/openssl/openssl/archive/OpenSSL_1_1_1g.tar.gz"

ENV OPENH264_DOWNLOAD_URL "https://github.com/cisco/openh264/tarball/openh264v2.1.0"

ENV OPUS_DOWNLOAD_URL "http://downloads.xiph.org/releases/opus/opus-1.3.1.tar.gz"
ENV OPUS_ANDROID_MK_DOWNLOAD_URL "https://trac.pjsip.org/repos/raw-attachment/ticket/1904/Android.mk"

ENV PATH /sources/android_ndk:$PATH

##############################
# Download sources
##############################

RUN mkdir -p /sources/android_ndk && \
    mkdir -p /sources/android_sdk && \
    mkdir -p /sources/pjsip && \
    mkdir -p /sources/swig && \
    mkdir -p /sources/openssl && \
    mkdir -p /sources/opus && \
    mkdir -p /sources/openh264

# Download Android NDK
RUN cd /sources/android_ndk && \
    curl -L -# -o ndk.zip "$ANDROID_NDK_DOWNLOAD_URL" && \
    unzip ndk.zip && \
    rm -rf ndk.zip && \
    mv android-*/* ./

# Download Android SDK & APIs
RUN cd /sources/android_sdk && \
    curl -L -# -o sdk.zip "$ANDROID_SDK_DOWNLOAD_URL" && \
    unzip sdk.zip

# Install Android SDK(s)
RUN cd /sources/android_sdk/tools && \
    ALL_SDK=$(./android list sdk --all) && \
    IFS=" " && \
    for api in $ANDROID_SETUP_APIS; \
    do \
    PACKAGE=$(echo "${ALL_SDK}" | grep "API ${api}" | head -n 1 | awk '{print $1}' | cut -d'-' -f 1); \
    echo yes | ./android update sdk --all --filter ${PACKAGE} --no-ui --force; \
    done && \
    PACKAGE=$(echo "${ALL_SDK}" | grep "Android SDK Platform-tools" | head -n 1 | awk '{print $1}' | cut -d'-' -f 1) && \
    echo yes | ./android update sdk --all --filter ${PACKAGE} --no-ui --force && \
    PACKAGE=$(echo "${ALL_SDK}" | grep "Build-tools" | grep "${BUILD_TOOLS_VERSION}" | head -n 1 | awk '{print $1}' | cut -d'-' -f 1) && \
    echo yes | ./android update sdk --all --filter ${PACKAGE} --no-ui --force

# Copy Android SDK licenses file over
RUN mkdir -p /sources/android_sdk/licenses
ADD ./android-sdk-licenses /sources/android_sdk/licenses/

# Download Pjsip
RUN cd /sources/pjsip && \
    curl -L -# -o pjsip.tar.gz "$PJSIP_DOWNLOAD_URL" && \
    tar xzf pjsip.tar.gz && \
    rm -rf pjsip.tar.gz && \
    mv pjproject-*/* ./

# Download Swig
RUN cd /sources/swig && \
    curl -L -# -o swig.tar.gz "$SWIG_DOWNLOAD_URL" && \
    tar xzf swig.tar.gz && \
    rm -rf swig.tar.gz && \
    mv swig-*/* ./

# Download OpenSSL
RUN cd /sources/openssl && \
    curl -L -# -o openssl.tar.gz "$OPENSSL_DOWNLOAD_URL" && \
    tar xzf openssl.tar.gz && \
    rm -rf openssl.tar.gz && \
    mv openssl-*/* ./

# Download Opus
RUN cd /sources/opus && \
    curl -L -# -o opus.tar.gz "$OPUS_DOWNLOAD_URL" && \
    tar xzf opus.tar.gz && \
    rm -rf opus.tar.gz && \
    mv opus-*/* ./ && \
    mkdir ./jni && \
    cd ./jni && \
    curl -L -# -o Android.mk "$OPUS_ANDROID_MK_DOWNLOAD_URL"

# Download OpenH264
RUN cd /sources/openh264 && \
    curl -L -# -o openh264.tar.gz "$OPENH264_DOWNLOAD_URL" && \
    tar xzf openh264.tar.gz && \
    rm -rf openh264.tar.gz && \
    mv cisco-*/* ./

#  Make tmp. directories
RUN mkdir -p /output/openssl/ && \
    mkdir -p /output/openh264/ && \
    mkdir -p /output/pjsip && \
    mkdir -p /output/opus && \
    mkdir -p /output/swig

##############################
# Build Opus, Swig, OpenH264, then OpenSSL
##############################

# Build Opus
ADD ./build_opus.sh /usr/local/sbin/
RUN IFS=" " && \
    for arch in $TARGET_ARCHS; \
    do \
    build_opus.sh ${arch}; \
    done

# Build Swig
RUN cd /sources/swig && \
    ./autogen.sh && \
    ./configure --prefix=/output/swig && \
    make && \
    make install

# Get Gradle 6.1.1
ADD ./get_gradle.sh /usr/local/sbin/
RUN get_gradle.sh

# Build OpenH264
ADD ./build_openh264.sh /usr/local/sbin/
RUN IFS=" " && \
    for arch in $TARGET_ARCHS; \
    do \
    build_openh264.sh ${arch}; \
    done

# Build OpenSSL
ADD ./build_openssl.sh /usr/local/sbin/
RUN IFS=" " && \
    for arch in $TARGET_ARCHS; \
    do \
    build_openssl.sh ${arch}; \
    done

# Step #32: Build pjsip
ADD ./build_pjsip.sh /usr/local/sbin/
RUN IFS=" " && \
    for arch in $TARGET_ARCHS; \
    do \
    build_pjsip.sh ${arch}; \
    done

# Dist
RUN mkdir -p /dist/android/src/main && \
    mv /output/pjsip/* /dist/android/src/main && \
    rm -rf /dist/android/src/main/java/org/pjsip/pjsua2/app

RUN IFS=" " && \
    for arch in $TARGET_ARCHS; \
    do \
    mv /output/openh264/${arch}/lib/libopenh264.so /dist/android/src/main/jniLibs/${arch}/; \
    done
