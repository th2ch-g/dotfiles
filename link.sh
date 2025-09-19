#!/bin/bash
set -e

USAGE='
link.sh:
    dotfiles linker / copier / unlinker

USAGE:
    ./link.sh [FLAGS]

EXAMPLE:
    ./link.sh                            only OS check
    ./link.sh --vim --zsh --tmux --git   dotfiles link
    ./link.sh --unlink                   all dotfiles unlink

OPTIONS:
    -h, --help              print help
    -u, --unlink            all dotfiles unlink
    -v, --vim               vim dotfiles link
    -z, --zsh               zsh dotfiles link
    -t, --tmux              tmux dotfiles link
    -g, --git               git dotfiles link
    -a, --alacritty         alacritty dotfiles link
    -n, --neovim            neovim dotfiles link
    -y, --yabai             yabai dotfiles link
    -s, --skhd              skhd dotfiles link
        --ssh               ssh config file copy
        --bash              bash profile link (not recommend)
        --cp                use cp instaead of ln
        --rm                use rm instaead of unlink
'

# default setting
unlink_flag=1
vim_flag=1
zsh_flag=1
tmux_flag=1
git_flag=1
alacritty_flag=1
neovim_flag=1
ssh_flag=1
bash_flag=1
cp_flag=1
rm_flag=1
yabai_flag=1
skhd_flag=1

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
        --cp)
            cp_flag=0
            ;;
        --rm)
            rm_flag=0
            ;;
        -y | --yabai)
            yabai_flag=0
            ;;
        -s | --skhd)
            skhd_flag=0
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

print_info() { echo "[INFO] $1" >&1;  }
print_warn() { echo "[WARN] $1" >&2;  }
print_error() { echo "[ERROR] $1" >&2;  }
create_link() {
    local src=$1
    local dest=$2
    if [ $cp_flag -eq 0 ]; then
        cp -r "$src" "$dest" && print_info "Copied $(basename "$dest")"
    else
        ln -nsi "$src" "$dest" && print_info "Linked $(basename "$dest")"
    fi
}
remove_link() {
    local target=$1
    if [ $rm_flag -eq 0 ]; then
        rm -ir "$target" && print_info "Removed $(basename "$target")"
    else
        if [ -L "$target" ]; then
            unlink "$target" && print_info "Unlinked $(basename "$target")"
        fi
    fi
}


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
if [ ! -e $PWD/link.sh ]; then
    print_error "link.sh is not detected"
    print_error "execute ./link.sh in dotfiles directory"
    exit 1
fi

if [ ! -d ${HOME}/.config ]; then
    mkdir -p ${HOME}/.config
fi

if [[ $unlink_flag -eq 0 || $rm_flag -eq 0 ]]; then
    print_info "Start unlink dotfiles"
    set +e
    print_warn "Ignore error"

    # vim & bash
    for dotfile in .vim .vimrc .bash_profile;
    do
        remove_link $HOME/$dotfile
    done

    # git & zsh & tmux & alacritty & nvim
    for target in git zsh tmux alacritty nvim;
    do
        remove_link ${HOME}/.config/$target
    done
    remove_link ${HOME}/.zshenv

    print_info "dotfiles unlink done"
    set -e
fi

# vim link
if [ $vim_flag -eq 0 ]; then
    print_info "vim link start"
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
    print_info "vim link done"
fi

# zsh link
if [ $zsh_flag -eq 0 ]; then
    print_info "zsh link start"
    create_link ${PWD}/zsh ${HOME}/.config/zsh
    create_link ${PWD}/zsh/.zshenv ${HOME}/.zshenv
    print_info "zsh link done"
fi

# tmux link
if [ $tmux_flag -eq 0 ]; then
    print_info "tmux link start"
    create_link ${PWD}/tmux ${HOME}/.config/tmux
    print_info "tmux link done"
fi

# git link
if [ $git_flag -eq 0 ]; then
    print_info "git link start"
    create_link ${PWD}/git ${HOME}/.config/git
    print_info "git link done"
fi

# alacritty link
if [ $alacritty_flag -eq 0 ]; then
    print_info "alacritty link start"
    create_link $PWD/alacritty/ ${HOME}/.config/alacritty
    print_info "alacritty link done"
fi

# neovim link
if [ $neovim_flag -eq 0 ]; then
    print_info "neovim link start"
    export VIM_AI=1
    create_link $PWD/nvim/ ${HOME}/.config/nvim
    print_info "neovim link done"
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

# yabai
if [[ $yabai_flag -eq 0 && $OS == "Mac" ]]; then
    print_info "yabai link start"
    create_link ${PWD}/yabai ${HOME}/.config/yabai
    print_info "yabai link done"
    if command -v yabai >/dev/null 2>&1; then
        yabai --start-service
    fi
fi

# skhd
if [[ $skhd_flag -eq 0 && $OS == "Mac" ]]; then
    print_info "skhd link start"
    create_link ${PWD}/skhd ${HOME}/.config/skhd
    print_info "skhd link done"
    if command -v skhd >/dev/null 2>&1; then
        skhd --start-service
    fi
fi

echo "[INFO] done" >&1
