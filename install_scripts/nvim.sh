#!/bin/bash
set -eux

VERSION="0.10.4"
PREFIX="${PWD}/neovim-${VERSION}/build"
thread=15

URL="https://github.com/neovim/neovim/archive/refs/tags/v${VERSION}.tar.gz"
wget $URL
tar -xvzf v${VERSION}.tar.gz
rm -rf v${VERSION}.tar.gz
cd neovim-${VERSION}
make -j $thread CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=${PREFIX}
make -j $thread install

echo done >&1
