#!/bin/bash
#
# setup.sh - interactive bootstrap for the th2ch-g/dotfiles repository.
#
# Remote (rustup-style one-liner):
#   curl -fsSL https://raw.githubusercontent.com/th2ch-g/dotfiles/main/setup.sh | bash
# Local (from a checkout):
#   ./setup.sh
#
# It prompts for how to fetch the repo (HTTPS clone / SSH clone / ZIP download),
# an install profile (full / standard / guest / customize), and optional
# developer setup (origin -> SSH, make setup), then delegates to link.sh and
# install.sh. Missing prerequisites (git / zsh / unzip) can be installed on the
# spot after a confirmation prompt.
#
# When run as `curl ... | bash`, the script text itself occupies stdin, so every
# interactive prompt is read from /dev/tty (the same trick rustup uses).
#
# Non-interactive use (CI / containers):
#   SETUP_PROFILE=full|standard|guest   choose the profile
#   SETUP_FETCH=https|ssh|zip           choose the fetch method (default https)
#   SETUP_DIR=/path                     install directory (default ~/works/dotfiles)
#
# This script is self-contained on purpose: during a `curl | bash` run the
# repository (and lib/utils.sh) does not exist yet, so it ships its own tiny
# logging / OS-detect helpers and only delegates to link.sh / install.sh once
# the repository is available.
#
set -e

REPO_SLUG="th2ch-g/dotfiles"
REPO_NAME="${REPO_SLUG##*/}"
BRANCH="main"
REPO_HTTPS="https://github.com/${REPO_SLUG}.git"
REPO_SSH="git@github.com:${REPO_SLUG}.git"
REPO_ZIP="https://github.com/${REPO_SLUG}/archive/refs/heads/${BRANCH}.zip"
CLONE_DEST="${SETUP_DIR:-${HOME}/works/dotfiles}"
TTY="/dev/tty"

# Selection state (populated as we go).
OS=""
NONINTERACTIVE=0
PROFILE=""
CLONE_PROTO="" # https | ssh | zip ; empty when an existing checkout is reused
REPO_DIR=""
DO_SETURL_SSH=0
DO_MAKE_SETUP=0
LINK_TOOLS=()
INSTALL_FLAGS=()
PM_CMD=()
PM_DISPLAY=""

# --- self-contained helpers (lib/utils.sh is not available pre-clone) ---

print_info() { printf '[INFO] %s\n' "$1"; }
print_warn() { printf '[WARN] %s\n' "$1" >&2; }
print_error() { printf '[ERROR] %s\n' "$1" >&2; }

need_cmd() { command -v "$1" > /dev/null 2>&1; }

detect_os() {
    case "$(uname -s)" in
        Darwin) OS="Mac" ;;
        Linux*) OS="Linux" ;;
        *)
            print_error "Unsupported platform: $(uname -s)"
            exit 1
            ;;
    esac
}

# Read a single line from the terminal into the named variable.
# Usage: prompt_read <var-name> <prompt-text>
prompt_read() {
    local __var="$1" __prompt="$2" __ans=""
    printf '%s' "$__prompt" > "$TTY"
    IFS= read -r __ans < "$TTY" || __ans=""
    printf -v "$__var" '%s' "$__ans"
}

# Yes/no prompt. Usage: ask_yn <prompt> <default:y|n> ; returns 0 for yes.
ask_yn() {
    local prompt="$1" def="$2" ans="" hint
    if [[ "$def" == "y" ]]; then
        hint="[Y/n]"
    else
        hint="[y/N]"
    fi
    while :; do
        prompt_read ans "  ${prompt} ${hint} "
        ans="${ans:-$def}"
        case "$ans" in
            [yY] | [yY][eE][sS]) return 0 ;;
            [nN] | [nN][oO]) return 1 ;;
            *) printf '  please answer y or n\n' > "$TTY" ;;
        esac
    done
}

# --- prerequisite installation ---

# Run a command as root: directly if already root, else via sudo.
run_root() {
    if [[ "$(id -u)" -eq 0 ]]; then
        "$@"
    elif need_cmd sudo; then
        sudo "$@"
    else
        print_error "root privileges required to run: $*"
        return 1
    fi
}

