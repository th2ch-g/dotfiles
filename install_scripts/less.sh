#!/bin/bash
set -eux

thread=15
VERSION="668"
PREFIX="${PWD}/less-${VERSION}/build"
BIN=${BIN:-$HOME/works/bin}

URL=https://greenwoodsoftware.com/less/less-${VERSION}.tar.gz
curl -L $URL -o less.tar.gz && \
    tar -zxvf less.tar.gz && \
    rm -f less.tar.gz

cd less-${VERSION} && \
    ./configure --prefix=${PREFIX} && \
    make -j $thread && make install && \
    cd ..

ln -s ${PREFIX}/bin/less $BIN

echo "[INFO] less install done" >&1
