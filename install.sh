#!/bin/bash
set -e

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
'

WORKS="$HOME/works"
MISC="$WORKS/misc"
TOOLS="$WORKS/tools"
OTHERS="$WORKS/others"
BIN="$WORKS/bin"
SHARE="$WORKS/share"
INSTALL_SCRIPTS="$WORKS/dotfiles/install_scripts"
XDG_CONFIG_HOME="$HOME/.config"

# default setting
test_mode=0

print_info() { echo "[INFO] $1" >&1;  }
print_warn() { echo "[WARN] $1" >&2;  }
print_error() { echo "[ERROR] $1" >&2;  }

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
if [ "$(uname)" == 'Darwin' ]; then
  OS='Mac'
elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
  OS='Linux'
elif [ "$(expr substr $(uname -s) 1 10)" == 'MINGW32_NT' ]; then
  OS='Cygwin'
else
  print_error "Your platform ($(uname -a)) is not supported."
  exit 1
fi
print_info "detect $OS OS"

# CPU check
arch=$(uname -m)
print_info "detect $arch CPU"

# cwd check
if [ ! -e $PWD/install.sh ]; then
    print_error "install.sh is not detected"
    print_error "execute ./install.sh in dotfiles directory"
    exit 1
fi

prepare_common_dirs() {
    arr=( $MISC $TOOLS $OTHERS $BIN $SHARE )
    for i in ${arr[@]};
    do
        mkdir -p $i
    done
}

prepare_local_rcs() {
    touch $XDG_CONFIG_HOME/zsh/.zshrc_local
    touch $XDG_CONFIG_HOME/zsh/.zshenv_local
}

install_script() {
    TARGET=$1
    CWD=$PWD
    cd $TOOLS
    $INSTALL_SCRIPTS/$TARGET.sh
    cd $CWD
}

install_brew_pkgs() {
    cd brew
    ./run.sh
    cd ..
}

install_cargo_pkgs() {
    cd cargo
    ./run.sh
    cd ..
}

apply_macos_settings() {
    cd macos
    ./run.sh --dockutil
    cd ..
}

apply_iterm2_settings() {
    cd iterm2
    ./run.sh
    cd ..
}

# For mac
if [ $OS == "Mac" ]; then
    if [ $test_mode -eq 1 ]; then
        prepare_common_dirs
        prepare_local_rcs
        for target in brew cargo;
        do
            install_script $target
            # install_${target}_pkgs
        done
        # apply_macos_settings
        # apply_iterm2_settings
    else
        prepare_common_dirs
        prepare_local_rcs
        for target in brew cargo;
        do
            install_script $target
            install_${target}_pkgs
        done
        apply_macos_settings
        apply_iterm2_settings
    fi
fi

# For linux
if [ $OS == "Linux" ]; then
    if [ $test_mode -eq 1 ]; then
        prepare_common_dirs
        prepare_local_rcs
        for target in fzf vim nvim tmux pixi uv imagemagick cargo;
        do
            install_script $target
        done
        # install_cargo_pkgs
    else
        prepare_common_dirs
        prepare_local_rcs
        for target in fzf vim nvim tmux pixi uv imagemagick cargo;
        do
            install_script $target
        done
        install_cargo_pkgs
    fi
fi

# For windows
if [ $OS == "Cygwin" ]; then
    print_warn "Cygwin is not supported"
    exit 1
fi

echo done
