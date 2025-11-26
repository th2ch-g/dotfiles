#!/bin/bash
set -e

WORKS=$HOME/works

defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$WORKS/dotfiles/iterm2"

defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true

echo done
