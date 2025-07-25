#!/bin/bash
set -eux

thread=15
VERSION="5.9"
PREFIX="${PWD}/zsh-${VERSION}/build"

URL=https://github.com/zsh-users/zsh/archive/refs/tags/zsh-${VERSION}.tar.gz
curl -L $URL -o zsh.tar.gz && \
    tar -zxvf zsh.tar.gz && \
    rm -f zsh.tar.gz

cd zsh-${VERSION} && \
    ./Util/preconfig && \
    ./configure --prefix=${PREFIX} \
    --enable-multibyte --enable-locale && \
    make -j $thread && make install && \
    cd ..

echo "[INFO] zsh install done" >&1
