#!/bin/bash
set -eux

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

VERSION="v2.47.1"
thread=$(detect_nproc)
PREFIX="${PWD}/git-${VERSION}/build"
BIN=${BIN:-$HOME/works/bin}

[ -d "git-${VERSION}" ] && {
    print_info "git-${VERSION} already present, skipping"
    exit 0
}

URL="https://github.com/git/git/archive/refs/tags/${VERSION}.tar.gz"
curl -L $URL -o git-${VERSION}.tar.gz &&
    tar -zxvf git-${VERSION}.tar.gz &&
    rm -rf git-${VERSION}.tar.gz

cd git-${VERSION} &&
    make configure &&
    ./configure --prefix=${PREFIX} &&
    make all -j $thread && make install && cd ..

ensure_bin ${PREFIX}/bin/git

print_info "git install done"
