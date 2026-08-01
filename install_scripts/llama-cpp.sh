#!/bin/bash
set -e
set -o pipefail

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

# Upstream installer: https://github.com/ggml-org/llama-install.sh
# It probes the machine (Metal / CUDA / ROCm / Vulkan / CPU), then drops a
# single unified `llama` binary into ~/.llama-app and copies it to
# ~/.local/bin/llama -- already on PATH via zsh/.zshenv. The old per-tool
# binaries are subcommands now: `llama serve`, `llama cli`, `llama bench`,
# `llama quantize`.
#
# NOTE: deliberately not update_if_installed -- the installer wipes
# ~/.llama-app and re-downloads the latest build on every run, so a re-run *is*
# the update. Dispatching `llama update` instead would resolve `llama` on PATH,
# which may still be a pixi- or brew-provided build.
if [ -x "$HOME/.local/bin/llama" ]; then
    print_info "llama is already installed, reinstalling the latest build"
fi

# `curl | sh` cannot fail the script on its own: with -f a network error leaves
# sh reading empty stdin and exiting 0. pipefail plus the binary check below is
# what actually decides success.
#
# Warn instead of aborting: macOS has no CPU fallback (only Apple silicon
# M1-M5 / A18 Metal builds exist), so an unsupported machine is an expected
# outcome, and install.sh's remaining steps should still run.
if curl -fsSL https://llama.app/install.sh | sh && [ -x "$HOME/.local/bin/llama" ]; then
    print_info "llama.cpp install done"
else
    print_warn "llama.cpp install failed (no prebuilt binary for this machine?)"
fi
