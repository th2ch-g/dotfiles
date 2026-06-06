#!/bin/bash
set -e

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

if ! need_cmd gh; then
    print_error "gh is not installed (run: ./install.sh --pixi --pixi-pkgs)"
    exit 1
fi

# Snapshot installed extensions once, then match each list entry against that
# string. Capturing up front (instead of piping `gh extension list` per line)
# avoids the SIGPIPE that `grep -q` raises by closing the pipe early, and keeps
# gh off the loop's stdin. `install` errors out on an already-present extension
# (which would abort under `set -e`), so skip those and let `upgrade --all`
# refresh them below.
installed=$(gh extension list)

while IFS= read -r line; do
    # Skip comments (header + disabled entries); read OWNER/REPO from "- repo:".
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ "$line" =~ ^[[:space:]]*-[[:space:]]+repo:[[:space:]]+([^[:space:]]+) ]] || continue
    ext="${BASH_REMATCH[1]}"
    print_step "$ext"
    if grep -qF "$ext" <<< "$installed"; then
        print_info "$ext already installed, skipping"
    else
        gh extension install "$ext" < /dev/null
    fi
done < list.yaml

# Upgrade all installed extensions to their latest release.
gh extension upgrade --all || true

print_info "gh-ext done"
