#!/bin/zsh
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
INSTALL_SCRIPTS="$WORKS/dotfiles/install_scripts"

# default setting
test_mode=0
no_cargo_pkgs=0

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
if [[ "$(uname)" == 'Darwin' ]]; then
  OS='Mac'
elif [[ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]]; then
  OS='Linux'
elif [[ "$(expr substr $(uname -s) 1 10)" == 'MINGW32_NT' ]]; then
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
if [[ ! -e $PWD/install.sh ]]; then
    print_error "install.sh is not detected"
    print_error "execute ./install.sh in dotfiles directory"
    exit 1
fi

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

# For mac
if [[ $OS == "Mac" ]]; then
    if [[ $test_mode -eq 1 ]]; then
        prepare_common_dirs
        for target in brew cargo pixi uv warpd;
        do
            install_script $target
        done
        run_local python3
        run_local macos --dockutil
        run_local iterm2
    else
        prepare_common_dirs
        for target in pixi uv brew claude-code cargo warpd;
        do
            install_script $target
        done
        run_local python3
        run_local brew
        run_local macos --dockutil
        run_local iterm2
        [ $no_cargo_pkgs -eq 0 ] && run_local cargo
    fi
fi

# For linux
if [[ $OS == "Linux" ]]; then
    if [[ $test_mode -eq 1 ]]; then
        prepare_common_dirs
        for target in vim nvim uv pixi cargo;
        # for target in uv pixi cargo;
        # for target in fzf vim nvim pixi uv imagemagick cargo node autoconf git gemini-cli password-store zsh tmux; # mold cmake;
        do
            install_script $target
        done
        run_local python3
        # [ $no_cargo_pkgs -eq 0 ] && run_local cargo
    else
        prepare_common_dirs
        for target in fzf vim nvim tmux pixi uv claude-code imagemagick cargo zsh;
        do
            install_script $target
        done
        run_local python3
        [ $no_cargo_pkgs -eq 0 ] && run_local cargo
    fi
fi

# For windows
if [[ $OS == "Cygwin" ]]; then
    print_warn "Cygwin is not supported"
    exit 1
fi

echo "[INFO] done" >&1
