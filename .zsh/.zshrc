#==================================================
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
    source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi


# prompt
autoload -Uz promptinit
promptinit
prompt pure
autoload -Uz colors
colors
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
autoload -Uz compinit
compinit
setopt auto_param_keys
setopt auto_param_slash
setopt complete_in_word
zstyle ':completion:*:default' menu select=2
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'


# export
export LS_COLORS='di=38;2;171;144;121' # ls color -> light brown
export CLICOLOR=1


# alias
alias ll="ls -lh"
alias la="ls -lhA"
alias sl="ls"
alias l="ls -1"
alias df="df -h"
alias du="du -h"
alias e="exit"
alias v="vim"
alias p="top"
alias les="less -S"
alias ta="tmux a"
alias tls="tmux ls"
alias tkas="tmux kill-server"
alias cb="conda activate base && conda info -e"
#alias ca="conda activate"
alias ce="conda info -e"
alias cl="conda list"
#alias rp="realpath -e"
alias memo="vim ~/.memo"
alias .="cd ."
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
alias cdp="cd $HOME/works/prc"
alias cdb="cd $HOME/works/bin"


# local specific file
if [ -e $HOME/.zshrc_local ]; then
    source $HOME/.zshrc_local
fi


# my function
ca() {
    conda activate $1 && conda info -e
}

rp() {
    if [ "$(uname)" = "Darwin" ]; then
        echo "$PWD/${1}"
    elif [ "$(uname)" = "Linux" ]; then
        realpath -e $1
    fi
}

hgrep() {
    history 1 | grep -i $1 | less -S +G
}

calc() {
    echo "" | awk "{OFMT=\"%.6f\"} {print $1}"
}

calc-int(){
    echo "" | awk "{OFMT=\"%.6f\"} {print int($1)}"
}

rusts() {
    rustc $1 -o rust_tmp_out && ./rust_tmp_out && rm -f rust_tmp_out
}

rusts3() {
    rustc $1 -C opt-level=3 -C debug_assertions=no -o rust_tmp_out \
        && ./rust_tmp_out && rm -f rust_tmp_out
}

make_add_file() {
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
#==================================================
