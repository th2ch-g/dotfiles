#!/bin/zsh
set -e

# cwd check
if [[ ! -e $PWD/install.sh ]]; then
    echo "install.sh is not detected"
    echo "execute ./install.sh in dotfiles directory"
    exit 1
fi

DOTFILES_DIR=$PWD
source "$DOTFILES_DIR/lib/utils.sh"

USAGE='
install.sh:
    boosrap installer

USAGE:
    ./install.sh [FLAGS]

EXAMPLE:
    ./install.sh
    ./install.sh --test

OPTIONS:
    -h, --help              print help
        --test              test mode (do not install large packages)
    -n ,--no-cargo-pkgs     do not install cargo packages
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

# default setting
test_mode=0
no_cargo_pkgs=0

# option parser
while :;
do
    case $1 in
        -h | --help)
           echo "$USAGE" >&1
           exit 0
           ;;
        --test)
           test_mode=1
           ;;
        -n | --no-cargo-pkgs)
           no_cargo_pkgs=1
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
    arr=( $MISC $TOOLS $OTHERS $BIN $SHARE $MNT )
    for i in ${arr[@]};
    do
        mkdir -p $i
    done
}

install_script() {
    (cd "$TOOLS" && "$INSTALL_SCRIPTS/$1.sh")
}

run_local() {
    (cd "$1" && ./run.sh "${@:2}")
}

prepare_common_dirs

# For mac
if [[ $OS == "Mac" ]]; then
    if [[ $test_mode -eq 1 ]]; then
        for target in mise brew pixi warpd;
        do
            install_script $target
        done
        mise install
        run_local python3
        run_local macos --dockutil
        run_local iterm2
    else
        for target in mise pixi brew claude-code warpd;
        do
            install_script $target
        done
        [ $no_cargo_pkgs -eq 0 ] && mise install
        run_local python3
        run_local brew
        run_local macos --dockutil
        run_local iterm2
    fi
fi

# For linux
if [[ $OS == "Linux" ]]; then
    if [[ $test_mode -eq 1 ]]; then
        for target in mise vim pixi;
        do
            install_script $target
        done
        mise install
        run_local python3
    else
        for target in mise vim tmux pixi claude-code imagemagick zsh;
        do
            install_script $target
        done
        [ $no_cargo_pkgs -eq 0 ] && mise install
        run_local python3
    fi
fi

# For windows
if [[ $OS == "Cygwin" ]]; then
    print_warn "Cygwin is not supported"
    exit 1
fi

echo "[INFO] done" >&1
