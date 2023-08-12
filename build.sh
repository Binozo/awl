#!/bin/bash

export TOOLCHAIN=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64
export TARGET=armv7a-linux-androideabi
#export TARGET=aarch64-linux-android
export API=24 # Do not compile below that
export AR=$TOOLCHAIN/bin/llvm-ar
export CC=$TOOLCHAIN/bin/$TARGET$API-clang
export AS=$CC
export CXX=$TOOLCHAIN/bin/$TARGET$API-clang++
export LD=$TOOLCHAIN/bin/ld
export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
export STRIP=$TOOLCHAIN/bin/llvm-strip

echo "Compiling using"
echo $($CC -v)

# Some stupid hacky stuff but it works
rm -rf /usr/include/bits
rm /usr/include/asm-generic/errno.h
cp -a /usr/include/. $TOOLCHAIN/sysroot/usr/include/

# arm64 (aarch64-linux-gnu)
cp -a /usr/include/aarch64-linux-gnu/bits/. $TOOLCHAIN/sysroot/usr/include/bits/
cp src/errno.h $TOOLCHAIN/sysroot/usr/include/aarch64-linux-android/asm/errno.

# armeabi-v7a (arm-linux-gnueabihf)
cp -a /usr/include/arm-linux-gnueabihf/bits/. $TOOLCHAIN/sysroot/usr/include/bits/
cp src/errno.h $TOOLCHAIN/sysroot/usr/include/arm-linux-gnueabihf/asm/errno.

cp src/assert.h $TOOLCHAIN/sysroot/usr/include/assert.h

rm -rf build
mkdir build
cd build
mkdir /output

echo "Building..."
cmake ..
make

echo "Building done"
cp /awl/build/daemon/owl /output/owl