#!/bin/bash
set -e

if ! command -v brew > /dev/null 2>&1; then
    echo "brew is not installed"
    exit 1
fi

# Sync the system to the Brewfile: install/upgrade listed packages and
# uninstall anything not listed. --force-cleanup removes unlisted packages
# without prompting; newer brew rejects `--cleanup` unless one of
# --force-cleanup/--force/$HOMEBREW_ASK is also given.
brew bundle install --cleanup --force-cleanup
# yabai --start-service
# skhd --start-service
# yabai --restart-service
# skhd --restart-service

echo "done"
