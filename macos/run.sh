#!/bin/bash
set -e

if [ "$(uname)" != "Darwin" ]; then
    echo "this script is only for macOS" >&2
    exit 1
fi


# Dock
defaults write com.apple.dock orientation -string left
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock show-recents -bool false


# Cursor
defaults write com.apple.universalaccess mouseDriverCursorSize -float 1.5


# Keyboard
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15


# Trackpad
defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 0
defaults write com.apple.AppleMultitouchTrackpad SecondClickThreshold -int 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad FirstClickThreshold -int 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad SecondClickThreshold -int 0

defaults write com.apple.AppleMultitouchTrackpad TrackpadSilentClicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadSilentClicking -bool true

defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadCornerSecondaryClick -int 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 0

defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true


# Window
defaults write com.apple.WindowManager GloballyEnabled -bool false

# Menubar
defaults write NSGlobalDomain _HIHideMenuBar -bool true

# DS Store
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true


# dockutil
if command -v dockutil >/dev/null 2>&1; then
    dockutil --remove all --no-restart
    for app in '/System/Applications/System Settings.app' '/System/Applications/Launchpad.app' '/Applications/Google Chrome.app' '/Applications/Slack.app' '/Applications/iTerm.app' '/Applications/Docker.app';
    do
        dockutil --add "$app" --no-restart --position end
    done
else
    echo "please install dockutil using brew" >&2
    exit 0
fi


echo "done" >&1
