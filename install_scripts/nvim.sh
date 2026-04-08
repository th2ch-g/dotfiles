#!/bin/bash
set -eux

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

VERSION="0.10.4"
PREFIX="${PWD}/neovim-${VERSION}/build"
BIN=${BIN:-$HOME/works/bin}
thread=$(detect_nproc)

[ -d "neovim-${VERSION}" ] && { print_info "neovim-${VERSION} already present, skipping"; exit 0; }

URL="https://github.com/neovim/neovim/archive/refs/tags/v${VERSION}.tar.gz"
curl -L "$URL" -o "v${VERSION}.tar.gz"
tar -xvzf v${VERSION}.tar.gz
rm -rf v${VERSION}.tar.gz
cd neovim-${VERSION}
make -j $thread CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=${PREFIX}
make -j $thread install

ensure_bin ${PREFIX}/bin/nvim

print_info "nvim install done"
