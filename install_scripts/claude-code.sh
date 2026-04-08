#!/bin/bash
set -e

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

skip_if_installed claude

curl -fsSL https://claude.ai/install.sh | bash

print_info "claude-code install done"
