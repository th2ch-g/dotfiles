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

# Move package lines that crossed the active/commented boundary back to their
# block: a freshly re-enabled entry left in the commented block goes up to the
# end of the active block, and a freshly disabled entry left in the active
# block goes down to the top of the commented block. Whichever side has fewer
# strays moves, so a single toggled entry travels instead of the whole other
# block. Non-package lines (e.g. the "# run: brew bundle dump" header) keep
# their positions; the subsequent sort_block calls put moved lines in order.
fix_boundary() {
    local file=$1 active=$2 commented=$3
    local rewritten
    rewritten=$(mktemp)

    awk -v act="$active" -v com="$commented" '
        { lines[NR] = $0 }
        END {
            fc = 0; la = 0
            for (i = 1; i <= NR; i++) {
                if (!fc && lines[i] ~ com) fc = i
                if (lines[i] ~ act) la = i
            }
            if (!fc || la < fc) {
                for (i = 1; i <= NR; i++) print lines[i]
                exit
            }
            ma = 0; mc = 0
            for (i = fc + 1; i <= NR; i++) if (lines[i] ~ act) ma++
            for (i = 1; i < la; i++) if (lines[i] ~ com) mc++
            ns = 0
            if (ma <= mc) {
                # strays: active lines below the first commented one; move up
                # to just after the last active line above it
                anchor = 0
                for (i = 1; i < fc; i++) if (lines[i] ~ act) anchor = i
                for (i = fc + 1; i <= NR; i++)
                    if (lines[i] ~ act) { stray[++ns] = lines[i]; skip[i] = 1 }
                for (i = 1; i <= NR; i++) {
                    if (anchor == 0 && i == fc)
                        for (j = 1; j <= ns; j++) print stray[j]
                    if (!(i in skip)) print lines[i]
                    if (i == anchor)
                        for (j = 1; j <= ns; j++) print stray[j]
                }
            } else {
                # strays: commented lines above the last active one; move down
                # to just before the first commented line below it
                anchor = 0
                for (i = NR; i > la; i--) if (lines[i] ~ com) anchor = i
                for (i = 1; i < la; i++)
                    if (lines[i] ~ com) { stray[++ns] = lines[i]; skip[i] = 1 }
                for (i = 1; i <= NR; i++) {
                    if (i == anchor)
                        for (j = 1; j <= ns; j++) print stray[j]
                    if (!(i in skip)) print lines[i]
                    if (anchor == 0 && i == la)
                        for (j = 1; j <= ns; j++) print stray[j]
                }
            }
        }
    ' "$file" > "$rewritten"

    if ! cmp -s "$file" "$rewritten"; then
        cat "$rewritten" > "$file"
        print_warn "Moved boundary-crossing entries in $file"
    fi

    rm -f "$rewritten"
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
        # packages must sit below every active one. Entries that crossed the
        # boundary (a freshly re-enabled or freshly disabled package left in
        # place) are moved back to their block first, then each block is
        # sorted.
        active='^(tap|brew|cask) '
        commented='^# (tap|brew|cask) '
        for file in "$@"; do
            fix_boundary "$file" "$active" "$commented"
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
