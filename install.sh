#!/bin/zsh
set -e

# cwd check
if [[ ! -e $PWD/install.sh ]]; then
    echo "install.sh is not detected"
    echo "execute ./install.sh in dotfiles directory"
    exit 1
fi

DOTFILES_DIR=$PWD
export DOTFILES_DIR
source "$DOTFILES_DIR/lib/utils.sh"

USAGE='
install.sh:
    bootstrap installer

USAGE:
    ./install.sh [FLAGS]

EXAMPLE:
    ./install.sh
    ./install.sh --pixi --uv --python3
    ./install.sh --pixi --pixi-pkgs --cargo --cargo-pkgs

OPTIONS:
    -h, --help          print help
        --pixi          install pixi
        --pixi-pkgs     install pixi global packages
        --uv            install uv
        --brew          install Homebrew (Mac only)
        --brew-pkgs     install Homebrew packages (Mac only)
        --cargo         install Rust toolchain
        --cargo-pkgs    install cargo packages
        --warpd         install warpd (Mac only)
        --claude-code   install claude-code
        --codex         install codex
        --opencode      install opencode
        --password-store install password-store
        --python3       install python packages
        --gh-ext        install gh extensions
        --macos         configure macOS settings (Mac only)
        --iterm2        configure iTerm2 (Mac only)
'

: "${WORKS:=$HOME/works}"
: "${TOOLS:=$WORKS/tools}"
: "${MISC:=$WORKS/misc}"
: "${OTHERS:=$WORKS/others}"
: "${BIN:=$WORKS/bin}"
: "${SHARE:=$WORKS/share}"
: "${MNT:=$WORKS/mnt}"
export BIN
INSTALL_SCRIPTS="$DOTFILES_DIR/install_scripts"

# flags
do_pixi=0
do_pixi_pkgs=0
do_uv=0
do_brew=0
do_brew_pkgs=0
do_cargo=0
do_cargo_pkgs=0
do_warpd=0
do_claude_code=0
do_codex=0
do_opencode=0
do_python3=0
do_gh_ext=0
do_macos=0
do_iterm2=0
do_password_store=0

# option parser
while :; do
    case $1 in
        -h | --help)
            echo "$USAGE" >&1
            exit 0
            ;;
        --pixi)
            do_pixi=1
            ;;
        --pixi-pkgs)
            do_pixi_pkgs=1
            ;;
        --uv)
            do_uv=1
            ;;
        --brew)
            do_brew=1
            ;;
        --brew-pkgs)
            do_brew_pkgs=1
            ;;
        --cargo)
            do_cargo=1
            ;;
        --cargo-pkgs)
            do_cargo_pkgs=1
            ;;
        --warpd)
            do_warpd=1
            ;;
        --claude-code)
            do_claude_code=1
            ;;
        --codex)
            do_codex=1
            ;;
        --opencode)
            do_opencode=1
            ;;
        --python3)
            do_python3=1
            ;;
        --gh-ext)
            do_gh_ext=1
            ;;
        --macos)
            do_macos=1
            ;;
        --iterm2)
            do_iterm2=1
            ;;
        --password-store)
            do_password_store=1
            ;;
        --)
            shift
            break
            ;;
        -?*)
            print_error "Unknown option: $1"
            exit 1
            ;;
        *)
            break
            ;;
    esac
    shift
done

# OS check
detect_os
print_info "detect $OS OS"

# CPU check
arch=$(uname -m)
print_info "detect $arch CPU"

prepare_common_dirs() {
    arr=("$MISC" "$TOOLS" "$OTHERS" "$BIN" "$SHARE" "$MNT")
    for i in "${arr[@]}"; do
        mkdir -p "$i"
    done
}

install_script() {
    (cd "$TOOLS" && "$INSTALL_SCRIPTS/$1.sh")
}

run_local() {
    (cd "$1" && ./run.sh "${@:2}")
}

prepare_common_dirs

# pixi
[[ $do_pixi -eq 1 ]] && install_script pixi

# pixi global packages
[[ $do_pixi_pkgs -eq 1 ]] && run_local pixi

# uv
[[ $do_uv -eq 1 ]] && install_script uv

# brew (Mac only)
# NOTE: not `[[ Mac ]] && install || warn`: that would also run the warn (and
# swallow the failure) when the install itself fails on Mac.
if [[ $do_brew -eq 1 ]]; then
    if [[ $OS == "Mac" ]]; then
        install_script brew
    else
        print_warn "--brew is Mac only, skipping"
    fi
fi

# brew packages (Mac only)
if [[ $do_brew_pkgs -eq 1 ]]; then
    if [[ $OS == "Mac" ]]; then
        run_local brew
    else
        print_warn "--brew-pkgs is Mac only, skipping"
    fi
fi

# cargo / Rust toolchain
[[ $do_cargo -eq 1 ]] && install_script cargo

# cargo packages
[[ $do_cargo_pkgs -eq 1 ]] && run_local cargo

# warpd (Mac only)
if [[ $do_warpd -eq 1 ]]; then
    if [[ $OS == "Mac" ]]; then
        install_script warpd
    else
        print_warn "--warpd is Mac only, skipping"
    fi
fi

# claude-code
[[ $do_claude_code -eq 1 ]] && install_script claude-code

# codex
[[ $do_codex -eq 1 ]] && install_script codex

# opencode
[[ $do_opencode -eq 1 ]] && install_script opencode

# password-store
[[ $do_password_store -eq 1 ]] && install_script password-store

# python packages
[[ $do_python3 -eq 1 ]] && run_local python3

# gh extensions
[[ $do_gh_ext -eq 1 ]] && run_local gh-ext

# macOS settings (Mac only)
if [[ $do_macos -eq 1 ]]; then
    if [[ $OS == "Mac" ]]; then
        run_local macos --dockutil
    else
        print_warn "--macos is Mac only, skipping"
    fi
fi

# iterm2 (Mac only)
if [[ $do_iterm2 -eq 1 ]]; then
    if [[ $OS == "Mac" ]]; then
        run_local iterm2
    else
        print_warn "--iterm2 is Mac only, skipping"
    fi
fi

print_info "done"
