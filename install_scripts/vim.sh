#!/bin/bash
set -eux

thread=15
VERSION="v9.1.1265"
PREFIX="${PWD}/vim-${VERSION}/build"

URL=https://github.com/vim/vim/archive/refs/tags/${VERSION}.tar.gz
curl -L $URL -o vim.tar.gz && \
    tar -zxvf vim.tar.gz && \
    rm -f vim.tar.gz

cd vim-${VERSION} && \
    ./configure --prefix=${PREFIX} --enable-perlinterp --enable-rubyinterp \
    --enable-multibyte --disable-netbeans --disable-gtktest --disable-acl \
    --disable-gpm --disable-xim --without-x --disable-gui && \
    make -j $thread && make install && \
    cd ..

echo "[INFO] vim install done" >&1
