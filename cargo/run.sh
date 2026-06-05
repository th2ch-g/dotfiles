#!/bin/bash
# Update the Rust toolchain and install every cargo package listed in list.txt.
#
# Each non-comment line in list.txt is one of:
#   <crate>             -> installed with `cargo binstall`
#   <git-url>           -> `cargo install --git <url>`
#   <git-url> <crate>   -> `cargo install --git <url> <crate>`
# Trailing `# ...` descriptions, blank lines and `#` comment lines are ignored.
#
# Failures are collected instead of aborting the loop: every package is
# attempted, and the script exits non-zero with a summary if any failed.

set -uo pipefail

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

rustup self update
rustup update

# cargo-binstall is required for the plain-crate lines below.
cargo install --locked cargo-binstall

failed=()

while IFS= read -r line; do
    # Skip comment lines and blank/whitespace-only lines.
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line//[[:space:]]/}" ]] && continue

    # Split into the first token (crate or git URL) and an optional spec;
    # the trailing `# ...` description, if any, is discarded into `_`.
    read -r target spec _ <<< "$line"
    echo "+ $target"

    if [[ "$target" == https://* ]]; then
        if [[ -z "$spec" || "$spec" == \#* ]]; then
            cargo install --locked --force --git "$target" ||
                failed+=("$target")
        else
            cargo install --locked --force --git "$target" "$spec" ||
                failed+=("$target $spec")
        fi
    else
        cargo binstall -y --locked --force "$target" ||
            failed+=("$target")
    fi
done < list.txt

if ((${#failed[@]} > 0)); then
    print_error "cargo-install-list: ${#failed[@]} package(s) failed:"
    printf '  - %s\n' "${failed[@]}" >&2
    exit 1
fi

print_info "cargo-install-list done"
