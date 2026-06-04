#!/bin/bash
# Install every uv tool listed in requirements.txt (one tool per line).
#
# Each non-comment line is a uv tool spec: a PyPI name (optionally with
# extras, e.g. markitdown[all]) or a git+https URL. Blank lines and `#`
# comment lines are ignored.
#
# Failures are collected instead of aborting the loop: every tool is
# attempted, and the script exits non-zero with a summary if any failed.

set -uo pipefail

failed=()

while IFS= read -r line; do
    # Skip comment lines and blank/whitespace-only lines.
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line//[[:space:]]/}" ]] && continue

    # First whitespace-delimited token is the tool spec; ignore any trailing text.
    read -r target _ <<< "$line"
    echo "+ $target"

    uv tool install -U "$target" || failed+=("$target")
done < requirements.txt

if ((${#failed[@]} > 0)); then
    echo "[ERROR] python-install-list: ${#failed[@]} tool(s) failed:" >&2
    printf '  - %s\n' "${failed[@]}" >&2
    exit 1
fi

echo "[INFO] python-install-list done"
