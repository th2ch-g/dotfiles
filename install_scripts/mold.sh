#!/bin/bash
set -e

PREFIX="${PWD}/mold/bin"
thread=2

git clone --branch stable https://github.com/rui314/mold.git
cd mold
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=c++ -B build -DCMAKE_INSTALL_PREFIX=$PREFIX
cmake --build build -j $thread
cmake --build build --target install

ln -s ${PREFIX}/bin/mold $HOME/works/bin

echo done
