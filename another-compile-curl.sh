#!/bin/bash

export ANDROID_NDK_ROOT=~/android-ndk-r23c

HOST_TAG=linux-x86_64

MIN_SDK_VERSION=23

TOOLCHAIN=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/$HOST_TAG

PATH=$TOOLCHAIN/bin:$PATH

BUILD_DIR=$PWD/jni/build




#source ./build-android-env.sh

ARCHIVE=curl-7.88.1.tar.xz

DIR=curl-7.88.1

INSTALL_DIR=$BUILD_DIR/curl2

if [ -d $INSTALL_DIR ]; then
    rm -rf $INSTALL_DIR
fi

mkdir -p $INSTALL_DIR

if [ -d $DIR ];then
    rm -rf $DIR
fi

tar xf $ARCHIVE

cd $DIR

function build() {
    export TARGET_HOST=$1
    export ANDROID_ARCH=$2
    export AR=$TOOLCHAIN/bin/llvm-ar
    export CC=$TOOLCHAIN/bin/$TARGET_HOST$MIN_SDK_VERSION-clang
    export AS=$CC
    export CXX=$TOOLCHAIN/bin/$TARGET_HOST$MIN_SDK_VERSION-clang++
    export LD=$TOOLCHAIN/bin/ld
    export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
    export STRIP=$TOOLCHAIN/bin/llvm-strip

    ./configure --host=$TARGET_HOST \
                --target=$TARGET_HOST \
                --prefix=$INSTALL_DIR/$ANDROID_ARCH \
                --with-zlib=$BUILD_DIR/zlib/$ANDROID_ARCH \
                --with-openssl=/home/seraphn/build-curl-openssl-zlib-android-ios/build/android/openssl/$ANDROID_ARCH \
                --with-pic --disable-shared

    make -j8a
    make install
    make clean
}


#build aarch64-linux-android arm64-v8a
build armv7a-linux-androideabi armeabi-v7a

cd ..

rm -rf cd $DIR
