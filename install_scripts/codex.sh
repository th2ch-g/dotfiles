#!/bin/bash
set -e

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

update_if_installed codex codex update

curl -fsSL https://chatgpt.com/codex/install.sh | sh

print_info "codex install done"
