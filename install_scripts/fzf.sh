#!/bin/bash
set -eux

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

XDG_CONFIG_HOME=${HOME}/.config

[ -d "${XDG_CONFIG_HOME}/fzf" ] && { print_info "fzf already present, skipping"; exit 0; }

git clone --depth 1 https://github.com/junegunn/fzf.git $XDG_CONFIG_HOME/fzf && \
$XDG_CONFIG_HOME/fzf/install

print_info "fzf install done"
