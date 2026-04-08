#!/bin/bash
set -e

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

CONDA_BASE_PATH=${HOME}/works/tools/miniconda3
arch=$(uname -m)

detect_os

print_info "conda install start"

if ! need_cmd conda; then
    if [ $OS == "Mac" ]; then
        if [[ $arch == "x86_64" || $arch == "amd64" ]]; then
            curl -LO https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
        elif [[ $arch == "aarch64" || $arch == "arm64" ]]; then
            curl -LO https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh
        else
            print_error "Unknown architecture: $arch"
            exit 1
        fi
    elif [ $OS == "Linux" ]; then
        if [[ $arch == "x86_64" || $arch == "amd64" ]]; then
            curl -LO https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
        elif [[ $arch == "aarch64" || $arch == "arm64" ]]; then
            curl -LO https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh
        else
            print_error "Unknown architecture: $arch"
            exit 1
        fi
    fi
    bash Miniconda3-latest-*-*.sh -p ${CONDA_BASE_PATH} -b
    rm -f Miniconda3-latest-*-*.sh

    cat >> ${HOME}/.config/zsh/.zshrc_local <<EOF

# <<< Conda initialization for Zsh >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="\$('$CONDA_BASE_PATH/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ \$? -eq 0 ]; then
    eval "\$__conda_setup"
else
    if [ -f "$CONDA_BASE_PATH/etc/profile.d/conda.sh" ]; then
        . "$CONDA_BASE_PATH/etc/profile.d/conda.sh"
    else
        export PATH="$CONDA_BASE_PATH/bin:\$PATH"
    fi
fi
unset __conda_setup
# <<< Conda initialization for Zsh >>>
EOF

    print_info "conda init was written to ${HOME}/.config/zsh/.zshrc_local"
    source ${CONDA_BASE_PATH}/etc/profile.d/conda.sh
    conda activate base
fi

print_info "conda install done"
