#!/bin/bash
set -eux

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

VERSION="3.31.6"
INSTALL_PREFIX="${PWD}/cmake-${VERSION}/build"
BIN=${BIN:-$HOME/works/bin}
thread=$(detect_nproc)

[ -d "cmake-${VERSION}" ] && { print_info "cmake-${VERSION} already present, skipping"; exit 0; }

URL="https://github.com/Kitware/CMake/releases/download/v${VERSION}/cmake-${VERSION}.tar.gz"
curl -LO "$URL"
tar -zxvf cmake-${VERSION}.tar.gz
cd cmake-${VERSION}

./bootstrap --prefix=${INSTALL_PREFIX} --parallel=$thread

make -j $thread
make install -j $thread

ensure_bin ${INSTALL_PREFIX}/bin/cmake

print_info "cmake install done"
