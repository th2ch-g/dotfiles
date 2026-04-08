#!/bin/bash
set -eux

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

VERSION="668"
PREFIX="${PWD}/less-${VERSION}/build"
BIN=${BIN:-$HOME/works/bin}
thread=$(detect_nproc)

[ -d "less-${VERSION}" ] && { print_info "less-${VERSION} already present, skipping"; exit 0; }

URL=https://greenwoodsoftware.com/less/less-${VERSION}.tar.gz
curl -L $URL -o less.tar.gz && \
    tar -zxvf less.tar.gz && \
    rm -f less.tar.gz

cd less-${VERSION} && \
    ./configure --prefix=${PREFIX} && \
    make -j $thread && make install && \
    cd ..

ensure_bin ${PREFIX}/bin/less

print_info "less install done"
