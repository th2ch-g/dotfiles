#!/bin/bash
set -eux

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

VERSION="7.1.1-47"
PREFIX="${PWD}/ImageMagick-${VERSION}/build"
BIN=${BIN:-$HOME/works/bin}
thread=$(detect_nproc)

[ -d "ImageMagick-${VERSION}" ] && {
    print_info "ImageMagick-${VERSION} already present, skipping"
    exit 0
}

URL="https://github.com/ImageMagick/ImageMagick/archive/refs/tags/${VERSION}.tar.gz"
curl -LO "$URL"
tar -xvzf ${VERSION}.tar.gz
rm -f ${VERSION}.tar.gz
cd ImageMagick-${VERSION}

./configure --prefix=${PREFIX}

make -j $thread && make install

ensure_bin ${PREFIX}/bin/convert

print_info "imagemagick install done"
