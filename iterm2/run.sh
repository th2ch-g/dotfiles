#!/bin/bash
set -e

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

# Point iTerm2 at this directory itself, so a checkout outside the default
# ~/works/dotfiles location (SETUP_DIR=...) still resolves correctly.
ITERM2_DIR="$(cd "$(dirname "$0")" && pwd)"

defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$ITERM2_DIR"

defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true

# Save GUI changes automatically (0: on quit, 1: never, 2: always).
defaults write com.googlecode.iterm2 NoSyncNeverRemindPrefsChangesLostForFile -bool true
defaults write com.googlecode.iterm2 NoSyncNeverRemindPrefsChangesLostForFile_selection -int 2

print_info "done"
