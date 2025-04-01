#!/bin/bash

set -e

thread=15
vim_link=https://github.com/vim/vim/archive/refs/tags/v9.1.1265.tar.gz
install_path=$PWD

curl -L $vim_link -o vim.tar.gz && \
    tar -zxvf vim.tar.gz && \
    rm -f vim.tar.gz

cd vim* && \
    ./configure --prefix=${install_path}/vim --enable-perlinterp --enable-rubyinterp \
    --enable-multibyte --disable-netbeans --disable-gtktest --disable-acl \
    --disable-gpm --disable-xim --without-x --disable-gui && \
    make -j $thread && make install && \
    cd .. && rm -rf vim-*

echo "[INFO] vim install done" >&1

