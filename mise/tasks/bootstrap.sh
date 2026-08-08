#!/usr/bin/env bash
# Run idempotent setup that is not covered by declarative bootstrap sections.
set -euo pipefail

profile="${DOTFILES_PROFILE:-standard}"
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"

mkdir -p "$config_home/zsh" "$HOME/.ssh"
touch "$config_home/zsh/.zshrc_local" "$config_home/zsh/.zshenv_local"
chmod 700 "$HOME/.ssh"
if [[ -f "$HOME/.ssh/config" ]]; then
    chmod 600 "$HOME/.ssh/config"
fi

if [[ "$profile" == "guest" ]]; then
    exit 0
fi

if command -v vim > /dev/null 2>&1; then
    VIM_AI=1 vim -e -c "JetpackSync" -c "qa" || printf 'warning: Vim plugin sync failed\n' >&2
fi
if command -v nvim > /dev/null 2>&1; then
    VIM_AI=1 nvim --headless "+Lazy! restore" +qa || printf 'warning: Neovim lock restore failed\n' >&2
fi

if [[ "$profile" != "full" ]]; then
    exit 0
fi

bash mise/tasks/gh-extensions.sh
bash mise/tasks/claude.sh
bash mise/tasks/llama.sh
bash mise/tasks/macos-casks.sh
bash mise/tasks/macos-apps.sh
bash mise/tasks/warpd.sh

if [[ "$(uname -s)" == "Darwin" ]]; then
    defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$DOTFILES_DIR/iterm2"
    defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
fi

if command -v pre-commit > /dev/null 2>&1 && [[ -d "$DOTFILES_DIR/.git" ]]; then
    pre-commit install --install-hooks
fi
if [[ -d "$DOTFILES_DIR/.git" ]] && git -C "$DOTFILES_DIR" remote get-url origin > /dev/null 2>&1; then
    git -C "$DOTFILES_DIR" remote set-url origin git@github.com:th2ch-g/dotfiles.git
fi
if command -v yabai > /dev/null 2>&1; then
    yabai --restart-service 2> /dev/null || yabai --start-service
fi
if command -v skhd > /dev/null 2>&1; then
    skhd --restart-service 2> /dev/null || skhd --start-service
fi
