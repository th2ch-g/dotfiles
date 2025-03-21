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
    -v, --vim               only vim dotfiles link
    -z, --zsh               only zsh dotfiles link
    -t, --tmux              only tmux dotfiles link
    -g, --git               only git dotfiles link
    -a, --alacritty         only alacritty dotfiles link
'

# default setting
unlink_flag=1
brew_flag=1
cargo_flag=1
vim_flag=1
zsh_flag=1
tmux_flag=1
git_flag=1
alacritty_flag=1

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
       --)
            shift
            break
            ;;
        -?*)
            echo "[ERROR] Unknown option : ${1}" >&2
            exit 1
            ;;
        *)
            break
    esac
    shift
done

# OS judgment
if [ "$(uname)" == 'Darwin' ]; then
  OS='Mac'
elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
  OS='Linux'
elif [ "$(expr substr $(uname -s) 1 10)" == 'MINGW32_NT' ]; then
  OS='Cygwin'
else
  echo "[ERROR] Your platform ($(uname -a)) is not supported." >&2
  exit 1
fi
echo "[INFO] detect $OS OS" >&1

# cwd check
if [ ! -e $PWD/install.sh ]; then
    echo "[ERROR] install.sh is not detected" >&2
    echo "[ERROR] execute ./install.sh in dotfiles directory" >&2
    exit 1
fi

# config dir
if [ -d ${HOME}/.config ]; then
    mkdir -p ${HOME}/.config
fi

# unlink $HOME/[links]
if [ $unlink_flag -eq 0 ]; then
    echo "[INFO] Start unlink dotfiles" >&1
    set +e
    echo "[WARN] Ignore error" >&2

    # vim
    for dotfile in .vim .vimrc;
    do
        if [ -L $HOME/$dotfile ]; then
            unlink $HOME/$dotfile && echo "[INFO] $dotfile unlink done" >&1
        fi
    done

    # git
    if [ -L ${HOME}/.config/git ]; then
        unlink ${HOME}/.config/git && echo "[INFO] git unlink done" >&1
    fi

    # zsh
    if [ -L ${HOME}/.config/zsh ]; then
        unlink ${HOME}/.config/zsh && echo "[INFO] zsh unlink done" >&1
    fi

    # tmux
    if [ -L ${HOME}/.config/tmux ]; then
        unlink ${HOME}/.config/tmux && echo "[INFO] tmux unlink done" >&1
    fi

    # alacritty
    if [ -L ${HOME}/.config/alacritty ]; then
        unlink ${HOME}/.config/alacritty && echo "[INFO] alacritty unlink done" >&1
    fi

    echo "[INFO] dotfiles unlink done" >&1
    set -e
fi

# vim link
if [ $vim_flag -eq 0 ]; then
    echo "[INFO] Start link vim dotfiles" >&1
    # vim does not support config dir
    for dotfile in .vim .vimrc;
    do
        ln -nsi $PWD/$dotfile $HOME/$dotfile && echo "[INFO] $dotfile link done" >&1
    done
    vim -c "PlugInstall" -c "qa"
    echo "[INFO] vim dotfiles link done" >&1
fi

# zsh link
if [ $zsh_flag -eq 0 ]; then
    echo "[INFO] Start link zsh dotfiles" >&1
    ln -nsi $PWD/zsh ${HOME}/.config/zsh
    echo "[INFO] zsh dotfiles link done" >&1
fi

# tmux link
if [ $tmux_flag -eq 0 ]; then
    echo "[INFO] Start link tmux dotfiles" >&1
    ln -nsi $PWD/tmux ${HOME}/.config/tmux
    echo "[INFO] tmux dotfiles link done" >&1
fi

# git link
if [ $git_flag -eq 0 ]; then
    echo "[INFO] Start link git dotfiles" >&1
    ln -nsi $PWD/git ${HOME}/.config/git
    echo "[INFO] git dotfiles link done" >&1
fi

# brew install
if [ $OS == "Mac" ] && [ $brew_flag -eq 0 ]; then
    echo "[INFO] Start install brew" >&1
    if command -v brew > /dev/null 2>&1; then
        echo "[INFO] brew is already installed" >&1
    else
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    cd ./brew/ && brew bundle && cd ..
    echo "[INFO] brew install done" >&1
fi

# cargo install
if [ $cargo_flag -eq 0 ]; then
    if [ $OS == "Mac" ] || [ $OS == "Linux" ]; then
        echo "[INFO] Start install cargo" >&1
        if command -v cargo > /dev/null 2>&1; then
            echo "[INFO] cargo is already installed" >&1
        else
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        fi
        cd ./cargo/ && ./run.sh && cd ..
        echo "[INFO] cargo install done" >&1
    fi
fi

# alacritty link
if [ $alacritty_flag -eq 0 ]; then
    echo "[INFO] Start link alacritty dotfiles" >&1
    ln -nsi $PWD/alacritty ${HOME}/.config/alacritty
    echo "[INFO] alacritty dotfiles link done" >&1
fi

echo "[INFO] done" >&1
