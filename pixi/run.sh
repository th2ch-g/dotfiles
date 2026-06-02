#!/bin/bash
set -e

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

if ! need_cmd pixi; then
    print_error "pixi is not installed (run: ./install.sh --pixi)"
    exit 1
fi

# pixi global sync has no --manifest-path; it always reads
# $PIXI_HOME/manifests/pixi-global.toml. Link the tracked manifest there so the
# repository stays the single source of truth.
PIXI_HOME="${PIXI_HOME:-$HOME/works/tools/pixi}"
manifest_dir="$PIXI_HOME/manifests"
manifest_src="$(cd "$(dirname "$0")" && pwd)/pixi-global.toml"

mkdir -p "$manifest_dir"
ln -sf "$manifest_src" "$manifest_dir/pixi-global.toml"
print_info "linked pixi-global.toml -> $manifest_dir/pixi-global.toml"

# PIXI_FROZEN (set in .zshenv) can block solving brand-new envs on first run,
# so unset it for this sync only.
env -u PIXI_FROZEN pixi global sync

print_info "pixi global sync done"
