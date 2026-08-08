#!/usr/bin/env bash
# Rebuild the Dock only when this explicit destructive task is invoked.
set -euo pipefail

[[ "$(uname -s)" == "Darwin" ]] || {
    printf 'error: macos:dock is macOS only\n' >&2
    exit 1
}
command -v dockutil > /dev/null 2>&1 || {
    printf 'error: dockutil is not installed\n' >&2
    exit 1
}

if [[ "${DOTFILES_CONFIRM_DOCK:-}" != "1" ]]; then
    printf 'This removes every Dock item. Type REBUILD to continue: '
    read -r answer
    [[ "$answer" == "REBUILD" ]] || exit 1
fi

dockutil --remove all --no-restart
items=(
    "/System/Applications/System Settings.app"
    "/Applications/Google Chrome.app"
    "/Applications/Slack.app"
    "/Applications/iTerm.app"
    "/Applications/Docker.app"
    "/Applications/Utilities/XQuartz.app"
    "$HOME/Desktop"
    "$HOME/Downloads"
)
for item in "${items[@]}"; do
    if [[ -e "$item" ]]; then
        dockutil --add "$item" --allhomes --no-restart
    else
        printf 'warning: Dock item is missing: %s\n' "$item" >&2
    fi
done
killall Dock
