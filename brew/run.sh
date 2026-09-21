#!/bin/bash
set -e

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

if ! command -v brew > /dev/null 2>&1; then
    print_error "brew is not installed"
    exit 1
fi

# Sync the system to the Brewfile: install/upgrade listed packages and
# uninstall anything not listed without prompting.
brew bundle install --force-cleanup
# yabai --start-service
# skhd --start-service
# yabai --restart-service
# skhd --restart-service

print_info "done"
