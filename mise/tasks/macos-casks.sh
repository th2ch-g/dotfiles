#!/usr/bin/env bash
# Install missing GUI applications through mise without taking over existing casks.
set -euo pipefail

[[ "$(uname -s)" == "Darwin" ]] || exit 0
[[ "${DOTFILES_PROFILE:-standard}" == "full" ]] || exit 0

casks=(
    "bricklink-studio|/Applications/Studio 2.0.app"
    "google-chrome|/Applications/Google Chrome.app"
    "homerow|/Applications/Homerow.app"
    "inkscape|/Applications/Inkscape.app"
    "iterm2|/Applications/iTerm.app"
    "licecap|/Applications/LICecap.app"
    "slack|/Applications/Slack.app"
    "thunderbird|/Applications/Thunderbird.app"
    "tor-browser|/Applications/Tor Browser.app"
    "utm|/Applications/UTM.app"
    "whatcable|/Applications/WhatCable.app"
    "xquartz|/Applications/Utilities/XQuartz.app"
)

failed=()
for record in "${casks[@]}"; do
    package="${record%%|*}"
    app="${record#*|}"
    [[ ! -e "$app" ]] || continue
    if ! mise bootstrap packages apply --yes "brew-cask:$package"; then
        failed+=("$package")
    fi
done

if ((${#failed[@]})); then
    printf 'warning: mise could not install these casks: %s\n' "${failed[*]}" >&2
fi