# Detect the platform package manager. Sets PM_CMD (install command, array) and
# PM_DISPLAY (human-readable). Returns non-zero when none is available.
detect_pm() {
    PM_CMD=()
    PM_DISPLAY=""
    if [[ "$OS" == "Mac" ]]; then
        PM_DISPLAY="xcode-select --install"
        return 0
    fi
    if need_cmd apt-get; then
        PM_CMD=(apt-get install -y)
    elif need_cmd dnf; then
        PM_CMD=(dnf install -y)
    elif need_cmd pacman; then
        PM_CMD=(pacman -S --noconfirm)
    elif need_cmd zypper; then
        PM_CMD=(zypper install -y)
    elif need_cmd apk; then
        PM_CMD=(apk add)
    else
        return 1
    fi
    PM_DISPLAY="${PM_CMD[*]}"
    return 0
}

# Install one package via the detected package manager. On macOS this triggers
# the Command Line Tools installer (which is an async GUI flow).
pm_install() {
    if [[ "$OS" == "Mac" ]]; then
        print_info "triggering Command Line Tools install: xcode-select --install"
        xcode-select --install 2> /dev/null || true
        if [[ "$NONINTERACTIVE" -eq 0 ]]; then
            local _ignore=""
            prompt_read _ignore "Press Enter once the Command Line Tools install finishes... "
        fi
        return 0
    fi
    if [[ "${PM_CMD[0]}" == "apt-get" ]]; then
        print_info "running: apt-get update"
        run_root apt-get update || true
    fi
    print_info "running: ${PM_DISPLAY} $*"
    run_root "${PM_CMD[@]}" "$@"
}

# Ensure <cmd> exists; offer to install <pkg> if missing. Exits on failure.
# Usage: ensure_tool <cmd> <pkg> <why>
ensure_tool() {
    local cmd="$1" pkg="$2" why="$3"
    need_cmd "$cmd" && return 0

    print_warn "${cmd} not found (${why})"
    if ! detect_pm; then
        print_error "no supported package manager found."
        print_error "install '${pkg}' manually, then re-run setup.sh"
        exit 1
    fi
    if [[ "$NONINTERACTIVE" -eq 0 ]]; then
        if ! ask_yn "install ${pkg} via '${PM_DISPLAY}'?" y; then
            print_error "install '${pkg}' manually, then re-run setup.sh"
            exit 1
        fi
    fi
    pm_install "$pkg"

    if ! need_cmd "$cmd"; then
        print_error "${cmd} is still missing; install '${pkg}' and re-run setup.sh"
        exit 1
    fi
}

ensure_zsh() { ensure_tool zsh zsh "install.sh runs under zsh"; }

# --- phases ---

validate_env() {
    if [[ -n "${SETUP_PROFILE:-}" ]]; then
        case "$SETUP_PROFILE" in
            full | standard | guest) ;;
            *)
                print_error "SETUP_PROFILE must be full|standard|guest (got: ${SETUP_PROFILE})"
                exit 1
                ;;
        esac
        NONINTERACTIVE=1
        return
    fi
    # Interactive run: make sure we can actually reach the terminal.
    if ! { exec 3< "$TTY"; } 2> /dev/null; then
        print_error "No interactive terminal (/dev/tty) available."
        print_error "Run ./setup.sh from a terminal, or set SETUP_PROFILE=full|standard|guest."
        exit 1
    fi
    exec 3<&-
}

choose_fetch_method() {
    if [[ "$NONINTERACTIVE" -eq 1 ]]; then
        case "${SETUP_FETCH:-https}" in
            https | ssh | zip) CLONE_PROTO="${SETUP_FETCH:-https}" ;;
            *)
                print_error "SETUP_FETCH must be https|ssh|zip (got: ${SETUP_FETCH})"
                exit 1
                ;;
        esac
        return
    fi
    local choice=""
    prompt_read choice "How to fetch dotfiles?  [1] HTTPS clone (default)  [2] SSH clone  [3] ZIP (no git) : "
    case "$choice" in
        2 | ssh | SSH) CLONE_PROTO="ssh" ;;
        3 | zip | ZIP) CLONE_PROTO="zip" ;;
        *) CLONE_PROTO="https" ;;
    esac
}

# Abort if the destination already holds non-checkout content.
guard_dest() {
    [[ -e "$CLONE_DEST" ]] || return 0
    [[ -d "$CLONE_DEST/.git" ]] && return 0
    if [[ -n "$(find "$CLONE_DEST" -mindepth 1 -maxdepth 1 -print -quit 2> /dev/null)" ]]; then
        print_error "destination exists and is not a dotfiles checkout: $CLONE_DEST"
        print_error "remove it or choose another directory (SETUP_DIR=...)"
        exit 1
    fi
}

