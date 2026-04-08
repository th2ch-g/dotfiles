#!/bin/bash
set -e

# for macos
source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

skip_if_installed warpd

VERSION=1.3.5
curl -L https://github.com/rvaiya/warpd/releases/download/v${VERSION}/warpd-${VERSION}-osx.tar.gz | sudo tar xzvfC - / && launchctl load /Library/LaunchAgents/com.warpd.warpd.plist

print_info "warpd install done"
