#!/bin/bash
set -e

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

update_if_installed uv uv self update

curl -LsSf https://astral.sh/uv/install.sh | sh -s -- --no-modify-path

print_info "uv install done"
