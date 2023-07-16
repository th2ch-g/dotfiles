#!/bin/bash
set -e

USAGE='
install.sh:
    dotfiles linker

USAGE:
    ./install.sh [FLAGS]

EXAMPLE:
    ./install.sh                            only OS check
    ./install.sh --link                     OS check & dotfiles link
    ./install.sh --link --brew --cargo      OS check & dotfiles link & brew install & cargo install

OPTIONS:
    -h, --help              print help
    -u, --unlink            dotfiles unlink
    -l, --link              dotfiles link
    -b, --brew              brew install
    -c, --cargo             cargo install
    -v, --vim               only vim dotfiles link
    -z, --zsh               only zsh dotfiles link
    -t, --tmux              only tmux dotfiles link
    -g, --git               only git dotfiles link
    -m, --mytools           add $PWD/mytools export to ~/.zshrc_local
'

# default setting
link_flag=1
unlink_flag=1
brew_flag=1
cargo_flag=1
vim_flag=1
zsh_flag=1
tmux_flag=1
git_flag=1
mytools_flag=1

# option parser
while :;
do
    case $1 in
        -h | --help)
            echo "$USAGE" >&1
            exit 0
            ;;
        -l | --link)
            link_flag=0
            break
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
        -m | --mytools)
            mytools_flag=0
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
if [ ! -e $PWD/LICENSE ]; then
    echo "[ERROR] LICENSE is not detected" >&2
    echo "[ERROR] execute ./install.sh in dotfiles directory" >&2
    exit 1
fi

# unlink $HOME/[links]
if [ $unlink_flag -eq 0 ]; then
    echo "[INFO] Start unlink dotfiles" >&1
    set +e
    echo "[WARN] Ignore error" >&2
    for dotfile in .?*;
    do
        [ $dotfile = ".." ] && continue
        [ $dotfile = ".git" ] && continue
        [ $dotfile = ".gitignore" ] && continue
        [ $dotfile = ".gitmodules" ] && continue
        [ $dotfile = ".github" ] && continue
        if [ $dotfile = ".zsh" ]; then
            for i in $(ls -a $PWD/.zsh);
            do
                [ $i = "." ] && continue
                [ $i = ".." ] && continue
                unlink ${HOME}/${i}
            done
        else
            unlink ${HOME}/${dotfile}
        fi && echo "[INFO] $dotfile unlink done" >&1
    done
    echo "[INFO] dotfiles unlink done" >&1
    set -e
fi

# vim link
if [ $vim_flag -eq 0 ]; then
    echo "[INFO] Start link vim dotfiles" >&1
    for dotfile in .vim .vimrc;
    do
        ln -nsi $PWD/$dotfile $HOME/$dotfile && echo "[INFO] $dotfile link done" >&1
    done
    echo "[INFO] vim dotfiles link done" >&1
fi

# zsh link
if [ $zsh_flag -eq 0 ]; then
    echo "[INFO] Start link zsh dotfiles" >&1
    for dotfile in $(ls -a $PWD/.zsh);
    do
        [ $dotfile = "." ] && continue
        [ $dotfile = ".." ] && continue
        ln -nsi $PWD/.zsh/$dotfile $HOME/$dotfile && echo "[INFO] $dotfile link done" >&1
    done
    echo "[INFO] zsh dotfiles link done" >&1
fi

# tmux link
if [ $tmux_flag -eq 0 ]; then
    echo "[INFO] Start link tmux dotfiles" >&1
    for dotfile in .tmux.conf;
    do
        ln -nsi $PWD/$dotfile $HOME/$dotfile && echo "[INFO] $dotfile link done" >&1
    done
    echo "[INFO] tmux dotfiles link done" >&1
fi

# git link
if [ $git_flag -eq 0 ]; then
    echo "[INFO] Start link git dotfiles" >&1
    for dotfile in .gitignore_global .gitconfig;
    do
        [ $dotfile = ".git" ] && continue
        [ $dotfile = ".gitignore" ] && continue
        [ $dotfile = ".gitmodules" ] && continue
        [ $dotfile = ".github" ] && continue
        ln -nsi $PWD/$dotfile $HOME/$dotfile && echo "[INFO] $dotfile link done" >&1
    done
    echo "[INFO] git dotfiles link done" >&1
fi

# link
if [ $link_flag -eq 0 ]; then
    echo "[INFO] Start link dotfiles" >&1
    for dotfile in .?*;
    do
        [ $dotfile = ".." ] && continue
        [ $dotfile = ".git" ] && continue
        [ $dotfile = ".gitignore" ] && continue
        [ $dotfile = ".gitmodules" ] && continue
        [ $dotfile = ".github" ] && continue
        if [ $dotfile = ".zsh" ]; then
            for i in $(ls -a $PWD/.zsh);
            do
                [ $i = "." ] && continue
                [ $i = ".." ] && continue
                ln -nsi $PWD/.zsh/$i $HOME
            done
        else
            ln -nsi $PWD/$dotfile $HOME/$dotfile
        fi && echo "[INFO] $dotfile link done" >&1
    done
    echo "[INFO] dotfiles link done" >&1
fi

# mytools
if [ $mytools_flag -eq 0 ]; then
    echo "[INFO] Start adding mytools path to ~/.zshrc_local" >&1
    echo "export PATH=\"$PWD/mytools:\$PATH\"" >> $HOME/.zshrc_local
    echo "[INFO] add mytools path done" >&1
fi

# brew install
if [ $OS == "Mac" ] && [ $brew_flag -eq 0 ]; then
    echo "[INFO] Start install brew" >&1
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    cd ./brew-install-list && ./run.sh && cd ..
    echo "[INFO] brew install done" >&1
fi

# cargo install
if [ $cargo_flag -eq 0 ]; then
    if [ $OS == "Mac" ] || [ $OS == "Linux" ]; then
        echo "[INFO] Start install cargo" >&1
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        cd ./cargo-install-list && ./run.sh && cd ..
        echo "[INFO] cargo install done" >&1
    fi
fi
