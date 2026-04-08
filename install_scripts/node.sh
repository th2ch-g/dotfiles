#!/bin/bash
set -e

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

VERSION="24.13.0"
OS="$(uname | tr '[:upper:]' '[:lower:]')"
CPU="$(uname -m)"
BIN=${BIN:-$HOME/works/bin}

case "$CPU" in
    x86_64 | amd64)
        NODE_CPU="x64"
        ;;
    aarch64 | arm64)
        NODE_CPU="arm64"
        ;;
    *)
        print_error "Unsupported architecture for Node.js binary: $CPU"
        exit 1
        ;;
esac

[ -d "node-v${VERSION}-${OS}-${NODE_CPU}" ] && { print_info "node-v${VERSION} already present, skipping"; exit 0; }

URL="https://nodejs.org/download/release/v${VERSION}/node-v${VERSION}-${OS}-${NODE_CPU}.tar.gz"
ARCHIVE="$(basename "$URL")"

# Use the exact release URL so the requested version and archive name stay aligned.
curl -fL -o "$ARCHIVE" "$URL"
tar -xvzf "$ARCHIVE"
rm -rf "$ARCHIVE"

for f in ${PWD}/node-v${VERSION}-${OS}-${NODE_CPU}/bin/*; do
    ensure_bin "$f"
done

print_info "node install done"
