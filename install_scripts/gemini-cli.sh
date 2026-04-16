#!/bin/bash
set -e

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

BIN=${BIN:-$HOME/works/bin}

[ -e "gemini" ] && {
    print_info "gemini already present, skipping"
    exit 0
}

URL="https://github.com/google-gemini/gemini-cli/releases/download/v0.18.0-nightly.20251118.7cc5234b9/gemini.js"
curl -LO "$URL"
chmod a+x gemini.js
mv gemini.js gemini

ensure_bin "${PWD}/gemini"

print_info "gemini-cli install done"
