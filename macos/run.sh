#!/bin/bash
set -e

if [ "$(uname)" != "Darwin" ]; then
    echo "this script is only for macOS" >&2
    exit 1
fi

# Dock
# defaults write com.apple.dock autohide -bool true
# defaults write com.apple.dock largesize -int 48
# defaults write com.apple.dock magnification -bool true
# defaults write com.apple.dock position -string "left"

# Cursor


# Trackpad


echo "done" >&1
