#!/usr/bin/env bash
# Bootstrap this dotfiles repository with mise.
set -euo pipefail

readonly REPO_SLUG="th2ch-g/dotfiles"
readonly REPO_HTTPS="https://github.com/${REPO_SLUG}.git"
readonly REPO_SSH="git@github.com:${REPO_SLUG}.git"
readonly REPO_ZIP="https://github.com/${REPO_SLUG}/archive/refs/heads/main.zip"
readonly MISE_MIN_VERSION="2026.8.3"

PROFILE="${SETUP_PROFILE:-standard}"
FETCH="${SETUP_FETCH:-https}"
DEST="${SETUP_DIR:-${HOME}/works/dotfiles}"
ASSUME_YES=0
REPO_DIR=""
MISE_BIN=""

usage() {
    cat << 'EOF'
Usage: ./setup.sh [options]

Options:
  --profile standard|full|guest|hpc  Bootstrap profile (default: standard)
  --fetch https|ssh|zip              Fetch method (default: https)
  --dir PATH                         Checkout path (default: ~/works/dotfiles)
  -y, --yes                          Accept mise confirmation prompts
  -h, --help                         Show this help

Environment variables: SETUP_PROFILE, SETUP_FETCH, SETUP_DIR
EOF
}

die() {
    printf 'error: %s\n' "$*" >&2
    exit 1
}

has_cmd() {
    command -v "$1" > /dev/null 2>&1
}

expand_home() {
    local tilde="~"
    case "$1" in
        "$tilde") printf '%s\n' "$HOME" ;;
        "$tilde/"*) printf '%s/%s\n' "$HOME" "${1#~/}" ;;
        *) printf '%s\n' "$1" ;;
    esac
}

parse_args() {
    while (($#)); do
        case "$1" in
            --profile)
                (($# >= 2)) || die "--profile requires a value"
                PROFILE="$2"
                shift 2
                ;;
            --profile=*)
                PROFILE="${1#*=}"
                shift
                ;;
            --fetch)
                (($# >= 2)) || die "--fetch requires a value"
                FETCH="$2"
                shift 2
                ;;
            --fetch=*)
                FETCH="${1#*=}"
                shift
                ;;
            --dir)
                (($# >= 2)) || die "--dir requires a value"
                DEST="$(expand_home "$2")"
                shift 2
                ;;
            --dir=*)
                DEST="$(expand_home "${1#*=}")"
                shift
                ;;
            -y | --yes)
                ASSUME_YES=1
                shift
                ;;
            -h | --help)
                usage
                exit 0
                ;;
            --)
                shift
                break
                ;;
            *) die "unknown option: $1" ;;
        esac
    done
}

validate_platform() {
    case "$PROFILE" in
        standard | full | guest | hpc) ;;
        *) die "profile must be standard, full, guest, or hpc" ;;
    esac
    case "$FETCH" in
        https | ssh | zip) ;;
        *) die "fetch must be https, ssh, or zip" ;;
    esac

    local os arch
    os="$(uname -s)"
    arch="$(uname -m)"
    case "$os:$arch" in
        Darwin:arm64 | Linux:x86_64 | Linux:aarch64 | Linux:arm64) ;;
        Darwin:*) die "Intel macOS is not supported" ;;
        *) die "unsupported platform: ${os} ${arch}" ;;
    esac
    [[ "$PROFILE" != "hpc" || "$os" == "Linux" ]] || die "hpc is Linux only"
}

install_prerequisite() {
    local package="$1"
    [[ "$PROFILE" != "hpc" ]] || die "install '${package}' without root, then retry"
    if [[ "$(uname -s)" == "Darwin" ]]; then
        xcode-select --install 2> /dev/null || true
        die "finish the Command Line Tools installation, then retry"
    fi

    local root=()
    if [[ "$(id -u)" -ne 0 ]]; then
        has_cmd sudo || die "sudo is required to install '${package}'"
        root=(sudo)
    fi
    if has_cmd apt-get; then
        "${root[@]}" apt-get update
        "${root[@]}" apt-get install -y "$package"
    elif has_cmd dnf; then
        "${root[@]}" dnf install -y "$package"
    elif has_cmd pacman; then
        "${root[@]}" pacman -S --noconfirm "$package"
    elif has_cmd apk; then
        "${root[@]}" apk add "$package"
    else
        die "install '${package}' manually, then retry"
    fi
}

ensure_command() {
    local command="$1" package="$2"
    has_cmd "$command" || install_prerequisite "$package"
    has_cmd "$command" || die "${command} is still unavailable"
}

