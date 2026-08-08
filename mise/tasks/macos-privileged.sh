#!/usr/bin/env bash
# Apply settings that mise macOS defaults cannot manage without elevated access.
set -euo pipefail

[[ "$(uname -s)" == "Darwin" ]] || {
    printf 'error: macos:privileged is macOS only\n' >&2
    exit 1
}
if [[ "${DOTFILES_CONFIRM_PRIVILEGED:-}" != "1" ]]; then
    printf 'This writes host and root-owned macOS settings. Type APPLY to continue: '
    read -r answer
    [[ "$answer" == "APPLY" ]] || exit 1
fi

sudo defaults write com.apple.universalaccess mouseDriverCursorSize -float 5
sudo defaults write com.apple.universalaccess accessibilityCursorSize -float 3.0
defaults -currentHost write com.apple.screensaver idleTime -int 0
defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -bool true
sudo nvram SystemAudioVolume=%01
killall ControlCenter 2> /dev/null || true
killall SystemUIServer 2> /dev/null || true
