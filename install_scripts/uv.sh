#!/bin/bash
set -e

if command -v uv >/dev/null 2>&1; then
    echo "uv is already installed"
else
    curl -LsSf https://astral.sh/uv/install.sh | sh -s -- --no-modify-path
fi

echo done
