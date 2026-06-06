#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=lib/utils.sh
source "$(dirname "$0")/utils.sh"

if [[ $# -lt 2 ]]; then
    print_error "usage: $0 <plain|brewfile> <file>..."
    exit 2
fi

mode=$1
shift

# Sort the lines matching `filter` in `file` in place, preserving the positions
# of non-matching lines. The file is rewritten only when the matched lines are
# not already sorted; the position-preserving rewrite lets pre-commit detect the
# change and fail the hook.
sort_block() {
    local file=$1 filter=$2
    shift 2
    local sort_args=("$@")

    local actual sorted rewritten
    actual=$(mktemp)
    sorted=$(mktemp)
    rewritten=$(mktemp)

    if ! grep -E "$filter" "$file" > "$actual"; then
        : > "$actual"
    fi

    LC_ALL=C sort "${sort_args[@]}" "$actual" > "$sorted"

    if ! cmp -s "$actual" "$sorted"; then
        awk -v filter="$filter" -v sorted_file="$sorted" '
            BEGIN {
                while ((getline line < sorted_file) > 0) {
                    sorted[++count] = line
                }
                close(sorted_file)
            }
            $0 ~ filter {
                print sorted[++line_index]
                next
            }
            { print }
            END {
                if (line_index != count) {
                    exit 1
                }
            }
        ' "$file" > "$rewritten"
        cat "$rewritten" > "$file"
        print_warn "Sorted $file"
    fi

    rm -f "$actual" "$sorted" "$rewritten"
}

case "$mode" in
    plain)
        for file in "$@"; do
            sort_block "$file" '^[[:space:]]*[^#[:space:]]' -k 1
        done
        ;;
    brewfile)
        # Brewfile holds two independent descending blocks: active package
        # lines and commented-out (disabled) package lines. Commented-out
        # packages must sit below every active one. An active line appearing
        # after a commented package line is an interleave that cannot be
        # auto-fixed (e.g. a freshly commented-out entry left in place), so we
        # fail loudly instead of guessing where to move it.
        active='^(tap|brew|cask) '
        commented='^# (tap|brew|cask) '
        for file in "$@"; do
            last_active=$(grep -nE "$active" "$file" | tail -n1 | cut -d: -f1) || true
            first_commented=$(grep -nE "$commented" "$file" | head -n1 | cut -d: -f1) || true
            if [[ -n "$last_active" && -n "$first_commented" && "$first_commented" -lt "$last_active" ]]; then
                print_error "$file: commented-out package at line $first_commented is above active package at line $last_active"
                print_error "Move commented-out packages below all active ones."
                exit 1
            fi
            sort_block "$file" "$active" -k 1,1r -k 2,2r
            sort_block "$file" "$commented" -k 2,2r -k 3,3r
        done
        ;;
    yaml-seq)
        # Verify that "- crate:/- url:/- repo:" record keys appear in sorted
        # order. Commented-out records (disabled candidates) start with '#' and
        # are ignored, matching the active-only sort the .txt format used.
        # Records span multiple lines, so this is fail-only: unlike plain/
        # brewfile it does not auto-reorder in place; sort manually if it fails.
        for file in "$@"; do
            actual=$(grep -E '^[[:space:]]*- (crate|url|repo): ' "$file" |
                sed -E 's/^[[:space:]]*- (crate|url|repo): //; s/[[:space:]].*//') || true
            sorted=$(LC_ALL=C sort <<< "$actual")
            if [[ "$actual" != "$sorted" ]]; then
                print_error "$file: entries not sorted (sort by crate/url/repo key)"
                exit 1
            fi
        done
        ;;
    *)
        print_error "unknown mode: $mode"
        exit 2
        ;;
esac

exit 0
