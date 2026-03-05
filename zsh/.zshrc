#=================================================
local DEBUG=0
if [ $DEBUG -eq 1 ]; then
    zmodload zsh/zprof && zprof
fi

# export
export LS_COLORS='di=38;2;171;144;121' # ls color -> light brown
export WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
export GPG_TTY=$(tty)
export HISTFILE="${ZDOTDIR:-$HOME/.config/zsh}/history"
export LESS='-g -i -M -Q -R -S -w -X -z-4 --no-vbell'
if [[ -z "$LESSOPEN" ]] && (( $#commands[(i)lesspipe(|.sh)] )); then
  export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
fi
export SAVEHIST=100000000
export HISTSIZE=100000
export CLICOLOR=1

# override source
function source {
  ensure_zcompiled $1
  builtin source $1
}
function ensure_zcompiled {
  local compiled="$1.zwc"
  if [[ ! -r "$compiled" || "$1" -nt "$compiled" ]]; then
    echo "\033[1;36mCompiling\033[m $1"
    zcompile $1
  fi
}
ensure_zcompiled ${ZDOTDIR:-$HOME/.config/zsh}/.zshrc

# additional settings
# sheldon
local use_plugins=1
if [[ $use_plugins -eq 1 ]]; then
    if ! command -v sheldon &> /dev/null; then
        curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh \
            | bash -s -- --repo rossmacarthur/sheldon --to ${HOME}/.local/bin
    fi
    # eval "$(sheldon source)"
    SHELDON_CACHE="${ZDOTDIR:-$HOME/.config/zsh}/sheldon_cache.zsh"
    SHELDON_TOML="${XDG_CONFIG_HOME:-$HOME/.config}/sheldon/plugins.toml"
    if [[ ! -r "$SHELDON_CACHE" || "$SHELDON_TOML" -nt "$SHELDON_CACHE" ]]; then
        sheldon source > $SHELDON_CACHE
    fi
    source $SHELDON_CACHE
fi
if command -v zsh-defer &> /dev/null; then
    DEFER="zsh-defer"
else
    DEFER=""
fi

# eza
if command -v eza > /dev/null 2>&1; then
    alias ls="eza --color=auto"
else
    alias ls="ls --color=auto"
fi

# zoxide
if command -v zoxide > /dev/null 2>&1; then
    # eval "$(zoxide init zsh)"
    ZOXIDE_CACHE="${ZDOTDIR:-$HOME/.config/zsh}/zoxide_cache.zsh"
    if [[ ! -r "$ZOXIDE_CACHE" || "$(command -v zoxide)" -nt "$ZOXIDE_CACHE" ]]; then
        zoxide init zsh > $ZOXIDE_CACHE
    fi
    $DEFER source $ZOXIDE_CACHE
fi

# prompt
if [ $use_plugins -eq 1 ]; then
    autoload -Uz promptinit && promptinit
    prompt pure
    autoload -Uz colors && colors
    zstyle :prompt:pure:user color green
    zstyle :prompt:pure:host color green
else
    # define prompt like pure
    autoload -Uz vcs_info
    zstyle ':vcs_info:*' enable git
    precmd() {
        vcs_info
    }
    zstyle ':vcs_info:git:*' formats       ' %F{cyan}%b%f'
    zstyle ':vcs_info:git:*' actionformats ' %F{cyan}%b%f (%a)'
    zstyle ':vcs_info:git:*' check-for-changes true
    zstyle ':vcs_info:git:*' unstagedstr ' %F{yellow}* M%f'
    zstyle ':vcs_info:git:*' stagedstr ' %F{green}* A%f'
    setopt PROMPT_SUBST
    REPORTTIME=3
    preexec() {
      (( ${TMOUT:-0} > 0 )) && { TMOUT=$TMOUT; }
      timer=${timer:-$SECONDS}
    }
    precmd_exec_time() {
      if [ $timer ]; then
        now=$SECONDS
        delta=$((now - timer))

        if [ $delta -gt $REPORTTIME ]; then
          PROMPT="%F{yellow}${delta}s%f"
        else
          PROMPT=""
        fi
        unset timer
      fi
    }
    precmd_functions+=(precmd_exec_time)
    PROMPT='%F{blue}%~%f${vcs_info_msg_0_}
%(?.%F{blue}.%F{red})❯%f '
fi

# basic
setopt no_beep
setopt ignore_eof
setopt correct
setopt auto_pushd
setopt pushd_ignore_dups
setopt auto_cd
bindkey -e

# history
setopt share_history
setopt hist_reduce_blanks
setopt hist_ignore_space
setopt extended_history
setopt hist_save_no_dups
setopt hist_ignore_all_dups

# autoload -Uz history-search-end
# zle -N history-beginning-search-backward-end history-search-end
# zle -N history-beginning-search-forward-end history-search-end
# bindkey "^P" history-beginning-search-backward-end
# bindkey "^N" history-beginning-search-forward-end

# compinit
autoload -Uz compinit && $DEFER compinit
setopt auto_param_keys
setopt auto_param_slash
setopt complete_in_word
zstyle ':completion:*:default' menu select=2
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# mkdir alias
alias mkdir="mkdir -p"

# cd alias
alias .....="cd ../../../../"
alias ....="cd ../../../"
alias ...="cd ../../"
alias cdb="cd $BIN"
alias cdm="cd $MISC"
alias cdo="cd $OTHERS"
alias cds="cd $SHARE"
alias cdt="cd $TOOLS"
alias cdw="cd $WORKS"
alias cdn="cd $MNT"

# disk alias
alias df="df -h"
alias du="du -h"
alias e="exit"
alias free="free -h"

# ls alias
alias l="ls -1"
alias sl="ls"
# alias la="ls -stlhA"
# alias ll="ls -stlh"

# less alias
alias batp="bat -p --paging=always"
alias les="less -S"

# open alias
alias o="open"

# scp alias
alias scp="noglob scp"

# vim alias
alias n="nvim"
alias nv="nvim"
alias v="vim"
alias vi="vim"
alias memo="vim ${HOME}/.memo.md"
alias pass="vim_ai_off; pass"
alias gp="gopass"

# slurm alias
alias scancela="scancel -u $USER"
alias squeue_full="squeue -o '%.18i %.9P %.50j %.8u %.8T %.10M %.6D %R %y %Z %C %b'"

# tmux alias
alias ta="tmux a"
alias tkas="tmux kill-server"
alias tls="tmux ls"

# git alias
# alias gac='git add -A && git commit -m "$(git diff --staged | claude -p "Generate a concise git commit message for this diff. Output the message and Co-author:")"'
alias gac='git add -A && claude -p "/commit-commands:commit"'
alias gc='git add -A && git commits -m add && git push'

# others
alias p="top"
alias rusts="rust-script"
alias sshxy="ssh -XY"
alias tree="pwd;find . | sort | sed '1d;s/^\.//;s/\/\([^/]*\)$/|--\1/;s/\/[^/|]*/|  /g'"
alias wget="wget --hsts-file=$XDG_CONFIG_HOME/wget-hsts"

# local specific file
if [ -e ${ZDOTDIR:-$HOME}/.zshrc_local ]; then
    source ${ZDOTDIR:-$HOME}/.zshrc_local
fi

# hook
precmd() {
    # reset cursor
    echo -ne "\e[6 q"
}

chpwd() {
    if command -v eza &> /dev/null; then
        eza -a --color=auto
    else
        ls -a --color=auto
    fi
}

# my function
tar-close() {
    tar -cvzf ${1}.tar.gz $1
}

tar-open() {
    tar -xvzf $1
}

benchmark() {
    (for i in $(seq 1 10); do time zsh -i -c exit; done)
}

dont_sleep() {
    # macos
    caffeinate -i -d
}

cld() {
    nono run \
        --allow-cwd \
        --read $BIN \
        --read $HOME/.local/bin/ \
        --read $TOOLS/rust/ \
        --read $TOOLS/pixi/ \
        --read $CONFIG/git/ \
        --read $CONFIG/gh \
        --allow $HOME/.cache \
        --allow $HOME/.local/share \
        --allow $HOME/.serena \
        --profile claude-code \
        -v \
        -- claude \
        --permission-mode bypassPermissions \
        --allow-dangerously-skip-permissions \
        --dangerously-skip-permissions
}

function tenki(){
    local target=$1
    curl "https://ja.wttr.in/${target}?2nF"
}

script_highlight() {
    for ft in sh py bash;
    do
        ft_number=$(find . -name "*.${ft}" -type f -maxdepth 1 | wc -l)
        if [ $ft_number -ne 0 ]; then
            chmod a+x *.${ft}
            echo "[info] highlighted : $(echo *.${ft})"
        fi

    done
}

script_unhighlight() {
    for ft in sh py bash;
    do
        ft_number=$(find . -name "*.${ft}" -type f -maxdepth 1 | wc -l)
        if [ $ft_number -ne 0 ]; then
            chmod a-x *.${ft}
            echo "[info] unhighlighted : $(echo *.${ft})"
        fi

    done
}

rp() {
    # if command -v realpath &> /dev/null; then
    if [[ $(uname) == "Linux" ]]; then
        realpath -e "$1"
    else
        readlink -f "$1"
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

update_dotfiles() {
    CWD=$PWD
    cd $WORKS/dotfiles
    git pull
    cd $CWD
    echo "[INFO] dotfiles is updated" >&1
}

prepare_all() {
    prepare_base_dir
    make_local_file
}

make_local_file() {
    arr=( .zshrc_local .zshenv_local )
    flag=1
    for i in ${arr[@]};
    do
        if [ ! -e ${ZDOTDIR:-$HOME}/${i} ]; then
            touch ${ZDOTDIR:-$HOME}/${i}
            echo "[INFO] touch ${ZDOTDIR:-$HOME}/${i}" >&1
            flag=0
        fi
    done

    if [ $flag -eq 1 ]; then
        echo "[INFO] nothing was created" >&1
    fi
}

prepare_base_dir() {
    arr=( $MISC $TOOLS $OTHERS $BIN $SHARE )
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

vim_ai_off() {
    export VIM_AI=0
}

vim_ai_on() {
    export VIM_AI=1
}

systemctl_restart() {
    if [ -z "$1" ]; then
        echo "Usage: systemctl_restart <service_name>"
        return
    fi
    sudo systemctl enable $1 && sudo systemctl restart $1 && sudo systemctl status $1
}

tide() {
  local USAGE='
tide:
    My Integrated Development Environment using Tmux (tmux_ide)

USAGE:
    tide -n [WINDOW_NAME] -t [WINDOW_TYPE]

DESCRIPTION:
    Terminal partitioning for development environment using Tmux.

EXAMPLE:
    tide                     Make tmux named "home"
    tide -n Rust             Make tmux named "Rust"
    tide -t 2                Make window type 2 (2x2 window)

OPTIONS:
    -h, --help              Print help
    -n, --name [NAME]       Name of tmux window [default: home]
    -t, --type {1,2,3,4}    Type of window. Choose {1,2,3,4}.
    type1 means 2+3 window, type2 means 2x2 window, type3 means 1+1 window(horizontal), type4 means 1+1 window(vertical) [default: 1]
    -x, --top-off           Do not put on top on the right edge [default: not set]
    -c, --cmd [command]     Command to run after log into tmux
'

  local tmux_window_name="home"
  local window_type="1"
  local top_off=0
  local cmd=""

  if ! command -v tmux >/dev/null; then
    echo "[ERROR] tmux is not found" >&2
    return 1
  fi

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help) echo "$USAGE"; return 0 ;;
      -n|--name)
        [[ -z "$2" ]] && { echo "[ERROR] WINDOW_NAME is necessary, if -n/--name option is present" >&2; return 1; }
        tmux_window_name="$2"; shift 2 ;;
      -t|--type)
        [[ -z "$2" ]] && { echo "[ERROR] window_type is necessary, if -t/--type option is present" >&2; return 1; }
        [[ "$2" =~ ^[1-4]$ ]] || { echo "[ERROR] window_type must be \"1\", \"2\", \"3\" or \"4\", if -t/--type option is present" >&2; return 1; }
        echo "[INFO] window type is \"type${2}\""
        window_type="$2"; shift 2 ;;
      -x|--top-off) top_off=1; shift ;;
      -c|--cmd)
        [[ -z "$2" ]] && { echo "[ERROR] command is necessary, if -c/--cmd option is present" >&2; return 1; }
        cmd="$2"; shift 2 ;;
      --) shift; break ;;
      -*) echo "[ERROR] Unknown option: $1" >&2; return 1 ;;
      *) break ;;
    esac
  done

  # Send $cmd to panes 0..last_pane
  _tide_send_cmd() {
    local last_pane=$1
    [[ -z "$cmd" ]] && return
    for i in $(seq 0 $last_pane); do
      tmux send-keys -t "$i" "$cmd" C-m
    done
  }

  echo "[INFO] Start making tmux named \"$tmux_window_name\""
  tmux new -s "$tmux_window_name" -d

  case "$window_type" in
    1)
      tmux split-window -h
      tmux split-window -v
      tmux split-window -v
      tmux select-pane -t 0
      tmux split-window -v
      tmux select-pane -t 2 && tmux resize-pane -D 35
      tmux select-pane -t 4 && tmux resize-pane -D 8
      [[ $top_off -eq 0 ]] && tmux send-keys -t 4 "top" C-m
      tmux select-pane -t 0
      _tide_send_cmd $(( top_off == 0 ? 3 : 4 ))
      ;;
    2)
      tmux split-window -h
      tmux split-window -v
      tmux select-pane -t 0
      tmux split-window -v
      [[ $top_off -eq 0 ]] && tmux send-keys -t 3 "top" C-m
      tmux select-pane -t 0
      _tide_send_cmd $(( top_off == 0 ? 2 : 3 ))
      ;;
    3)
      tmux split-window -h
      tmux select-pane -t 0
      _tide_send_cmd 1
      ;;
    4)
      tmux split-window -v
      tmux select-pane -t 0
      _tide_send_cmd 1
      ;;
  esac

  unfunction _tide_send_cmd 2>/dev/null

  echo "[INFO] Make tmux named \"$tmux_window_name\""
  echo "[INFO] tmux ls Result"
  tmux ls

  tmux attach
}

$DEFER unfunction source

if [ $DEBUG -eq 1 ]; then
    zprof
fi
#==================================================
