#!/bin/bash
set -e

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

URL=https://github.com/supertuxkart/stk-code/releases/download/1.4/SuperTuxKart-1.4-linux-x86_64.tar.xz

[ -d "SuperTuxKart-1.4-linux-x86_64" ] && { print_info "SuperTuxKart already present, skipping"; exit 0; }

curl -LO "$URL"
tar Jxfv SuperTuxKart-1.4-linux-x86_64.tar.xz
rm -f SuperTuxKart-1.4-linux-x86_64.tar.xz

print_info "supertuxkart install done"
