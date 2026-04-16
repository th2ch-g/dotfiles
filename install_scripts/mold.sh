#!/bin/bash
set -e

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

PREFIX="${PWD}/mold/build"
BIN=${BIN:-$HOME/works/bin}
thread=$(detect_nproc)

[ -d "mold" ] && {
    print_info "mold already present, skipping"
    exit 0
}

git clone --branch stable https://github.com/rui314/mold.git
cd mold
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=c++ -B build -DCMAKE_INSTALL_PREFIX=$PREFIX
cmake --build build -j $thread
cmake --build build --target install

ensure_bin ${PREFIX}/bin/mold

print_info "mold install done"
