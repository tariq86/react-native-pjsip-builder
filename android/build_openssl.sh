#!/bin/bash
#@see http://stackoverflow.com/questions/11929773/compiling-the-latest-openssl-for-android
set -e

GCC_VERSION=$(gcc --version | grep gcc | awk '{print $4}' | cut -d'.' -f1,2)

TARGET_ARCH=$1
TARGET_PATH=/output/openssl/${TARGET_ARCH}

export ANDROID_NDK_ROOT=/sources/android_ndk
export ANDROID_API=26

cp -r /sources/openssl /tmp/openssl

if [ "$TARGET_ARCH" == "armeabi-v7a" ]; then
    TARGET=linux-generic32
elif [ "$TARGET_ARCH" == "arm64-v8a" ]; then
    TARGET=linux-generic64
elif [ "$TARGET_ARCH" == "armeabi" ]; then
    TARGET=android-armeabi
elif [ "$TARGET_ARCH" == "x86" ]; then
    TARGET=linux-generic32
elif [ "$TARGET_ARCH" == "x86_64" ]; then
    TARGET=linux-generic64
elif [ "$TARGET_ARCH" == "mips" ]; then
    TARGET=android-mips
elif [ "$TARGET_ARCH" == "mips64" ]; then
    TARGET=android-mips64
else
    echo "Unsupported target ABI: $TARGET_ARCH"
    exit 1
fi

export TOOLCHAIN_PATH="${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64/bin"
export PATH=$TOOLCHAIN_PATH:$PATH
export NDK_TOOLCHAIN_BASENAME=${TOOLCHAIN_PATH}/${TOOL}
# Set compiler clang, instead of gcc by default
export CC=clang

cd /tmp/openssl/

./Configure ${TARGET} \
    no-asm \
    no-unit-test \
    -D__ANDROID_API__=${ANDROID_API} \
    --openssldir=${TARGET_PATH}
make && make install
rm -rf /tmp/openssl/
