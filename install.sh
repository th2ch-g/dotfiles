#!/bin/bash
set -e

USAGE='
install.sh:
    dotfiles linker

USAGE:
    ./install.sh [FLAGS]

EXAMPLE:
    ./install.sh                            only OS check
    ./install.sh --vim --zsh --tmux --git   OS check & dotfiles link
    ./install.sh -b -c -v -z -t -g -m       recommended options

OPTIONS:
    -h, --help              print help
    -u, --unlink            all dotfiles unlink
    -b, --brew              brew install
    -c, --cargo             cargo install
    -p, --python            python install
    -v, --vim               only vim dotfiles link
    -z, --zsh               only zsh dotfiles link
    -t, --tmux              only tmux dotfiles link
    -g, --git               only git dotfiles link
    -a, --alacritty         only alacritty dotfiles link
    -n, --neovim            only neovim dotfiles link
'

# default setting
unlink_flag=1
brew_flag=1
cargo_flag=1
python_flag=1
vim_flag=1
zsh_flag=1
tmux_flag=1
git_flag=1
alacritty_flag=1
neovim_flag=1

print_info() { echo "[INFO] $1" >&1;  }
print_warn() { echo "[WARN] $1" >&2;  }
print_error() { echo "[ERROR] $1" >&2;  }
create_link() {
    local src=$1
    local dest=$2
    ln -nsi "$src" "$dest" && print_info "Linked $(basename "$dest")"
}
remove_link() {
    local target=$1
    if [ -L "$target" ]; then
        unlink "$target" && print_info "Unlinked $(basename "$target")"
    fi
}

# option parser
while :;
do
    case $1 in
        -h | --help)
            echo "$USAGE" >&1
            exit 0
            ;;
        -u | --unlink)
            unlink_flag=0
            break
            ;;
        -b | --brew)
            brew_flag=0
            ;;
        -c | --cargo)
            cargo_flag=0
            ;;
        -p | --python)
            python_flag=0
            ;;
        -v | --vim)
            vim_flag=0
            ;;
        -z | --zsh)
            zsh_flag=0
            ;;
        -t | --tmux)
            tmux_flag=0
            ;;
        -g | --git)
            git_flag=0
            ;;
        -a | --alacritty)
            alacritty_flag=0
            ;;
        -n | --neovim)
            neovim_flag=0
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

if [ ! -d ${HOME}/.config ]; then
    mkdir -p ${HOME}/.config
fi

if [ $unlink_flag -eq 0 ]; then
    print_info "Start unlink dotfiles"
    set +e
    print_warn "Ignore error"

    # vim
    for dotfile in .vim .vimrc;
    do
        if [ -L $HOME/$dotfile ]; then
            unlink $HOME/$dotfile && echo "[INFO] $dotfile unlink done" >&1
        fi
    done

    for target in git zsh tmux alacritty;
    do
        remove_link ${HOME}/.config/$target
    done
    remove_link ${HOME}/.zshenv

    print_info "dotfiles unlink done"
    set -e
fi

# vim link
if [ $vim_flag -eq 0 ]; then
    print_info "vim install start"
    # vim does not support config dir
    for dotfile in .vim .vimrc;
    do
        create_link ${PWD}/vim/$dotfile ${HOME}/$dotfile
    done
    if command -v vim >/dev/null 2>&1; then
        set +e
        vim -e -c "PlugInstall" -c "qa"
        set -e
    fi
    print_info "vim install done"
fi

# zsh link
if [ $zsh_flag -eq 0 ]; then
    print_info "zsh install start"
    create_link ${PWD}/zsh ${HOME}/.config/zsh
    create_link ${PWD}/zsh/.zshenv ${HOME}/.zshenv
    print_info "zsh install done"
fi

# tmux link
if [ $tmux_flag -eq 0 ]; then
    print_info "tmux install start"
    create_link ${PWD}/tmux ${HOME}/.config/tmux
    print_info "tmux install done"
fi

# git link
if [ $git_flag -eq 0 ]; then
    print_info "git install start"
    create_link ${PWD}/git ${HOME}/.config/git
    print_info "git install done"
fi

# alacritty link
if [ $alacritty_flag -eq 0 ]; then
    print_info "alacritty install start"
    create_link $PWD/alacritty/ ${HOME}/.config/alacritty
    print_info "alacritty install done"
fi

# neovim link
if [ $neovim_flag -eq 0 ]; then
    print_info "neovim install start"
    create_link $PWD/nvim/ ${HOME}/.config/nvim
    if command -v nvim >/dev/null 2>&1; then
        set +e
        nvim -e -c "PlugInstall" -c "qa"
        set -e
    fi
    print_info "neovim install done"
fi

# brew install
if [ $OS == "Mac" ] && [ $brew_flag -eq 0 ]; then
    print_info "brew install start"
    if command -v brew > /dev/null 2>&1; then
        print_info "brew is already installed"
        print_info "brew bundle install start"
        cd ./brew/ && brew bundle && cd ..
    else
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    print_info "brew install done"
fi

# cargo install
if [ $cargo_flag -eq 0 ]; then
    if [ $OS == "Mac" ] || [ $OS == "Linux" ]; then
        print_info "cargo install start"
        if command -v cargo > /dev/null 2>&1; then
            print_info "cargo is already installed"
            print_info "cargo subcommands install start"
            cd ./cargo/ && ./run.sh && cd ..
        else
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
        fi
        print_info "cargo install done"
    fi
fi

# python install
if [ $python_flag -eq 0 ]; then
    if [ $OS == "Mac" ] || [ $OS == "Linux" ]; then
        print_info "python install start"
        if command -v conda > /dev/null 2>&1; then
            print_info "conda is already installed"
            print_info "python commands install  start"
            cd python && ./run.sh && cd ..
        else
            if [ $OS == "Mac" ]; then
                if [[ $arch == "x86_64" || $arch == "amd64" ]]; then
                    curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
                elif [[ $arch == "aarch64" || $arch == "arm64" ]]; then
                    curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh
                else
                    print_error "Unknown architecture"
                    exit 1
                fi
            fi
            if [ $OS == "Linux" ]; then
                if [[ $arch == "x86_64" || $arch == "amd64" ]]; then
                    curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
                elif [[ $arch == "aarch64" || $arch == "arm64" ]]; then
                    curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh
                else
                    print_error "Unknown architecture"
                    exit 1
                fi
            fi
            bash Miniconda3-latest-*-*.sh -p ${HOME}/works/tools/miniconda3 -b
        fi
        print_info "python install done"
    fi
fi

echo "[INFO] done" >&1
