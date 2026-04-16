#!/bin/bash
set -eux

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

VERSION=2.71
URL=http://ftp.gnu.org/gnu/autoconf/autoconf-${VERSION}.tar.gz
PREFIX=$PWD/autoconf-${VERSION}/build
BIN=${BIN:-$HOME/works/bin}
thread=$(detect_nproc)

[ -d "autoconf-${VERSION}" ] && {
    print_info "autoconf-${VERSION} already present, skipping"
    exit 0
}

curl -LO "$URL"

tar xvfz autoconf-${VERSION}.tar.gz

rm -rf autoconf-${VERSION}.tar.gz

cd autoconf-${VERSION}

./configure --prefix=$PREFIX

make -j $thread

make install

ensure_bin $PREFIX/bin/autoconf

print_info "autoconf install done"
