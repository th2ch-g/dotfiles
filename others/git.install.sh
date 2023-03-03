#!/bin/bash

set -e
URL="https://github.com/git/git/archive/refs/tags/v2.40.0-rc1.tar.gz"
thread=15
install_path=$PWD

curl -L $URL -o git.tar.gz && \
    tar -zxvf git.tar.gz && \
    rm -rf git.tar.gz

cd git* && \
    make configure && \
    ./configure --prefix=${install_path}/git && \
    make all -j $thread && cd .. && \
    echo "[INFO] git install done" >&1

