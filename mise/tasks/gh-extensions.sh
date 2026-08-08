#!/usr/bin/env bash
# Install the declared GitHub CLI extensions without removing other extensions.
set -euo pipefail

command -v gh > /dev/null 2>&1 || exit 0
extensions=(
    babarot/gh-infra
    th2ch-g/gh-email-get
    th2ch-g/gh-repo-history
)
for extension in "${extensions[@]}"; do
    if gh extension list | awk -v extension="$extension" '$1 == extension { found = 1 } END { exit !found }'; then
        gh extension upgrade "$extension" || true
    else
        gh extension install "$extension"
    fi
done
