#!/bin/bash
set -e

TARGET_ARCH=$1
TARGET_PATH=/output/openh264/${TARGET_ARCH}

cp -r /sources/openh264 /tmp/openh264
cd /tmp/openh264

sed -i "s*PREFIX=/usr/local*PREFIX=${TARGET_PATH}*g" Makefile

declare -A arch_abis=(
	["arm"]="armeabi-v7a"
	["arm64"]="arm64-v8a"
	["x86"]="x86"
	["x86_64"]="x86_64"
)

declare -A ndk_levels=(
	["arm"]="16"
	["arm64"]="21"
	["x86"]="16"
	["x86_64"]="21"
)

for arch in arm arm64 x86 x86_64; do
	echo "*** BUILDING openh264 FOR $arch (${arch_abis[$arch]}) ***"
	if [ "$arch" == "x86" ]; then
		export ASMFLAGS=-DX86_32_PICASM
	else
		export ASMFLAGS=
	fi
	if [ "$arch" == "arm64" ]; then
		echo "********* LDFLAGS BEFORE: ${LDFLAGS} *********"
		export LDFLAGS="-L/usr/lib64"
		echo "********* LDFLAGS AFTER: ${LDFLAGS} *********"
	fi
	ARGS="OS=android NDKROOT=/sources/android_ndk TARGET=android-${ndk_levels[$arch]}"
	ARGS="${ARGS} NDKLEVEL=${ndk_levels[$arch]} ARCH=$arch NDK_TOOLCHAIN_VERSION=clang"
	/opt/gradle/latest/bin/gradle wrapper
	make ${ARGS} clean
	make ${ARGS} install
done

rm -rf /tmp/openh264
