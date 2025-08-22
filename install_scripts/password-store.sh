#!/bin/bash
set -e

VERSION="1.7.4"
URL="https://git.zx2c4.com/password-store/snapshot/password-store-${VERSION}.tar.xz"
PREFIX="${PWD}/password-store-${VERSION}"

wget $URL
tar Jxfv password-store-${VERSION}.tar.xz
cd password-store-${VERSION}

sed -i -e "s#PREFIX ?= /usr#PREFIX ?= ${PREFIX}#g" Makefile

make install

echo done
