#!/bin/bash
set -ex

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

if [ "$(uname)" != "Darwin" ]; then
    print_error "this script is only for macOS"
    exit 1
fi

# default setting
dockutil_flag=1
login_items_only=0

USAGE='
Usage:
    -h, --help          Show this help message
    -d, --dockutil      Use dockutil
    --login-items-only Configure only login items
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
        --login-items-only)
            login_items_only=1
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

# Login items
if need_cmd loginitems; then
    while IFS='|' read -r app_name app_id; do
        app_path=$(
            osascript -l JavaScript - "$app_id" << 'JXA'
ObjC.import('AppKit');
function run(argv) {
    const appURL = $.NSWorkspace.sharedWorkspace.URLForApplicationWithBundleIdentifier(argv[0]);
    return appURL.isNil() ? '' : ObjC.unwrap(appURL.path);
}
JXA
        )
        if [ -z "$app_path" ]; then
            print_warn "$app_name is not installed, skipping login setup"
            continue
        fi
        loginitems -a "$app_name" -p "$app_path"
        print_info "Enabled login startup for $app_name"
    done << 'APPS'
AeroSpace|bobko.aerospace
iTerm|com.googlecode.iterm2
Google Chrome|com.google.Chrome
Slack|com.tinyspeck.slackmacgap
XQuartz|org.xquartz.X11
APPS
elif [ "$login_items_only" -eq 1 ]; then
    print_error "install ojford/formulae/loginitems using brew first"
    exit 1
else
    print_warn "loginitems is not installed, skipping login setup"
fi

if [ "$login_items_only" -eq 1 ]; then
    exit 0
fi

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
