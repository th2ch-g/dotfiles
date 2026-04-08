#!/bin/bash
set -e

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

if need_cmd pixi; then
    print_info "pixi is already installed"
else
    curl -fsSL https://pixi.sh/install.sh | sh
fi

print_info "pixi install done"
