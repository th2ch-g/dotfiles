#!/bin/bash
set -e

install_path=$PWD
thread=15

make -j $thread CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=${install_path}/nvim
make -j $thread install

echo done >&1
