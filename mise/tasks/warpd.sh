#!/usr/bin/env bash
# Install the pinned warpd release on macOS when it is absent.
set -euo pipefail

[[ "$(uname -s)" == "Darwin" ]] || exit 0
command -v warpd > /dev/null 2>&1 && exit 0

curl -fsSL https://github.com/rvaiya/warpd/releases/download/v1.3.5/warpd-1.3.5-osx.tar.gz |
    sudo tar xzf - -C /
launchctl load /Library/LaunchAgents/com.warpd.warpd.plist 2> /dev/null || true
