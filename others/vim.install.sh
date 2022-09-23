#!/bin/sh

set -e

thread=15
vim_link=https://github.com/vim/vim/archive/refs/tags/v9.0.0539.tar.gz

curl -L $vim_link -o vim.tar.gz && \
    tar -zxvf vim.tar.gz && \
    rm -f vim.tar.gz

cd vim* && \
    ./configure --prefix=$PWD/vim --enable-perlinterp --enable-rubyinterp \
    --enable-multibyte --disable-netbeans --disable-gtktest --disable-acl \
    --disable-gpm --disable-xim --without-x --disable-gui && \
    make -j $thread && make install

echo "[INFO] vim install done" >&1

