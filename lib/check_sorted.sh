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

status=0

for file in "$@"; do
    actual=$(mktemp)
    expected=$(mktemp)

    if ! grep -E "$filter" "$file" > "$actual"; then
        : > "$actual"
    fi

    LC_ALL=C sort "${sort_args[@]}" "$actual" > "$expected"

    if ! diff -u "$expected" "$actual"; then
        echo "Please sort $file with the documented order." >&2
        status=1
    fi

    rm -f "$actual" "$expected"
done

exit "$status"
