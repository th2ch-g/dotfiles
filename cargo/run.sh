#!/bin/bash
# Update the Rust toolchain and install every cargo package listed in list.yaml.
#
# list.yaml holds a `packages:` sequence keyed by `crate:` or `url:`; optional
# `bin:` / `feature:` refine the install command:
#   - crate: <name>                 -> cargo binstall <name>
#   - crate: <name> + feature: <f>  -> cargo binstall <name> --features <f>
#   - url: <git-url>                -> cargo install --git <url>
#   - url: <git-url> + bin: <pkg>   -> cargo install --git <url> <pkg>
#   - url: <git-url> + feature: <f> -> cargo install --git <url> --features <f>
# `bin:` and `feature:` may be combined (feature takes a comma-separated list).
# `desc:` fields, the `packages:` header and `#` comment lines (disabled
# candidates) are ignored. This is a minimal yq-free YAML reader so the cargo
# bootstrap stays self-contained; keep list.yaml to the flat two-space-indent
# schema above or the parser will silently skip records.
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

# Install the record accumulated in url/crate/bin, then reset for the next one.
# Called when a new "- crate:"/"- url:" line starts a record and once at EOF.
flush_record() {
    [[ -z "$url$crate" ]] && return
    # feature -> --features; expanded with the set-but-empty-safe idiom so an
    # absent feature adds no argument (and does not trip `set -u` on bash 3.2).
    local opts=()
    [[ -n "$feature" ]] && opts=(--features "$feature")
    if [[ -n "$url" ]]; then
        print_step "$url"
        if [[ -n "$bin" ]]; then
            cargo install --locked --force --git "$url" "$bin" ${opts[@]+"${opts[@]}"} ||
                failed+=("$url $bin")
        else
            cargo install --locked --force --git "$url" ${opts[@]+"${opts[@]}"} ||
                failed+=("$url")
        fi
    else
        print_step "$crate"
        cargo binstall -y --locked --force "$crate" ${opts[@]+"${opts[@]}"} ||
            failed+=("$crate")
    fi
    url="" crate="" bin="" feature=""
}

url="" crate="" bin="" feature=""
while IFS= read -r line; do
    # Skip comment lines (disabled candidates) and blank/whitespace-only lines.
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line//[[:space:]]/}" ]] && continue

    # A new "- crate:"/"- url:" line flushes the previous record; "bin:" and
    # "feature:" attach to the current one. The "packages:" header and "desc:"
    # lines match none of these and fall through (ignored).
    if [[ "$line" =~ ^[[:space:]]*-[[:space:]]+crate:[[:space:]]+([^[:space:]]+) ]]; then
        flush_record
        crate="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^[[:space:]]*-[[:space:]]+url:[[:space:]]+([^[:space:]]+) ]]; then
        flush_record
        url="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^[[:space:]]*bin:[[:space:]]+([^[:space:]]+) ]]; then
        bin="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^[[:space:]]*feature:[[:space:]]+([^[:space:]]+) ]]; then
        feature="${BASH_REMATCH[1]}"
    fi
done < list.yaml
flush_record

if ((${#failed[@]} > 0)); then
    print_error "cargo-install-list: ${#failed[@]} package(s) failed:"
    printf '  - %s\n' "${failed[@]}" >&2
    exit 1
fi

print_info "cargo-install-list done"
