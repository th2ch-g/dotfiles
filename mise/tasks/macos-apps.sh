#!/usr/bin/env bash
# Install macOS applications unsupported by mise's built-in cask manager.
set -euo pipefail

[[ "$(uname -s)" == "Darwin" ]] || exit 0
install_docker() {
    [[ ! -d "/Applications/Docker.app" ]] || return
    local temp_dir mount_point
    temp_dir="$(mktemp -d)"
    mount_point="$temp_dir/mount"
    mkdir -p "$mount_point"
    curl -fsSL https://desktop.docker.com/mac/main/arm64/Docker.dmg -o "$temp_dir/Docker.dmg"
    hdiutil attach "$temp_dir/Docker.dmg" -nobrowse -mountpoint "$mount_point" > /dev/null
    sudo ditto "$mount_point/Docker.app" "/Applications/Docker.app"
    hdiutil detach "$mount_point" > /dev/null
    rm -rf "$temp_dir"
}

install_aerospace() {
    [[ ! -d "/Applications/AeroSpace.app" ]] || return
    local install_dir roots=()
    install_dir="$(mise where 'github:nikitabobko/AeroSpace')"
    roots=("$install_dir"/AeroSpace-v*)
    if [[ -d "${roots[0]}/AeroSpace.app" ]]; then
        if ! ditto "${roots[0]}/AeroSpace.app" "/Applications/AeroSpace.app"; then
            printf 'warning: copy AeroSpace.app to /Applications manually from %s\n' "$install_dir" >&2
        fi
    else
        printf 'warning: AeroSpace.app is missing from %s\n' "$install_dir" >&2
    fi
}

install_docker
install_aerospace
