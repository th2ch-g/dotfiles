#!/bin/bash
set -e

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

update_if_installed claude claude update

curl -fsSL https://claude.ai/install.sh | bash

print_info "claude-code install done"
