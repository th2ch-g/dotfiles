#!/bin/bash
set -eux

VERSION="3.31.6"
INSTALL_PREFIX="${PWD}/cmake-${VERSION}/build"
thread=4

URL="https://github.com/Kitware/CMake/releases/download/v${VERSION}/cmake-${VERSION}.tar.gz"
wget $URL
tar -zxvf cmake-${VERSION}.tar.gz
cd cmake-${VERSION}

./bootstrap --prefix=${INSTALL_PREFIX} --parallel=$thread

make -j $thread
make install -j $thread

echo done
