#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 2 ]]; then
    echo "usage: $0 <plain|brewfile> <file>..." >&2
    exit 2
fi

mode=$1
shift

case "$mode" in
    plain)
        filter='^[[:space:]]*[^#[:space:]]'
        sort_args=("-k" "1")
        ;;
    brewfile)
        filter='^(tap|brew|cask) '
        sort_args=("-k" "1,1r" "-k" "2,2r")
        ;;
    *)
        echo "unknown mode: $mode" >&2
        exit 2
        ;;
esac

for file in "$@"; do
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
        echo "Sorted $file" >&2
    fi

    rm -f "$actual" "$sorted" "$rewritten"
done

exit 0
