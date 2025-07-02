#!/bin/bash
set -e

VERSION="3.31.6"
INSTALL_PREFIX="/data/group1/z42347t/apps/cmake/${VERSION}"
thread=12

URL="https://github.com/Kitware/CMake/releases/download/v${VERSION}/cmake-${VERSION}.tar.gz"
wget $URL
tar -zxvf cmake-${VERSION}.tar.gz
cd cmake-${VERSION}

./bootstrap --prefix=${INSTALL_PREFIX} --parallel=$thread

make -j $thread
make install -j $thread

echo done
