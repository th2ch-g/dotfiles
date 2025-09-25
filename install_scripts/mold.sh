#!/bin/bash
set -e

PREFIX="${PWD}/mold/bin"
thread=12

git clone --branch stable https://github.com/rui314/mold.git
cd mold
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=c++ -B build -DCMAKE_INSTALL_PREFIX=$PREFIX
cmake --build build -j $thread
cmake --build build --target install

echo done
