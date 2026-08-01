#!/bin/bash
set -e

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

update_if_installed opencode opencode upgrade

curl -fsSL https://opencode.ai/install | bash

print_info "opencode install done"
