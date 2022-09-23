#!/bin/sh

set -e

mainpath=$HOME
name=vim-instant-installer

# default theme
theme=vscode

function usage {
cat <<EOM
Usage: $name [OPTION]...
  -h, --help     Print help
  -V, --version  Print version
  -v, --vscode   Set as VSCode theme
  -a, --atom     Set as Atom theme
EOM
exit 0
}


while :;
do
    case $1 in
        -v | --vscode)
            echo "[INFO] VSCode theme" >&1
            theme=vscode
            break
            ;;
        -a | --atom)
            echo "[INFO] Atom theme" >&1
            theme=atom
            break
            ;;
        -h | --help )
            usage >&1
            break
            ;;
        -?* )
            echo "[ERROR] Unknown option" >&2
            exit 1
            ;;
        * )
            break
            ;;
    esac
done


# file exist check
if [ -e "${mainpath}/.vimrc" ]; then
    echo "[ERROR] .vimrc file exists" >&2
    exit 1
fi

if [ -d "${mainpath}/.vim/" ]; then
    echo "[ERROR].vim/ dir exists" >&2
    exit 1
fi


# mkdir
mkdir -p ${mainpath}/.vim/
mkdir -p ${mainpath}/.vim/colors/
mkdir -p ${mainpath}/.vim/autoload/
mkdir -p ${mainpath}/.vim/plugged/


# install vim-plug
git clone https://github.com/junegunn/vim-plug.git && \
    mv vim-plug/plug.vim ${mainpath}/.vim/autoload/. && \
    rm -rf vim-plug

# install atom theme
git clone https://github.com/gosukiwi/vim-atom-dark.git && \
    mv vim-atom-dark/colors ${mainpath}/.vim/ && \
    rm -rf vim-atom-dark/

# install code theme
git clone https://github.com/tomasiser/vim-code-dark.git && \
    mv vim-code-dark/colors/codedark.vim ${mainpath}/.vim/colors && \
    rm -rf vim-code-dark/

# install lexima
git clone https://github.com/cohama/lexima.vim.git && \
    mv lexima.vim ${mainpath}/.vim/plugged/.

# install fern
git clone https://github.com/lambdalisue/fern.vim.git && \
    mv fern.vim ${mainpath}/.vim/plugged/.

# setting .vimrc
cp .vimrc ${mainpath}/.vimrc


# theme
if [ $theme = "atom" ];then
    echo "colorscheme atom-dark-256" >> ${mainpath}/.vimrc
fi

if [ $theme = "vscode" ];then
    echo "colorscheme codedark" >> ${mainpath}/.vimrc
fi

echo "[INFO] $name done" >&1
