#!/bin/bash
set -e

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

WORKS=$HOME/works

defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$WORKS/dotfiles/iterm2"

defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true

print_info "done"
