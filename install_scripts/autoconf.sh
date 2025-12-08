#!/bin/bash
set -e

VERSION=2.71
URL=http://ftp.gnu.org/gnu/autoconf/autoconf-${VERSION}.tar.gz
PREFIX=$PWD/autoconf-${VERSION}/build
BIN=$HOME/works/bin

wget $URL

tar xvfz autoconf-${VERSION}.tar.gz

rm -rf autoconf-${VERSION}.tar.gz

cd autoconf-${VERSION}

./configure --prefix=$PREFIX

make -j 8

make install

ln -s $PREFIX/bin/* $BIN/

echo done
