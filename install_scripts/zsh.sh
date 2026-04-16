#!/bin/bash
set -eux

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

VERSION="5.9"
PREFIX="${PWD}/zsh-zsh-${VERSION}/build"
BIN=${BIN:-$HOME/works/bin}
thread=$(detect_nproc)

[ -d "zsh-zsh-${VERSION}" ] && {
    print_info "zsh-zsh-${VERSION} already present, skipping"
    exit 0
}

URL=https://github.com/zsh-users/zsh/archive/refs/tags/zsh-${VERSION}.tar.gz
curl -L $URL -o zsh.tar.gz &&
    tar -zxvf zsh.tar.gz &&
    rm -f zsh.tar.gz

cd zsh-zsh-${VERSION} &&
    ./Util/preconfig &&
    ./configure --prefix=${PREFIX} \
        --enable-multibyte --enable-locale &&
    make -j $thread && make install &&
    cd ..

ensure_bin ${PREFIX}/bin/zsh

print_info "zsh install done"
