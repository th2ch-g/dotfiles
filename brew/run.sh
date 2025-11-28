#!/bin/bash
set -e

if ! command -v brew >/dev/null 2>&1; then
    echo "brew is not installed"
    exit 1
fi

brew bundle
yabai --start-service
skhd --start-service
yabai --restart-service
skhd --restart-service

echo done
