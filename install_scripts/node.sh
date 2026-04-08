#!/bin/bash
set -e

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

VERSION="24.13.0"
VERSION_LATEST="$(echo $VERSION | cut -d '.' -f 1).x"
OS="$(uname | tr '[:upper:]' '[:lower:]')"
CPU="$(uname -m)"
BIN=${BIN:-$HOME/works/bin}

[ -d "node-v${VERSION}-${OS}-${CPU}" ] && { print_info "node-v${VERSION} already present, skipping"; exit 0; }

URL="https://nodejs.org/download/release/latest-v${VERSION_LATEST}/node-v${VERSION}-${OS}-${CPU}.tar.gz"
curl -LO "$URL"
tar -xvzf $(basename $URL)
rm -rf $(basename $URL)

for f in ${PWD}/node-v${VERSION}-${OS}-${CPU}/bin/*; do
    ensure_bin "$f"
done

print_info "node install done"
