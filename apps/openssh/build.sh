#!/bin/sh

set -u
set -e
umask 0077

prefix="/opt/openssh"
top="$(pwd)"
root="$top/root"
build="$top/build"

host=arm-linux-gnueabihf

export CFLAGS="-fPIC"
export CPPFLAGS="-fPIC -I$root/include -L."
export CC=$host-gcc
export AR=$host-ar
export RANLIB=$host-ranlib
export LD=$host-gcc

rm -rf "$root" "$build"
mkdir -p "$root" "$build"

gzip -dc dist/zlib-*.tar.gz |(cd "$build" && tar xf -)
cd "$build"/zlib-*
./configure --prefix="$root" --static
make -j4
make install
cd "$top"

gzip -dc dist/openssl-*.tar.gz |(cd "$build" && tar xf -)
cd "$build"/openssl-*
./Configure linux-generic32 -DL_ENDIAN --prefix="$root" no-shared no-tests
make -j4
make install_sw
cd "$top"

gzip -dc dist/openssh-*.tar.gz |(cd "$build" && tar xf -)
cd "$build"/openssh-*
cp -p "$root"/lib/*.a .

./configure --prefix="$prefix" --host=$host --disable-strip --enable-static --with-libs --with-zlib="$root"/lib --with-ssl-dir="$root"/lib

make -j4
make install-files

cd "$top"
