#!/bin/bash
set -e

TARGET_ARCH=$1
TARGET_PATH=/output/openh264/${TARGET_ARCH}

cp -r /sources/openh264 /tmp/openh264
cd /tmp/openh264

sed -i "s*PREFIX=/usr/local*PREFIX=${TARGET_PATH}*g" Makefile

# Set architecture && NDK level based on Android target
if [ "$TARGET_ARCH" == "armeabi" ]; then
	ARCH="arm APP_ABI=armeabi"
	NDK_LEVEL="16"
elif [ "$TARGET_ARCH" == "armeabi-v7a" ]; then
	ARCH="arm"
	NDK_LEVEL="16"
elif [ "$TARGET_ARCH" == "x86" ]; then
	ARCH="x86"
	NDK_LEVEL="16"
elif [ "$TARGET_ARCH" == "x86_64" ]; then
	ARCH="x86_64"
	NDK_LEVEL="21"
elif [ "$TARGET_ARCH" == "arm64-v8a" ]; then
	ARCH="arm64"
	NDK_LEVEL="21"
elif [ "$TARGET_ARCH" == "mips" ]; then
	ARCH="mips"
	NDK_LEVEL="21"
elif [ "$TARGET_ARCH" == "mips64" ]; then
	ARCH="mips64"
	NDK_LEVEL="21"
else
	echo "Unsupported target ABI: $TARGET_ARCH"
	exit 1
fi

if [ "$ARCH" == "x86" ]; then
	export ASMFLAGS=-DX86_32_PICASM
else
	export ASMFLAGS=
fi
if [ "$ARCH" == "arm64" ]; then
	export LDFLAGS="-L/usr/lib64"
else
	export LDFLAGS=
fi

ARGS="OS=android ENABLEPIC=Yes NDKROOT=/sources/android_ndk NDKLEVEL=${NDK_LEVEL}"
ARGS="${ARGS} TARGET=android-${ANDROID_TARGET_API} ARCH=${ARCH} NDK_TOOLCHAIN_VERSION=clang"

echo "*** BUILDING openh264 FOR ${ARCH}. Args: ${ARGS} ***"

/opt/gradle/latest/bin/gradle wrapper
make ${ARGS} clean
make ${ARGS} install

rm -rf /tmp/openh264
