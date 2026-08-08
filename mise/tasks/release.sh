#!/usr/bin/env bash
# Create and push the daily release tag.
set -euo pipefail

tag="v$(date +'%Y.%m.%d')"
git tag -a "$tag" -m "Release $tag"
git push origin "$tag"
