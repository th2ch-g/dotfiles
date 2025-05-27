#!/bin/bash
set -e

thread=15

wget https://github.com/ImageMagick/ImageMagick/archive/refs/tags/7.1.1-47.tar.gz
tar -xvzf 7.1.1-47.tar.gz
rm -f 7.1.1-47.tar.gz
cd ImageMagick-7.1.1-47

./configure --prefix=$PWD/build

make -j $thread && make install

export PATH=$PWD/build/bin:$PATH

convert -version

echo done

