#!/bin/sh

set -u
set -e
umask 0077

prefix="/opt/nano"
top="$(pwd)"
root="$top/root"
build="$top/build"

host=arm-linux-gnueabihf

export CFLAGS="-fPIC"
export CPPFLAGS="-I$root/include -I$root/include/ncurses -L."
export LDFLAGS="-L$root/lib"
export CC=$host-gcc
export AR=$host-ar
export RANLIB=$host-ranlib
export LD=$host-gcc

rm -rf "$root" "$build"
mkdir -p "$root" "$build"

cd "$build"
tar -xf ../dist/ncurses-*.tar.gz
tar -xf ../dist/nano-*.tar.gz

cd "$build"/ncurses-*
./configure --host=$host --prefix="$root" --disable-stripping --enable-termcap --with-caps --disable-database --with-fallbacks=vt100 --without-xterm-new
make -j4
make install

cd "$build"/nano-*
cp -p "$root"/lib/*.a .
./configure --host=$host --prefix="$prefix"
make -j4
make install-exec

cd "$top"
