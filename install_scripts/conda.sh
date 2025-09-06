#!/bin/bash
set -e

CONDA_BASE_PATH=${HOME}/works/tools/miniconda3


# OS check
if [ "$(uname)" == 'Darwin' ]; then
  OS='Mac'
elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
  OS='Linux'
elif [ "$(expr substr $(uname -s) 1 10)" == 'MINGW32_NT' ]; then
  OS='Cygwin'
else
  echo "Your platform ($(uname -a)) is not supported."
  exit 1
fi


if [ $OS == "Mac" ] || [ $OS == "Linux" ]; then
    echo "conda install start"
    if ! command -v conda > /dev/null 2>&1; then
        if [ $OS == "Mac" ]; then
            if [[ $arch == "x86_64" || $arch == "amd64" ]]; then
                curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
            elif [[ $arch == "aarch64" || $arch == "arm64" ]]; then
                curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh
            else
                echo "Unknown architecture"
                exit 1
            fi
        fi
        if [ $OS == "Linux" ]; then
            if [[ $arch == "x86_64" || $arch == "amd64" ]]; then
                curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
            elif [[ $arch == "aarch64" || $arch == "arm64" ]]; then
                curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh
            else
                echo "Unknown architecture"
                exit 1
            fi
        fi
        bash Miniconda3-latest-*-*.sh -p ${CONDA_BASE_PATH} -b
        rm -f Miniconda3-latest-*-*.sh

        echo """
# <<< Conda initialization for Zsh >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup=\"\$('$CONDA_BASE_PATH/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)\"
if [ \$? -eq 0 ]; then
    eval \"\$__conda_setup\"
else
    if [ -f \"$CONDA_BASE_PATH/etc/profile.d/conda.sh\" ]; then
        . \"$CONDA_BASE_PATH/etc/profile.d/conda.sh\"
    else
        export PATH=\"$CONDA_BASE_PATH/bin:\$PATH\"
    fi
fi
unset __conda_setup
# <<< Conda initialization for Zsh >>>

""" >> ${HOME}/.config/zsh/.zshrc_local

        echo "conda init was written to ${HOME}/.config/zsh/.zshrc_local"
        echo "conda install done"
        source ${CONDA_BASE_PATH}/etc/profile.d/conda.sh
        conda activate base
    fi

    echo "conda install done"
fi
