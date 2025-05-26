#!/bin/bash
set -e

if [ "$(uname)" != "Darwin" ]; then
    echo "this script is only for macOS" >&2
    exit 1
fi

# default setting
dockutil_flag=1

# option parser
while :;
do
    case $1 in
        -h | --help)
            echo "$USAGE" >&1
            exit 0
            ;;
        -d | --dockutil)
            dockutil_flag=0
            ;;
       --)
            shift
            break
            ;;
        -?*)
            print_error "Unknown option: $1"
            exit 1
            ;;
        *)
            break
    esac
    shift
done


# Dock
defaults write com.apple.dock orientation -string left
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock show-recents -bool false


# Cursor
# Error
# defaults write com.apple.universalaccess mouseDriverCursorSize -float 5
# defaults write com.apple.universalaccess accessibilityCursorSize -float 3.0


# Keyboard
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

defaults write com.apple.inputmethod.Kotoeri JIMPrefLiveConversionKey -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false


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
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false
defaults -currentHost write com.apple.screensaver idleTime -int 0

# Menubar
defaults write NSGlobalDomain _HIHideMenuBar -bool true


# DS Store
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Screenshot
defaults write com.apple.screencapture location ~/Downloads/
defaults write com.apple.screencapture type png
defaults write com.apple.screencapture name "ss"
defaults write com.apple.screencapture disable-sound -bool true


# Xquartz
defaults write org.macosforge.xquartz.X11 enable_iglx -bool true


# Sound
defaults write com.apple.systemsound com.apple.sound.uiaudio.enabled -bool false
defaults write NSGlobalDomain com.apple.sound.beep.feedback -bool false


# dockutil
if [ $dockutil_flag -eq 0 ]; then
    if command -v dockutil >/dev/null 2>&1; then
        dockutil --remove all --no-restart
        dockutil --add '/System/Applications/System Settings.app' --allhomes --no-restart
        dockutil --add '/System/Applications/Launchpad.app' --allhomes --no-restart
        dockutil --add '/Applications/Google Chrome.app' --allhomes --no-restart
        dockutil --add '/Applications/Slack.app' --allhomes --no-restart
        dockutil --add '/Applications/iTerm.app' --allhomes --no-restart
        dockutil --add '/Applications/Docker.app' --allhomes --no-restart
        dockutil --add '/Applications/Utilities/XQuartz.app' --allhomes --no-restart
        dockutil --add '~/Desktop' --allhomes --no-restart
        dockutil --add '~/Downloads' --allhomes --no-restart
        killall Dock
    else
        echo "please install dockutil using brew" >&2
        exit 0
    fi
fi

echo "done" >&1
