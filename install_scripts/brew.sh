#!/bin/bash
set -e

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

if ! need_cmd brew; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    export PATH="/opt/homebrew/bin:$PATH"
else
    print_info "brew is already installed"
fi

print_info "brew install done"
