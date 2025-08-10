#!/bin/bash
set -e

USAGE='
install.sh:
    dotfiles linker / installer / copier / unlinker

USAGE:
    ./install.sh [FLAGS]

EXAMPLE:
    ./install.sh                            only OS check
    ./install.sh --vim --zsh --tmux --git   dotfiles link
    ./install.sh --unlink                   all dotfiles unlink

OPTIONS:
    -h, --help              print help
    -u, --unlink            all dotfiles unlink
    -v, --vim               vim dotfiles link
    -z, --zsh               zsh dotfiles link
    -t, --tmux              tmux dotfiles link
    -g, --git               git dotfiles link
    -a, --alacritty         alacritty dotfiles link
    -n, --neovim            neovim dotfiles link
        --brew              brew install
        --cargo             cargo install
        --conda             conda install & python commands install
        --pixi              python commands install using pixi
        --macos             macos settings
        --ssh               ssh config file copy
        --bash              bash profile link
'

# default setting
unlink_flag=1
brew_flag=1
cargo_flag=1
conda_flag=1
pixi_flag=1
macos_flag=1
vim_flag=1
zsh_flag=1
tmux_flag=1
git_flag=1
alacritty_flag=1
neovim_flag=1
ssh_flag=1
bash_flag=1

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
        --brew)
            brew_flag=0
            ;;
        --cargo)
            cargo_flag=0
            ;;
        --conda)
            conda_flag=0
            ;;
        --pixi)
            pixi_flag=0
            ;;
        --macos)
            macos_flag=0
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
        --ssh)
            ssh_flag=0
            ;;
        --bash)
            bash_flag=0
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
    for dotfile in .vim .vimrc .bash_profile;
    do
        if [ -L $HOME/$dotfile ]; then
            unlink $HOME/$dotfile && echo "[INFO] $dotfile unlink done" >&1
        fi
    done

    for target in git zsh tmux alacritty neovim;
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
        export VIM_AI=1
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
    export VIM_AI=1
    create_link $PWD/nvim/ ${HOME}/.config/nvim
    print_info "neovim install done"
fi

# ssh config file copy
if [ $ssh_flag -eq 0 ]; then
    print_info "ssh config file copy start"
    if [ ! -d ${HOME}/.ssh ]; then
        mkdir -p ${HOME}/.ssh
        print_info "${HOME}/.ssh/ is created"
    fi
    if [ ! -e ${HOME}/.ssh/config ]; then
        cp ${PWD}/ssh/config ${HOME}/.ssh/config
        print_info "ssh config file copy done"
    else
        print_warn "${HOME}/.ssh/config is already exist"
    fi
fi

# bash link
if [ $bash_flag -eq 0 ]; then
    print_info "bash file link start"
    create_link ${PWD}/bash/.bash_profile ${HOME}/.bash_profile
    print_info "bash file link done"
fi

# brew install
if [ $OS == "Mac" ] && [ $brew_flag -eq 0 ]; then
    print_info "brew install start"
    if ! command -v brew > /dev/null 2>&1; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        export PATH="/opt/homebrew/bin:$PATH"
    fi

    if command -v brew > /dev/null 2>&1; then
        print_info "brew is already installed"
        print_info "brew bundle install start"
        cd ./brew/ && brew bundle && cd ..
    fi
    print_info "brew install done"
fi

# cargo install
if [ $cargo_flag -eq 0 ]; then
    if [ $OS == "Mac" ] || [ $OS == "Linux" ]; then
        print_info "cargo install start"
        if ! command -v cargo > /dev/null 2>&1; then
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
            export PATH="${HOME}/.cargo/bin:$PATH"
        fi

        if command -v cargo > /dev/null 2>&1; then
            print_info "cargo is already installed"
            print_info "cargo subcommands install start"
            cd ./cargo/ && ./run.sh && cd ..
        fi
        print_info "cargo install done"
    fi
fi

# conda install
if [ $conda_flag -eq 0 ]; then
    if [ $OS == "Mac" ] || [ $OS == "Linux" ]; then
        print_info "conda install start"
        if ! command -v conda > /dev/null 2>&1; then
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
            rm -f Miniconda3-latest-*-*.sh
            CONDA_BASE_PATH=${HOME}/works/tools/miniconda3

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

            print_info "conda init was written to ${HOME}/.config/zsh/.zshrc_local"
            print_info "conda install done"
            source ${HOME}/works/tools/miniconda3/etc/profile.d/conda.sh
            conda activate base
        fi

        if command -v conda > /dev/null 2>&1; then
            print_info "conda is already installed"
            print_info "python commands install start"
            source ${HOME}/works/tools/miniconda3/etc/profile.d/conda.sh
            conda activate base
            cd python && ./run.sh && cd ..
        fi

        print_info "conda install done"
    fi
fi

# pixi install
if [ $pixi_flag -eq 0 ]; then
    if command -v pixi >/dev/null 2>&1; then
        print_info "pixi is already installed"
        # print_info "python commands install start"
        # cd python && ./run.sh && cd ..
    else
        print_error "pixi is not installed"
        print_error "run first: ./install.sh --cargo"
        print_error "or run:"
        PIXI_VERSION="v0.50.2"
        if [ $OS == "Mac" ]; then
            if [[ $arch == "x86_64" || $arch == "amd64" ]]; then
                print_error "wget https://github.com/prefix-dev/pixi/releases/download/${PIXI_VERSION}/pixi-x86_64-apple-darwin.tar.gz"
            elif [[ $arch == "aarch64" || $arch == "arm64" ]]; then
                print_error "wget https://github.com/prefix-dev/pixi/releases/download/${PIXI_VERSION}/pixi-aarch64-apple-darwin.tar.gz"
            else
                print_error "Unknown architecture"
                print_error "open https://github.com/prefix-dev/pixi/releases"
                exit 1
            fi
        fi
        if [ $OS == "Linux" ]; then
            if [[ $arch == "x86_64" || $arch == "amd64" ]]; then
                print_error "wget https://github.com/prefix-dev/pixi/releases/download/${PIXI_VERSION}/pixi-x86_64-unknown-linux-musl.tar.gz"
            elif [[ $arch == "aarch64" || $arch == "arm64" ]]; then
                print_error "wget https://github.com/prefix-dev/pixi/releases/download/${PIXI_VERSION}/pixi-aarch64-unknown-linux-musl.tar.gz"
            else
                print_error "Unknown architecture"
                print_error "open https://github.com/prefix-dev/pixi/releases"
                exit 1
            fi
        fi
    fi
fi


# macos settings
if [ $macos_flag -eq 0 ]; then
    if [ $OS != "Mac" ]; then
        print_error "this script is only for macOS; skipping macos settings"
    else
        export PATH="/opt/homebrew/bin:$PATH"
        cd macos && ./run.sh --dockutil && cd ..
    fi
fi

echo "[INFO] done" >&1
