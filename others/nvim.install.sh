#!/bin/bash
set -e

VERSION="v0.10.4"
PREFIX="${PWD}/nvim-${VERSION}/build"
thread=15

URL="https://github.com/neovim/neovim/archive/refs/tags/${VERSION}.tar.gz"
wget $URL
tar -xvzf ${VERSION}.tar.gz
rm -rf ${VERSION}.tar.gz
cd neovim-${VERSION}
make -j $thread CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=${PREFIX}
make -j $thread install

echo done >&1