# Download + extract the branch ZIP (the "without git" path from the README).
fetch_zip() {
    ensure_tool unzip unzip "to extract the ZIP archive"
    local dl=""
    if need_cmd curl; then
        dl="curl"
    elif need_cmd wget; then
        dl="wget"
    else
        ensure_tool curl curl "to download the ZIP archive"
        dl="curl"
    fi

    local tmpd=""
    tmpd="$(mktemp -d)"
    print_info "downloading ${REPO_ZIP}"
    if [[ "$dl" == "curl" ]]; then
        curl -fsSL -o "$tmpd/dotfiles.zip" "$REPO_ZIP"
    else
        wget -qO "$tmpd/dotfiles.zip" "$REPO_ZIP"
    fi
    unzip -q "$tmpd/dotfiles.zip" -d "$tmpd"
    # an empty pre-existing dir would make `mv` nest the source inside it
    [[ -d "$CLONE_DEST" ]] && rmdir "$CLONE_DEST"
    mv "$tmpd/${REPO_NAME}-${BRANCH}" "$CLONE_DEST"
    rm -rf "$tmpd"
    print_info "extracted to ${CLONE_DEST}"
}

fetch_repo() {
    guard_dest
    mkdir -p "$(dirname "$CLONE_DEST")"
    case "$CLONE_PROTO" in
        ssh)
            ensure_tool git git "to clone the repository"
            print_info "cloning ${REPO_SSH} -> ${CLONE_DEST}"
            git clone "$REPO_SSH" "$CLONE_DEST"
            ;;
        zip)
            fetch_zip
            ;;
        *)
            ensure_tool git git "to clone the repository"
            print_info "cloning ${REPO_HTTPS} -> ${CLONE_DEST}"
            git clone "$REPO_HTTPS" "$CLONE_DEST"
            ;;
    esac
}

