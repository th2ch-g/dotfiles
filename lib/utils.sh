# Shared utilities for dotfiles scripts.
# Source this file from install.sh and link.sh.

# ANSI colors for the log helpers below (gated per-call on TTY + NO_COLOR).
_LOG_GREEN=$'\033[32m'
_LOG_YELLOW=$'\033[33m'
_LOG_RED=$'\033[31m'
_LOG_RESET=$'\033[0m'
_LOG_DIM=$'\033[2m'
_LOG_BOLD=$'\033[1m'

# Print "<icon> <msg>" to the current stream, wrapping it in <color>...reset
# only when the target fd ($4) is a TTY and NO_COLOR is unset. This keeps
# piped/redirected output and NO_COLOR users on plain, un-escaped text.
_log() {
    local color="$1" icon="$2" msg="$3" fd="$4"
    if [ -z "${NO_COLOR:-}" ] && [ -t "$fd" ]; then
        printf '%s%s %s%s\n' "$color" "$icon" "$msg" "$_LOG_RESET"
    else
        printf '%s %s\n' "$icon" "$msg"
    fi
}

print_info() { _log "$_LOG_GREEN" '✔' "$1" 1; }
print_warn() { _log "$_LOG_YELLOW" '⚠' "$1" 2 >&2; }
print_error() { _log "$_LOG_RED" '✖' "$1" 2 >&2; }

# Progress marker for "currently working on <x>" lines inside loops.
# Dim, so it stays visually subordinate to the ✔/⚠/✖ result lines.
print_step() { _log "$_LOG_DIM" '▸' "$1" 1; }

# Section header: "── title ──────" padded to the terminal width (max 80).
# Bold/achromatic; degrades to a plain "-- title --" on non-TTY / NO_COLOR
# so piped logs stay greppable.
print_section() {
    local title="$1"
    if [ -z "${NO_COLOR:-}" ] && [ -t 1 ]; then
        local cols width line
        cols=$(tput cols 2> /dev/null || echo 80)
        [ "$cols" -gt 80 ] && cols=80
        width=$((cols - ${#title} - 4))
        [ "$width" -lt 0 ] && width=0
        line=$(printf '%*s' "$width" '')
        printf '%s── %s %s%s\n' "$_LOG_BOLD" "$title" "${line// /─}" "$_LOG_RESET"
    else
        printf -- '-- %s --\n' "$title"
    fi
}

# Sets global OS variable to 'Mac', 'Linux', or 'Cygwin'.
# Exits with error if the platform is unsupported.
detect_os() {
    # shellcheck disable=SC2034  # OS is used by callers that source this file
    case "$(uname -s)" in
        Darwin) OS='Mac' ;;
        Linux*) OS='Linux' ;;
        MINGW32_NT*) OS='Cygwin' ;;
        *)
            print_error "Your platform ($(uname -a)) is not supported."
            exit 1
            ;;
    esac
}

# Returns true if the given command exists on PATH.
need_cmd() { command -v "$1" > /dev/null 2>&1; }

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
