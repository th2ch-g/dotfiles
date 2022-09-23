#!/bin/sh

set -e

thread=15
zsh_link=https://github.com/zsh-users/zsh/archive/refs/tags/zsh-5.9.tar.gz

curl -L $zsh_link -o zsh.tar.gz && \
    tar -zxvf zsh.tar.gz && \
    rm -f zsh.tar.gz


cd zsh* && \
    ./configure --prefix=$PWD/zsh \
    --enable-multibyte --enable-locale && \
    make -j $thread && make install

echo "[INFO] zsh install done" >&1


