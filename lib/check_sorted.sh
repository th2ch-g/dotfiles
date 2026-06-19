#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=lib/utils.sh
source "$(dirname "$0")/utils.sh"

if [[ $# -lt 2 ]]; then
    print_error "usage: $0 <plain|brewfile|yaml-seq> <file>..."
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

# Sort a YAML "packages:"/"extensions:" sequence in place by record key
# (crate/url/repo). Active records (- crate:/url:/repo: plus their indented
# desc/bin/feature continuation lines) are reordered; comment lines (disabled
# candidates, wherever they sit — a freshly commented-out entry left mid-list or
# a trailing block), blank lines and the header keep their positions and act as
# fixed anchors, mirroring the position-preserving rewrite the plain/brewfile
# modes use. Multi-line records are folded onto one line (continuations joined
# with \001) so a record sorts as a unit, then unfolded back. Single-line
# records (e.g. gh-ext "- repo:") fold to themselves and work the same way.
sort_yaml_seq() {
    local record='^[[:space:]]*-[[:space:]]+(crate|url|repo):[[:space:]]'
    local file=$1
    local folded sorted_records rewritten
    folded=$(mktemp)
    sorted_records=$(mktemp)
    rewritten=$(mktemp)

    # Step 1: fold each active record onto one line; emit anchors verbatim.
    awk '
        BEGIN { buf = ""; have = 0 }
        function flushbuf() { if (have) { print buf; buf = ""; have = 0 } }
        /^[[:space:]]*-[[:space:]]+(crate|url|repo):[[:space:]]/ {
            flushbuf(); buf = $0; have = 1; next
        }
        have && /^[[:space:]]/ && $0 !~ /^[[:space:]]*#/ && $0 !~ /^[[:space:]]*$/ {
            buf = buf "\001" $0; next
        }
        { flushbuf(); print }
        END { flushbuf() }
    ' "$file" > "$folded"

    # Step 2: sort the folded record lines by their crate/url/repo value (the
    # text after the key, up to the first space or folded-newline \001).
    grep -E "$record" "$folded" |
        awk '{
            key = $0
            sub(/^[[:space:]]*-[[:space:]]+(crate|url|repo):[[:space:]]+/, "", key)
            sub(/[[:space:]\001].*/, "", key)
            print key "\t" $0
        }' | LC_ALL=C sort -t$'\t' -k1,1 | cut -f2- > "$sorted_records"

    # Step 3: drop the sorted records back into the slots records occupied
    # (anchors stay put), unfolding \001 back into newlines.
    awk -v sorted_file="$sorted_records" -v record="$record" '
        BEGIN {
            n = 0
            while ((getline line < sorted_file) > 0) sorted[++n] = line
            close(sorted_file)
            i = 0
        }
        $0 ~ record {
            line = sorted[++i]
            gsub(/\001/, "\n", line)
            print line
            next
        }
        { print }
    ' "$folded" > "$rewritten"

    if ! cmp -s "$file" "$rewritten"; then
        cat "$rewritten" > "$file"
        print_warn "Sorted $file"
    fi

    rm -f "$folded" "$sorted_records" "$rewritten"
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
        # Sort a YAML "packages:"/"extensions:" sequence in place by record key
        # (crate/url/repo). Commented-out records (disabled candidates) start
        # with '#' and stay verbatim at the bottom. Unlike the old fail-only
        # check, this auto-reorders multi-line records in place (see
        # sort_yaml_seq), matching the plain/brewfile modes.
        for file in "$@"; do
            sort_yaml_seq "$file"
        done
        ;;
    *)
        print_error "unknown mode: $mode"
        exit 2
        ;;
esac

exit 0
