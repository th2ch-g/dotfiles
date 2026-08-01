#!/bin/bash
set -e

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

update_if_installed opencode opencode upgrade

curl -fsSL https://opencode.ai/install | bash

# The vendor installer lands in ~/.opencode/bin, which no tracked zsh config
# puts on PATH (unlike codex/claude-code, which use ~/.local/bin).
ensure_bin "$HOME/.opencode/bin/opencode"

print_info "opencode install done"
