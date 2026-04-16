#!/bin/bash
set -e

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

VERSION="1.7.4"
URL="https://git.zx2c4.com/password-store/snapshot/password-store-${VERSION}.tar.xz"
PREFIX="${PWD}/password-store-${VERSION}"
BIN=${BIN:-$HOME/works/bin}

[ -d "password-store-${VERSION}" ] && {
    print_info "password-store-${VERSION} already present, skipping"
    exit 0
}

curl -LO "$URL"
tar Jxfv password-store-${VERSION}.tar.xz
rm -rf password-store-${VERSION}.tar.xz
cd password-store-${VERSION}

sed -i.bak "s#PREFIX ?= /usr#PREFIX ?= ${PREFIX}#g" Makefile && rm -f Makefile.bak

make install

for f in ${PREFIX}/bin/*; do
    ensure_bin "$f"
done

print_info "password-store install done"
