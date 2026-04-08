#!/bin/bash
set -e

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

if need_cmd uv; then
    print_info "uv is already installed"
else
    curl -LsSf https://astral.sh/uv/install.sh | sh -s -- --no-modify-path
fi

print_info "uv install done"
