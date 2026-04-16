# Shared utilities for dotfiles scripts.
# Source this file from install.sh and link.sh.

print_info()  { echo "[INFO] $1" >&1; }
print_warn()  { echo "[WARN] $1" >&2; }
print_error() { echo "[ERROR] $1" >&2; }

# Sets global OS variable to 'Mac', 'Linux', or 'Cygwin'.
# Exits with error if the platform is unsupported.
detect_os() {
    # shellcheck disable=SC2034  # OS is used by callers that source this file
    case "$(uname -s)" in
        Darwin)       OS='Mac'    ;;
        Linux*)       OS='Linux'  ;;
        MINGW32_NT*)  OS='Cygwin' ;;
        *)
            print_error "Your platform ($(uname -a)) is not supported."
            exit 1
            ;;
    esac
}

# Returns true if the given command exists on PATH.
need_cmd() { command -v "$1" >/dev/null 2>&1; }

# Print a message and exit 0 if the given command is already installed.
skip_if_installed() {
    if need_cmd "$1"; then
        print_info "$1 is already installed, skipping"
        exit 0
    fi
}

# Create a symlink in $BIN (force, so re-runs are safe).
# Usage: ensure_bin /path/to/binary
ensure_bin() {
    local src="$1"
    local bin_dir="${BIN:-$HOME/works/bin}"
    mkdir -p "$bin_dir"
    ln -sf "$src" "$bin_dir/"
    print_info "linked $(basename "$src") -> $bin_dir"
}

# Return the number of available CPU cores (cross-platform).
detect_nproc() {
    if need_cmd nproc; then
        nproc
    elif [ "$(uname)" = "Darwin" ]; then
        sysctl -n hw.ncpu
    else
        echo 4
    fi
}