# Decide which directory holds the repo: reuse a local checkout or fetch.
resolve_repo() {
    if [[ -f "$PWD/link.sh" && -f "$PWD/install.sh" && -f "$PWD/setup.sh" ]]; then
        REPO_DIR="$PWD"
        print_info "using current checkout: $REPO_DIR"
        return
    fi

    # Clone destination: default ~/works/dotfiles, overridable via the SETUP_DIR
    # env var or, in interactive runs, by typing a path at the prompt.
    if [[ "$NONINTERACTIVE" -eq 0 ]]; then
        local dest_in=""
        prompt_read dest_in "Install directory? [${CLONE_DEST}] : "
        if [[ -n "$dest_in" ]]; then
            # expand a leading ~ (read does not perform tilde expansion)
            if [[ "$dest_in" == \~ || "$dest_in" == \~/* ]]; then
                dest_in="${HOME}${dest_in#\~}"
            fi
            CLONE_DEST="$dest_in"
        fi
    fi

    if [[ -d "$CLONE_DEST/.git" ]]; then
        REPO_DIR="$CLONE_DEST"
        print_info "reusing existing clone: $REPO_DIR"
        return
    fi

    choose_fetch_method
    fetch_repo
    REPO_DIR="$CLONE_DEST"
}

choose_profile() {
    if [[ "$NONINTERACTIVE" -eq 1 ]]; then
        PROFILE="$SETUP_PROFILE"
        print_info "non-interactive profile: $PROFILE"
        return
    fi
    local ans=""
    {
        printf '\nSelect install profile:\n'
        printf '  1) full       everything for this machine\n'
        printf '  2) standard   core tools (pixi, uv, cargo, claude-code, ...)\n'
        printf '  3) guest      link-only (zsh, vim, tmux, nvim)\n'
        printf '  4) customize  toggle each component\n'
    } > "$TTY"
    prompt_read ans "> "
    case "$ans" in
        1 | full) PROFILE="full" ;;
        2 | standard) PROFILE="standard" ;;
        3 | guest) PROFILE="guest" ;;
        4 | customize) PROFILE="customize" ;;
        *)
            print_warn "invalid choice, defaulting to standard"
            PROFILE="standard"
            ;;
    esac
}

build_full() {
    LINK_TOOLS=(--zsh --git --tmux --vim --neovim --ssh --aerospace)
    if [[ "$OS" == "Mac" ]]; then
        INSTALL_FLAGS=(
            --pixi --pixi-pkgs --uv --cargo --cargo-pkgs
            --brew --brew-pkgs --warpd --claude-code --codex
            --python3 --gh-ext --iterm2 --macos
        )
    else
        INSTALL_FLAGS=(
            --pixi --pixi-pkgs --uv --cargo --cargo-pkgs
            --claude-code --codex --python3 --gh-ext
        )
    fi
    DO_SETURL_SSH=1
    DO_MAKE_SETUP=1
}

build_standard() {
    LINK_TOOLS=(--git --zsh --tmux --vim --neovim --ssh --aerospace)
    INSTALL_FLAGS=(--pixi --pixi-pkgs --uv --cargo --cargo-pkgs --claude-code --codex --python3)
    DO_SETURL_SSH=0
    DO_MAKE_SETUP=0
}

build_guest() {
    LINK_TOOLS=(--zsh --vim --tmux --neovim)
    INSTALL_FLAGS=()
    DO_SETURL_SSH=0
    DO_MAKE_SETUP=0
}

# Interactive per-component toggles. Defaults mirror the standard profile;
# Mac-only items are offered only on macOS.
customize() {
    {
        printf '\n-- link components --\n'
    } > "$TTY"
    if ask_yn "link zsh?" y; then LINK_TOOLS+=(--zsh); fi
    if ask_yn "link git?" y; then LINK_TOOLS+=(--git); fi
    if ask_yn "link tmux?" y; then LINK_TOOLS+=(--tmux); fi
    if ask_yn "link vim?" y; then LINK_TOOLS+=(--vim); fi
    if ask_yn "link neovim?" y; then LINK_TOOLS+=(--neovim); fi
    if ask_yn "link ssh config?" y; then LINK_TOOLS+=(--ssh); fi
    if ask_yn "link aerospace?" y; then LINK_TOOLS+=(--aerospace); fi
    if ask_yn "link alacritty?" n; then LINK_TOOLS+=(--alacritty); fi
    if [[ "$OS" == "Mac" ]]; then
        if ask_yn "link yabai?" n; then LINK_TOOLS+=(--yabai); fi
        if ask_yn "link skhd?" n; then LINK_TOOLS+=(--skhd); fi
    fi
    if ask_yn "link gemini?" n; then LINK_TOOLS+=(--gemini); fi
    if ask_yn "link codex?" n; then LINK_TOOLS+=(--codex); fi
    if ask_yn "link claude?" n; then LINK_TOOLS+=(--claude); fi
    if ask_yn "link bash profile? (not recommended)" n; then LINK_TOOLS+=(--bash); fi

    {
        printf '\n-- install components --\n'
    } > "$TTY"
    if ask_yn "install pixi + global pkgs?" y; then INSTALL_FLAGS+=(--pixi --pixi-pkgs); fi
    if ask_yn "install uv?" y; then INSTALL_FLAGS+=(--uv); fi
    if ask_yn "install cargo + pkgs?" y; then INSTALL_FLAGS+=(--cargo --cargo-pkgs); fi
    if ask_yn "install claude-code?" y; then INSTALL_FLAGS+=(--claude-code); fi
    if ask_yn "install codex?" y; then INSTALL_FLAGS+=(--codex); fi
    if ask_yn "install python pkgs?" y; then INSTALL_FLAGS+=(--python3); fi
    if ask_yn "install gh extensions?" y; then INSTALL_FLAGS+=(--gh-ext); fi
    if [[ "$OS" == "Mac" ]]; then
        if ask_yn "install Homebrew + pkgs?" y; then INSTALL_FLAGS+=(--brew --brew-pkgs); fi
        if ask_yn "install warpd?" n; then INSTALL_FLAGS+=(--warpd); fi
        if ask_yn "configure iTerm2?" n; then INSTALL_FLAGS+=(--iterm2); fi
        if ask_yn "configure macOS defaults?" n; then INSTALL_FLAGS+=(--macos); fi
    fi
    if ask_yn "install conda?" n; then INSTALL_FLAGS+=(--conda); fi
    if ask_yn "install gemini-cli?" n; then INSTALL_FLAGS+=(--gemini-cli); fi
    if ask_yn "install mold?" n; then INSTALL_FLAGS+=(--mold); fi
    if ask_yn "install password-store?" n; then INSTALL_FLAGS+=(--password-store); fi
    if ask_yn "install supertuxkart?" n; then INSTALL_FLAGS+=(--supertuxkart); fi
}

build_selection() {
    case "$PROFILE" in
        full) build_full ;;
        standard) build_standard ;;
        guest) build_guest ;;
        customize) customize ;;
    esac
}

# Optional developer setup. Only meaningful for git checkouts (ZIP has no .git).
choose_dev_steps() {
    if [[ ! -d "$REPO_DIR/.git" ]]; then
        DO_SETURL_SSH=0
        DO_MAKE_SETUP=0
        return
    fi
    if [[ "$NONINTERACTIVE" -eq 1 ]]; then
        return
    fi
    local d1 d2
    if [[ "$DO_SETURL_SSH" -eq 1 ]]; then d1="y"; else d1="n"; fi
    if [[ "$DO_MAKE_SETUP" -eq 1 ]]; then d2="y"; else d2="n"; fi
    {
        printf '\n-- developer setup --\n'
    } > "$TTY"
    if ask_yn "set git origin to SSH (for committing)?" "$d1"; then
        DO_SETURL_SSH=1
    else
        DO_SETURL_SSH=0
    fi
    if ask_yn "run 'make setup' (pre-commit hooks)?" "$d2"; then
        DO_MAKE_SETUP=1
    else
        DO_MAKE_SETUP=0
    fi
}

# Execute link.sh / install.sh. When tools are installed, vim/neovim links are
# deferred until after install.sh, because link.sh runs their plugin sync
# (vim JetpackSync, nvim Lazy update) at link time and needs the binaries.
run_steps() {
    cd "$REPO_DIR"

    local pre=() post=() t
    if [[ "${#INSTALL_FLAGS[@]}" -gt 0 ]]; then
        for t in "${LINK_TOOLS[@]}"; do
            case "$t" in
                --vim | --neovim) post+=("$t") ;;
                *) pre+=("$t") ;;
            esac
        done
    elif [[ "${#LINK_TOOLS[@]}" -gt 0 ]]; then
        pre=("${LINK_TOOLS[@]}")
    fi

    if [[ "${#pre[@]}" -gt 0 ]]; then
        print_info "link: ${pre[*]}"
        ./link.sh "${pre[@]}"
    fi
    if [[ "${#INSTALL_FLAGS[@]}" -gt 0 ]]; then
        print_info "install: ${INSTALL_FLAGS[*]}"
        ./install.sh "${INSTALL_FLAGS[@]}"
    fi
    if [[ "${#post[@]}" -gt 0 ]]; then
        print_info "link: ${post[*]}"
        ./link.sh "${post[@]}"
    fi

    # Switch origin to SSH for committing (git checkouts only).
    if [[ "$DO_SETURL_SSH" -eq 1 && -d ".git" ]]; then
        print_info "git remote set-url origin ${REPO_SSH}"
        git remote set-url origin "$REPO_SSH"
    fi
    if [[ "$DO_MAKE_SETUP" -eq 1 && -d ".git" ]]; then
        if need_cmd make; then
            print_info "make setup"
            make setup
        else
            print_warn "make not found, skipping 'make setup'"
        fi
    fi
}

confirm_and_run() {
    if [[ "${#LINK_TOOLS[@]}" -eq 0 && "${#INSTALL_FLAGS[@]}" -eq 0 ]]; then
        print_warn "nothing selected, exiting"
        exit 0
    fi

    printf '\n=== planned actions (repo: %s, profile: %s) ===\n' "$REPO_DIR" "$PROFILE"
    [[ "${#LINK_TOOLS[@]}" -gt 0 ]] && printf '  link    : ./link.sh %s\n' "${LINK_TOOLS[*]}"
    [[ "${#INSTALL_FLAGS[@]}" -gt 0 ]] && printf '  install : ./install.sh %s\n' "${INSTALL_FLAGS[*]}"
    [[ "$DO_SETURL_SSH" -eq 1 ]] && printf '  remote  : git remote set-url origin (ssh)\n'
    [[ "$DO_MAKE_SETUP" -eq 1 ]] && printf '  hooks   : make setup\n'
    printf '\n'

    if [[ "$NONINTERACTIVE" -eq 0 ]]; then
        if ! ask_yn "proceed?" y; then
            print_info "aborted"
            exit 0
        fi
    fi
    run_steps
    print_info "done"
}

main() {
    detect_os
    print_info "detected ${OS} ($(uname -m))"
    validate_env
    resolve_repo
    choose_profile
    build_selection
    if [[ "${#INSTALL_FLAGS[@]}" -gt 0 ]]; then
        ensure_zsh
    fi
    choose_dev_steps
    confirm_and_run
}

main "$@"
