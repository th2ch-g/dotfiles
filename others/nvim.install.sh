#!/bin/bash
set -e

install_path=$PWD
thread=15

wget https://github.com/neovim/neovim/archive/refs/tags/v0.10.4.tar.gz
tar -xvzf v0.10.4.tar.gz
cd neovim-0.10.4
make -j $thread CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=${install_path}/nvim
make -j $thread install
rm -rf neovim-0.10.4 v0.10.4.tar.gz

echo done >&1
