#!/usr/bin/env bash
# Install the accelerator-specific llama.cpp build from the upstream installer.
set -euo pipefail

update=0
[[ "${1:-}" != "--update" ]] || update=1
if [[ -x "$HOME/.local/bin/llama" && "$update" -eq 0 ]]; then
    exit 0
fi

if curl -fsSL https://llama.app/install.sh | sh && [[ -x "$HOME/.local/bin/llama" ]]; then
    printf 'llama.cpp installation complete\n'
else
    printf 'warning: llama.cpp has no compatible build for this machine\n' >&2
fi
