#!/bin/bash

set -e

thread=15
zsh_link=https://github.com/zsh-users/zsh/archive/refs/tags/zsh-5.9.tar.gz
install_path=$PWD

curl -L $zsh_link -o zsh.tar.gz && \
    tar -zxvf zsh.tar.gz && \
    rm -f zsh.tar.gz

cd zsh* && \
    ./Util/preconfig && \
    ./configure --prefix=${install_path}/zsh \
    --enable-multibyte --enable-locale && \
    make -j $thread && make install && \
    cd ..

echo "[INFO] zsh install done" >&1
