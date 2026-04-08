#!/bin/bash
set -e

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

if ! need_cmd cargo; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    export PATH="${HOME}/.cargo/bin:$PATH"
else
    print_info "cargo is already installed"
fi

print_info "cargo install done"
