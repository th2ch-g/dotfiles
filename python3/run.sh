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

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

failed=()

while IFS= read -r line; do
    # Skip comment lines and blank/whitespace-only lines.
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line//[[:space:]]/}" ]] && continue

    # First whitespace-delimited token is the tool spec; ignore any trailing text.
    read -r target _ <<< "$line"
    print_step "$target"

    uv tool install -U "$target" || failed+=("$target")
done < requirements.txt

if ((${#failed[@]} > 0)); then
    print_error "python-install-list: ${#failed[@]} tool(s) failed:"
    printf '  - %s\n' "${failed[@]}" >&2
    exit 1
fi

print_info "python-install-list done"
