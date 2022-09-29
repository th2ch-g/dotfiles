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
alias les="less"
alias ta="tmux a"
alias tls="tmux ls"
alias tks="tmux kill-server"
alias cb="conda activate base && conda info -e"
alias ca="conda activate"
alias ce="conda info -e"
alias cl="conda list"
alias rp="realpath -e"
alias .="cd ."
alias cdt="cd $HOME/tools"
alias cdp="cd $HOME/prc"
alias cdw="cd $HOME/works"
alias cdb="cd $HOME/bin"


# local specfic alias file
if [ -e $HOME/.zshrc_alias ]; then
    cat $HOME/.zshrc_alias | while IFS= read -r line;
    do
        alias "$( echo $line | cut -d "," -f 1 )"="$( echo $line | cut -d "," -f 2 )"
    done
fi


# additional source file
if [ -e $HOME/.zshrc_source ]; then
    source $HOME/.zshrc_source
fi


# my function
hgrep() {
    history 1 | grep -i $1
}

calc() {
    echo "" | awk "{print $1}"
}

rusts() {
    rustc $1 -o rust_tmp_out && ./rust_tmp_out && rm -f rust_tmp_out
}

rusts3() {
    rustc $1 -C opt-level=3 -C debug_assertions=no -o rust_tmp_out \
        && ./rust_tmp_out && rm -f rust_tmp_out
}

bk() {
    if [ -z $1 ] || [[ ! "$1" =~ ^[0-9]+$ ]]; then
        cd ..
    else
        cd_str=""
        for i in $(seq $1);
        do
            cd_str="${cd_str}../"
        done
        cd "${cd_str}"
    fi
}

make_add_file() {
    arr=( .zshrc_source .zshrc_alias .zshenv_export )
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
