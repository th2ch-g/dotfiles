#!/bin/bash
set -e

thread=15
VERSION="7.1.1-47"
PREFIX="${PWD}/ImageMagick-${VERSION}/build"

URL="https://github.com/ImageMagick/ImageMagick/archive/refs/tags/${VERSION}.tar.gz"
wget $URL
tar -xvzf ${VERSION}.tar.gz
rm -f ${VERSION}.tar.gz
cd ImageMagick-${VERSION}

./configure --prefix=${PREFIX}

make -j $thread && make install

export PATH=${PREFIX}/bin:$PATH

convert -version

echo done

