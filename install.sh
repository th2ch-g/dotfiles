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
    ./install.sh --vim --nvim --cargo --python3

OPTIONS:
    -h, --help          print help
        --pixi          install pixi
        --uv            install uv
        --brew          install Homebrew (Mac only)
        --brew-pkgs     install Homebrew packages (Mac only)
        --cargo         install Rust toolchain
        --cargo-pkgs    install cargo packages
        --warpd         install warpd (Mac only)
        --claude-code   install claude-code
        --fzf           install fzf
        --vim           install vim
        --nvim          install neovim
        --tmux          install tmux
        --imagemagick   install imagemagick
        --zsh           install zsh
        --node          install Node.js
        --conda         install conda
        --gemini-cli    install gemini-cli
        --git           install git
        --autoconf      install autoconf
        --cmake         install cmake
        --mold          install mold
        --less          install less
        --password-store install password-store
        --supertuxkart  install supertuxkart
        --python3       install python packages
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
do_uv=0
do_brew=0
do_brew_pkgs=0
do_cargo=0
do_cargo_pkgs=0
do_warpd=0
do_claude_code=0
do_fzf=0
do_vim=0
do_nvim=0
do_tmux=0
do_imagemagick=0
do_zsh=0
do_python3=0
do_macos=0
do_iterm2=0
do_node=0
do_conda=0
do_gemini_cli=0
do_git=0
do_autoconf=0
do_cmake=0
do_mold=0
do_less=0
do_password_store=0
do_supertuxkart=0

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
        --fzf)
            do_fzf=1
            ;;
        --vim)
            do_vim=1
            ;;
        --nvim)
            do_nvim=1
            ;;
        --tmux)
            do_tmux=1
            ;;
        --imagemagick)
            do_imagemagick=1
            ;;
        --zsh)
            do_zsh=1
            ;;
        --python3)
            do_python3=1
            ;;
        --macos)
            do_macos=1
            ;;
        --iterm2)
            do_iterm2=1
            ;;
        --node)
            do_node=1
            ;;
        --conda)
            do_conda=1
            ;;
        --gemini-cli)
            do_gemini_cli=1
            ;;
        --git)
            do_git=1
            ;;
        --autoconf)
            do_autoconf=1
            ;;
        --cmake)
            do_cmake=1
            ;;
        --mold)
            do_mold=1
            ;;
        --less)
            do_less=1
            ;;
        --password-store)
            do_password_store=1
            ;;
        --supertuxkart)
            do_supertuxkart=1
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

# uv
[[ $do_uv -eq 1 ]] && install_script uv

# brew (Mac only)
if [[ $do_brew -eq 1 ]]; then
    [[ $OS == "Mac" ]] && install_script brew || print_warn "--brew is Mac only, skipping"
fi

# brew packages (Mac only)
if [[ $do_brew_pkgs -eq 1 ]]; then
    [[ $OS == "Mac" ]] && run_local brew || print_warn "--brew-pkgs is Mac only, skipping"
fi

# cargo / Rust toolchain
[[ $do_cargo -eq 1 ]] && install_script cargo

# cargo packages
[[ $do_cargo_pkgs -eq 1 ]] && run_local cargo

# warpd (Mac only)
if [[ $do_warpd -eq 1 ]]; then
    [[ $OS == "Mac" ]] && install_script warpd || print_warn "--warpd is Mac only, skipping"
fi

# claude-code
[[ $do_claude_code -eq 1 ]] && install_script claude-code

# fzf
[[ $do_fzf -eq 1 ]] && install_script fzf

# vim
[[ $do_vim -eq 1 ]] && install_script vim

# nvim
[[ $do_nvim -eq 1 ]] && install_script nvim

# tmux
[[ $do_tmux -eq 1 ]] && install_script tmux

# imagemagick
[[ $do_imagemagick -eq 1 ]] && install_script imagemagick

# zsh
[[ $do_zsh -eq 1 ]] && install_script zsh

# node
[[ $do_node -eq 1 ]] && install_script node

# conda
[[ $do_conda -eq 1 ]] && install_script conda

# gemini-cli
[[ $do_gemini_cli -eq 1 ]] && install_script gemini-cli

# git
[[ $do_git -eq 1 ]] && install_script git

# autoconf
[[ $do_autoconf -eq 1 ]] && install_script autoconf

# cmake
[[ $do_cmake -eq 1 ]] && install_script cmake

# mold
[[ $do_mold -eq 1 ]] && install_script mold

# less
[[ $do_less -eq 1 ]] && install_script less

# password-store
[[ $do_password_store -eq 1 ]] && install_script password-store

# supertuxkart
[[ $do_supertuxkart -eq 1 ]] && install_script supertuxkart

# python packages
[[ $do_python3 -eq 1 ]] && run_local python3

# macOS settings (Mac only)
if [[ $do_macos -eq 1 ]]; then
    [[ $OS == "Mac" ]] && run_local macos --dockutil || print_warn "--macos is Mac only, skipping"
fi

# iterm2 (Mac only)
if [[ $do_iterm2 -eq 1 ]]; then
    [[ $OS == "Mac" ]] && run_local iterm2 || print_warn "--iterm2 is Mac only, skipping"
fi

echo "[INFO] done" >&1
