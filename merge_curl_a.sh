#!/bin/bash
# Compile curl & openssl & zlib for android with NDK.
# Copyright (C) 2018  shishuo <shishuo365@126.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

APP_ABI=(armeabi-v7a arm64-v8a)

BASE_PATH=$(
	cd "$(dirname $0)"
	pwd
)
BUILD_PATH="$BASE_PATH/jni/build"

checkExitCode() {
	if [ $1 -ne 0 ]; then
		echo "Error building curl library"
		cd $BASE_PATH
		exit $1
	fi
}
safeMakeDir() {
	if [ ! -x "$1" ]; then
		mkdir -p "$1"
	fi
}

## Android NDK
export NDK_ROOT="$NDK_ROOT"

if [ -z "$NDK_ROOT" ]; then
	echo "Please set your NDK_ROOT environment variable first"
	exit 1
fi	

# Clean build directory
rm -rf $BASE_PATH/libs
safeMakeDir $BASE_PATH/libs


merge() {
	ABI=$1
	TOOLCHAIN=$2
	export AR=$TOOLCHAIN/llvm-ar

	# extract *.o from libcurl.a
	safeMakeDir $BASE_PATH/obj/$ABI/curl
	cd $BASE_PATH/obj/$ABI/curl
	$AR -x $BUILD_PATH/curl/$ABI/lib/libcurl.a
	checkExitCode $?
	# extract *.o from libssl.a & libcrypto.a
	safeMakeDir $BASE_PATH/obj/$ABI/openssl
	cd $BASE_PATH/obj/$ABI/openssl
	$AR -x $BUILD_PATH/openssl/$ABI/lib/libssl.a
	$AR -x $BUILD_PATH/openssl/$ABI/lib/libcrypto.a
	checkExitCode $?
	# extract *.o from libz.a
	safeMakeDir $BASE_PATH/obj/$ABI/zlib
	cd $BASE_PATH/obj/$ABI/zlib
	$AR -x $BUILD_PATH/zlib/$ABI/lib/libz.a
	checkExitCode $?
	# combine *.o to libcurl.a
	safeMakeDir $BASE_PATH/libs/$ABI
	cd $BASE_PATH
	$AR -cr $BASE_PATH/libs/$ABI/libcurl.a $BASE_PATH/obj/$ABI/curl/*.o $BASE_PATH/obj/$ABI/openssl/*.o $BASE_PATH/obj/$ABI/zlib/*.o
	checkExitCode $?
}

# check system
host=$(uname | tr 'A-Z' 'a-z')
if [ $host = "darwin" ] || [ $host = "linux" ]; then
	echo "system: $host"
else
	echo "unsupport system, only support Mac OS X and Linux now."
	exit 1
fi

for abi in ${APP_ABI[*]}; do
	merge $abi "$NDK_ROOT/toolchains/llvm/prebuilt/$host-x86_64/bin"
done

echo "=== merge success ==="
echo "path: $BASE_PATH/libs"
rm -rf $BASE_PATH/obj

cd $BASE_PATH
exit 0
