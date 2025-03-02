#=================================================
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
    source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# prompt
autoload -Uz promptinit; promptinit && prompt pure
autoload -Uz colors && colors
zstyle :prompt:pure:user color green
zstyle :prompt:pure:host color green

# basic
setopt no_beep
setopt ignore_eof
setopt correct
setopt auto_pushd
setopt pushd_ignore_dups
setopt no_beep
export LANG=ja_JP.UTF-8
setopt share_history
setopt histignorealldups
setopt auto_cd
chpwd() { ls -a }
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
bindkey -e

# history
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000000
setopt share_history
setopt hist_reduce_blanks
setopt hist_ignore_space
setopt extended_history
setopt hist_save_no_dups
setopt hist_ignore_all_dups

autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

# compinit
autoload -Uz compinit && compinit
setopt auto_param_keys
setopt auto_param_slash
setopt complete_in_word
zstyle ':completion:*:default' menu select=2
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# export
export LS_COLORS='di=38;2;171;144;121' # ls color -> light brown
export CLICOLOR=1
export PIPENV_VENV_IN_PROJECT=1

# alias
alias ll="ls -stlh"
alias la="ls -stlhA"
alias sl="ls"
alias l="ls -1"
alias df="df -h"
alias du="du -h"
alias free="free -h"
alias e="exit"
alias v="vim"
alias vi="vim"
alias p="top"
alias les="less -S"
alias ta="tmux a"
alias tls="tmux ls"
alias tkas="tmux kill-server"
alias cb="conda activate base && conda info -e"
alias ce="conda info -e"
alias cl="conda list"
alias tree="pwd;find . | sort | sed '1d;s/^\.//;s/\/\([^/]*\)$/|--\1/;s/\/[^/|]*/|  /g'"
alias memo="vim ~/.memo"
alias ...="cd ../../"
alias ....="cd ../../../"
alias .....="cd ../../../../"
alias ......="cd ../../../../../"
alias .......="cd ../../../../../../"
alias ........="cd ../../../../../../../"
alias .........="cd ../../../../../../../../"
alias ..........="cd ../../../../../../../../../"
alias ...........="cd ../../../../../../../../../../"
alias cdw="cd $HOME/works"
alias cdt="cd $HOME/works/tools"
alias cdm="cd $HOME/works/misc"
alias cdb="cd $HOME/works/bin"
alias cdo="cd $HOME/works/others"
alias cds="cd $HOME/works/share"
alias batp="bat -p --paging=always"
alias sshxy="ssh -XY"
alias rusts="rust-script"

# zoxide
if [[ -x "$(which zoxide)" ]]; then
    eval "$(zoxide init zsh)"
fi

# local specific file
if [ -e $HOME/.zshrc_local ]; then
    source $HOME/.zshrc_local
fi

# my function
tar-close() {
    tar -cvzf ${1}.tar.gz $1
}

tar-open() {
    tar -xvzf $1
}

mydu() {
    USAGE="[ERROR] usage: mydu <target_top_dir>"
    if [ -z "$1" ]; then
        echo "$USAGE" >&2
    else
        today=$(date "+%Y%m%d")
        du -d 1 $1 > ${today}.du
        echo "[INFO] mydu done, output file is ${today}.du" >&1
    fi
}


script_highlight() {
    sh_number=$(find . -name "*.sh" -type f -maxdepth 1 | wc -l)
    if [ $sh_number -ne 0 ]; then
        chmod a+x *.sh
        echo "[INFO] highlighted : $(echo *.sh)"
    fi

    py_number=$(find . -name "*.py" -type f -maxdepth 1 | wc -l)
    if [ $py_number -ne 0 ]; then
        chmod a+x *.py
        echo "[INFO] highlighted : $(echo *.py)"
    fi

    bash_number=$(find . -name "*.bash" -type f -maxdepth 1 | wc -l)
    if [ $bash_number -ne 0 ]; then
        chmod a+x *.bash
        echo "[INFO] highlighted : $(echo *.bash)"
    fi
}

script_unhighlight() {
    sh_number=$(find . -name "*.sh" -type f -maxdepth 1 | wc -l)
    if [ $sh_number -ne 0 ]; then
        chmod a-x *.sh
        echo "[INFO] unhighlighted : $(echo *.sh)"
    fi

    py_number=$(find . -name "*.py" -type f -maxdepth 1 | wc -l)
    if [ $py_number -ne 0 ]; then
        chmod a-x *.py
        echo "[INFO] unhighlighted : $(echo *.py)"
    fi

    bash_number=$(find . -name "*.bash" -type f -maxdepth 1 | wc -l)
    if [ $bash_number -ne 0 ]; then
        chmod a-x *.bash
        echo "[INFO] unhighlighted : $(echo *.bash)"
    fi
}

cr() {
    conda remove -n "$1" --all -y && conda info -e
}

cn() {
    conda create -n "$1" -y && conda activate "$1" && conda info -e
}

ca() {
    conda activate "$1" && conda info -e
}

rp() {
    if [ "$(uname)" = "Darwin" ]; then
        echo "$PWD/${1}"
    elif [ "$(uname)" = "Linux" ]; then
        realpath -e "$1"
    fi
}

hgrep() {
    if [ -n "$1" ]; then
        history 1 | grep -i "$1" | less -S +G
    else
        history 1 | less -S +G
    fi
}

calc() {
    echo "" | awk "{OFMT=\"%.6f\"} {print $1}"
}

make_local_file() {
    arr=( .zshrc_local .zshenv_local )
    flag=1
    for i in ${arr[@]};
    do
        if [ ! -e $HOME/${i} ]; then
            touch $HOME/${i}
            echo "[INFO] touch ${HOME}/${i}" >&1
            flag=0
        fi
    done

    if [ $flag -eq 1 ]; then
        echo "[INFO] nothing was created" >&1
    fi
}

update_dotfiles() {
    CWD=$PWD
    cd ~/works/dotfiles
    git pull
    cd $CWD
    echo "[INFO] dotfiles is updated" >&1
}

prepare_base_dir() {
    arr=( ~/works/misc/ ~/works/tools/ ~/works/others/ ~/works/bin/ ~/works/share )
    for i in ${arr[@]};
    do
        if [ ! -d $i ]; then
            mkdir -p $i
            echo "[INFO] $i was created" >&1
        else
            echo "[WARN] $i is already created" >&1
        fi
    done
    echo "[INFO] base directories were prepared" >&1
}

vim_codeium_off() {
    sed -i -e "s/let g:codeium_enabled = 1/let g:codeium_enabled = 0/g" $(readlink ~/.vimrc)
    a=$(dirname $(readlink ~/.vimrc))
    rm -f ${a}/.vimrc-e
}

vim_codeium_on() {
    sed -i -e "s/let g:codeium_enabled = 0/let g:codeium_enabled = 1/g" $(readlink ~/.vimrc)
    a=$(dirname $(readlink ~/.vimrc))
    rm -f ${a}/.vimrc-e
}
#==================================================