fetch_repo() {
    if [[ -f "$PWD/setup.sh" && -f "$PWD/mise/config.toml" ]]; then
        REPO_DIR="$PWD"
        return
    fi
    if [[ -f "$DEST/setup.sh" && -f "$DEST/mise/config.toml" ]]; then
        REPO_DIR="$DEST"
        return
    fi
    [[ ! -e "$DEST" ]] || die "destination exists but is not a mise dotfiles checkout: ${DEST}"
    mkdir -p "$(dirname "$DEST")"

    case "$FETCH" in
        https)
            ensure_command git git
            git clone "$REPO_HTTPS" "$DEST"
            ;;
        ssh)
            ensure_command git git
            git clone "$REPO_SSH" "$DEST"
            ;;
        zip)
            ensure_command curl curl
            ensure_command unzip unzip
            local temp_dir
            temp_dir="$(mktemp -d)"
            trap 'rm -rf "$temp_dir"' RETURN
            curl -fsSL "$REPO_ZIP" -o "$temp_dir/dotfiles.zip"
            unzip -q "$temp_dir/dotfiles.zip" -d "$temp_dir"
            mv "$temp_dir/dotfiles-main" "$DEST"
            trap - RETURN
            rm -rf "$temp_dir"
            ;;
    esac
    REPO_DIR="$DEST"
}

version_at_least() {
    local current="$1" required="$2" i
    local current_parts required_parts
    IFS=. read -r -a current_parts <<< "$current"
    IFS=. read -r -a required_parts <<< "$required"
    for i in 0 1 2; do
        if ((10#${current_parts[$i]:-0} > 10#${required_parts[$i]:-0})); then
            return 0
        elif ((10#${current_parts[$i]:-0} < 10#${required_parts[$i]:-0})); then
            return 1
        fi
    done
    return 0
}

ensure_mise() {
    local current=""
    if has_cmd mise; then
        current="$(mise --version | awk '{print $1}')"
        if version_at_least "$current" "$MISE_MIN_VERSION"; then
            MISE_BIN="$(command -v mise)"
            return
        fi
    fi

    ensure_command curl curl
    mkdir -p "$HOME/.local/bin"
    curl -fsSL https://mise.run |
        MISE_INSTALL_PATH="$HOME/.local/bin/mise" MISE_VERSION="v${MISE_MIN_VERSION}" sh
    MISE_BIN="$HOME/.local/bin/mise"
    [[ -x "$MISE_BIN" ]] || die "mise installation failed"
}

write_local_config() {
    local environments escaped_dir
    case "$PROFILE" in
        standard) environments='["standard"]' ;;
        full) environments='["standard", "full"]' ;;
        guest) environments='["guest"]' ;;
        hpc) environments='["standard", "hpc"]' ;;
    esac
    escaped_dir="${REPO_DIR//\\/\\\\}"
    escaped_dir="${escaped_dir//\"/\\\"}"
    printf 'auto_env = true\nenv = %s\n' "$environments" > "$REPO_DIR/mise/miserc.toml"
    printf '[env]\nDOTFILES_DIR = "%s"\n' "$escaped_dir" > "$REPO_DIR/mise/config.local.toml"
}

run_bootstrap() {
    local environment skip_args=() yes_args=()
    case "$PROFILE" in
        standard) environment="standard" ;;
        full) environment="standard,full" ;;
        guest)
            environment="guest"
            skip_args=(--skip "packages,macos-defaults,user,tools")
            ;;
        hpc)
            environment="standard,hpc"
            skip_args=(--skip "packages,macos-defaults,user")
            ;;
    esac
    ((ASSUME_YES == 0)) || yes_args=(--yes)

    MISE_ENV="$environment" MISE_AUTO_ENV=true DOTFILES_DIR="$REPO_DIR" \
        "$MISE_BIN" trust --all --yes --cd "$REPO_DIR"
    MISE_ENV="$environment" MISE_AUTO_ENV=true DOTFILES_DIR="$REPO_DIR" \
        "$MISE_BIN" bootstrap --cd "$REPO_DIR" "${yes_args[@]}" "${skip_args[@]}"
}

main() {
    parse_args "$@"
    DEST="$(expand_home "$DEST")"
    validate_platform
    fetch_repo
    ensure_mise
    write_local_config
    run_bootstrap
    printf 'bootstrap complete: profile=%s repo=%s\n' "$PROFILE" "$REPO_DIR"
}

main "$@"
