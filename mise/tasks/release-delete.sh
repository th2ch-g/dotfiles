#!/usr/bin/env bash
# Delete one release tag locally and from origin.
set -euo pipefail

tag="${1:-}"
[[ -n "$tag" ]] || {
    printf 'usage: mise run release:delete -- vYYYY.MM.DD\n' >&2
    exit 1
}
git tag -d "$tag"
git push origin --delete "$tag"
