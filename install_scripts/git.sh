#!/bin/bash
set -eux

VERSION="v2.40.0-rc1"
thread=15
PREFIX="${PWD}/git-${VERSION}/build"
BIN=$HOME/works/bin

URL="https://github.com/git/git/archive/refs/tags/${VERSION}.tar.gz"
curl -L $URL -o git-${VERSION}.tar.gz && \
    tar -zxvf git-${VERSION}.tar.gz && \
    rm -rf git-${VERSION}.tar.gz

cd git-${VERSION} && \
    make configure && \
    ./configure --prefix=${PREFIX} && \
    make all -j $thread && cd ..

ln -s ${PREFIX}/bin/git $BIN

echo "[INFO] git install done" >&1

