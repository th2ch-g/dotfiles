#!/bin/bash
set -e

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

update_if_installed pixi pixi self-update

curl -fsSL https://pixi.sh/install.sh | sh

print_info "pixi install done"
