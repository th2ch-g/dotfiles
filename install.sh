#!/bin/sh

set -e


USAGE='
install.sh:
    dotfiles linker

USAGE:
    ./install.sh [FLAGS]

DESCRIPTION:
    dotfiles linker

EXAMPLE:
    ./install.sh                            only OS check
    ./install.sh --link                     OS check & dotfiles link
    ./install.sh --link --brew --cargo      OS check & dotfiles link & brew install & cargo install

OPTIONS:
    -h, --help              Print help
    -u, --unlink            dotfiles unlink
    -l, --link              dotfiles link
    -m, --make-dir          make basic directories
    -b, --brew              brew install
    -c, --cargo             cargo install
    -v, --vim-link          only vim dotfiles link
    -z, --zsh-link          only zsh dotfiles link
'


# default setting
link_flag=1
make_dir_flag=1
brew_flag=1
cargo_flag=1
unlink_flag=1
vim_link_flag=1
zsh_link_flag=1


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
            ;;
        -u | --unlink)
            unlink_flag=0
            ;;
        -m | --make-dir)
            make_dir_flag=0
            ;;
        -b | --brew)
            brew_flag=0
            ;;
        -c | --cargo)
            cargo_flag=0
            ;;
        -v | --vim-link)
            vim_link_flag=0
            ;;
        -z | --zsh-link)
            zsh_link_flag=0
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
  echo "[ERROR] Your platform ($(uname -a)) is not supported."
  exit 1
fi
echo "[INFO] detect $OS OS" >&1


# cwd check
if [ ! -e $PWD/dotfiles-id-file ]; then
    echo "[ERROR] dotfiles-id-file is not detected" >&2
    echo "[ERROR] exec ./install.sh in dotfiles directory" >&2
    exit 1
fi


# unlink $HOME/[links]
if [ $unlink_flag -eq 0 ]; then

    echo "[INFO] Start unlink dotfiles" >&1
    for dotfile in .?*;
    do
        [ $dotfile = ".." ] && continue
        [ $dotfile = ".git" ] && continue
        [ $dotfile = ".gitignore" ] && continue
        [ $dotfile = ".gitmodules" ] && continue

        if [ $dotfile = ".zsh" ]; then
            for i in $(ls -a $PWD/.zsh);
            do
                [ $i = "." ] && continue
                [ $i = ".." ] && continue
                unlink ${HOME}/${i}
            done
        else
            unlink ${HOME}/${dotfile}
        fi

        echo "[INFO] $dotfile unlink done" >&1
    done
    echo "[INFO] dotfiles unlink done" >&1

    echo "[INFO] Start link others directories" >&1
    for dir in mytools;
    do
        unlink ${HOME}/${dir}
        echo "[INFO] $dir unlink done" >&1
    done
    echo "[INFO] others directories unlink done" >&1

fi


# vim link
if [ $vim_link_flag -eq 0 ]; then
    echo "[INFO] Start link vim dotfiles" >&1
    for dotfile in .vim .vimrc;
    do
        ln -nsi $PWD/$dotfile $HOME
        echo "[INFO] $dotfile link done" >&1
    done
    echo "[INFO] vim dotfiles link done" >&1
fi


# zsh link
if [ $zsh_link_flag -eq 0 ]; then
    echo "[INFO] Start link zsh dotfiles" >&1
    for dotfile in $(ls -a $PWD/.zsh);
    do
        [ $i = "." ] && continue
        [ $i = ".." ] && continue
        ln -nsi $PWD/.zsh/$i $HOME
        echo "[INFO] $dotfile link done" >&1
    done
    echo "[INFO] zsh dotfiles link done" >&1
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

        if [ $dotfile = ".zsh" ]; then
            for i in $(ls -a $PWD/.zsh);
            do
                [ $i = "." ] && continue
                [ $i = ".." ] && continue
                ln -nsi $PWD/.zsh/$i $HOME
            done
        else
            ln -nsi $PWD/$dotfile $HOME
        fi

        echo "[INFO] $dotfile link done" >&1
    done
    echo "[INFO] dotfiles link done" >&1

    echo "[INFO] Start link other directories" >&1
    for dir in mytools;
    do
        ln -nsi $PWD/$dir $HOME
        echo "[INFO] $dir link done" >&1
    done
    echo "[INFO] other directories link done" >&1

fi


# make basic directories
if [ $make_dir_flag  -eq 0 ]; then
    arr=( tools prc bin )
    for i in ${arr[@]};
    do
        if [ ! -d $HOME/${i} ]; then
            echo "[INFO] mkdir $HOME/${i}" >&1
            mkdir $HOME/${i}
        fi
    done

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

