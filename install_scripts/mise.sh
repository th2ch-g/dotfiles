#!/bin/bash
set -e

if command -v mise >/dev/null 2>&1; then
    echo "mise is already installed"
else
    curl https://mise.jdx.dev/install.sh | sh
    export PATH="${HOME}/.local/bin:$PATH"
fi

echo "[INFO] mise install done"
