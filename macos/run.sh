#!/bin/bash
set -ex

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

if [ "$(uname)" != "Darwin" ]; then
    print_error "this script is only for macOS"
    exit 1
fi

# default setting
dockutil_flag=1
google_ime_flag=1

USAGE='
Usage:
    -h, --help          Show this help message
    -d, --dockutil      Use dockutil
        --google-ime   Enable Google Japanese Input
'

# option parser
while :; do
    case $1 in
        -h | --help)
            echo "$USAGE" >&1
            exit 0
            ;;
        -d | --dockutil)
            dockutil_flag=0
            ;;
        --google-ime)
            google_ime_flag=0
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
            ;;
    esac
    shift
done

# Dock
defaults write com.apple.dock orientation -string left
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock show-recents -bool false

# accessibility
# cannot

# Cursor
sudo defaults write com.apple.universalaccess mouseDriverCursorSize -float 5
sudo defaults write com.apple.universalaccess accessibilityCursorSize -float 3.0

# Keyboard
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

defaults write com.apple.inputmethod.Kotoeri JIMPrefLiveConversionKey -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Google Japanese Input
if [[ $google_ime_flag -eq 0 ]]; then
    google_ime_sources=$(defaults read com.apple.HIToolbox AppleEnabledInputSources 2> /dev/null || true)
    google_ime_sources=${google_ime_sources//[[:space:]]/}
    google_ime_changed=0

    has_google_ime_source() {
        local kind=$1 mode=${2:-} remaining=$google_ime_sources entry
        while [[ $remaining == *'{'* ]]; do
            remaining=${remaining#*\{}
            entry=${remaining%%\}*}
            remaining=${remaining#*\}}
            if [[ $entry == *'"BundleID"="com.google.inputmethod.Japanese";'* &&
                $entry == *"InputSourceKind=\"$kind\";"* ]]; then
                if [[ -z $mode || $entry == *"\"InputMode\"=\"$mode\";"* ]]; then
                    return 0
                fi
            fi
        done
        return 1
    }

    if ! has_google_ime_source KeyboardInputMethod; then
        defaults write com.apple.HIToolbox AppleEnabledInputSources -array-add \
            '{ "Bundle ID" = "com.google.inputmethod.Japanese"; InputSourceKind = "Keyboard Input Method"; }'
        google_ime_changed=1
    fi

    if ! has_google_ime_source InputMode com.apple.inputmethod.Japanese; then
        defaults write com.apple.HIToolbox AppleEnabledInputSources -array-add \
            '{ "Bundle ID" = "com.google.inputmethod.Japanese"; "Input Mode" = "com.apple.inputmethod.Japanese"; InputSourceKind = "Input Mode"; }'
        google_ime_changed=1
    fi
    if [[ $google_ime_changed -eq 1 ]]; then
        print_info "Google Japanese Input (Hiragana) configured. Log out and back in to apply."
    else
        print_info "Google Japanese Input (Hiragana) is already in input source preferences."
    fi
fi

# banner
defaults write com.apple.notificationcenterui bannerTime -int 120
killall NotificationCenter

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
# defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "外出中"

# Menubar
defaults write NSGlobalDomain _HIHideMenuBar -bool true
defaults -currentHost write com.apple.controlcenter.BatteryShowPercentage -bool true
# killall exits 1 when the process is not running; do not abort under set -e
killall ControlCenter || true

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
defaults write -g com.apple.sound.uiaudio.enabled -int 0
sudo nvram SystemAudioVolume=%01
killall SystemUIServer || true

# office
defaults write com.microsoft.autoupdate2 HowToCheck -string "Manual"

# dockutil
if [ $dockutil_flag -eq 0 ]; then
    if command -v dockutil > /dev/null 2>&1; then
        dockutil --remove all --no-restart
        dockutil --add '/System/Applications/System Settings.app' --allhomes --no-restart
        dockutil --add '/Applications/Google Chrome.app' --allhomes --no-restart
        dockutil --add '/Applications/Slack.app' --allhomes --no-restart
        dockutil --add '/Applications/iTerm.app' --allhomes --no-restart
        dockutil --add '/Applications/Docker.app' --allhomes --no-restart
        dockutil --add '/Applications/Utilities/XQuartz.app' --allhomes --no-restart
        dockutil --add "$HOME/Desktop" --allhomes --no-restart
        dockutil --add "$HOME/Downloads" --allhomes --no-restart
        killall Dock
    else
        print_warn "please install dockutil using brew"
        exit 0
    fi
fi

print_info "done"
