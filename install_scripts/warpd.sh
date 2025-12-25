#!/bin/bash
set -e

# for macos
VERSION=1.3.5
curl -L https://github.com/rvaiya/warpd/releases/download/v${VERSION}/warpd-${VERSION}-osx.tar.gz |  sudo tar xzvfC - / && launchctl load /Library/LaunchAgents/com.warpd.warpd.plist

echo done
