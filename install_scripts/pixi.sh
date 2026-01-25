#!/bin/bash
set -e

if command -v pixi >/dev/null 2>&1; then
    echo "pixi is already installed"
else
    curl -fsSL https://pixi.sh/install.sh | sh
fi

echo done
