#=================================================
local DEBUG=0
if [ $DEBUG -eq 1 ]; then
    zmodload zsh/zprof && zprof
fi

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
ensure_zcompiled ${ZDOTDIR:-$HOME}/.zshrc

# additional settings
# sheldon
local use_plugins=1
if [[ $use_plugins -eq 1 ]]; then
    if ! command -v sheldon &> /dev/null; then
        curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh \
            | bash -s -- --repo rossmacarthur/sheldon --to ${HOME}/.local/bin
    fi
    # eval "$(sheldon source)"
    SHELDON_CACHE="${ZDOTDIR:-$HOME}/sheldoni_cache.zsh"
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

# exa
if command -v exa > /dev/null 2>&1; then
    alias ls="exa"
fi

# zoxide
if command -v zoxide > /dev/null 2>&1; then
    # eval "$(zoxide init zsh)"
    ZOXIDE_CACHE="${ZDOTDIR:-$HOME}/zoxide_cache.zsh"
    if [[ ! -r "$ZOXIDE_CACHE" || "$SHELDON_TOML" -nt "$ZOXIDE_CACHE" ]]; then
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
          RPROMPT="%F{yellow}${delta}s%f"
        else
          RPROMPT=""
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
setopt no_beep
setopt share_history
setopt histignorealldups
setopt auto_cd
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
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

# disk alias
alias df="df -h"
alias du="du -h"
alias e="exit"
alias free="free -h"

# ls alias
alias l="ls -1"
alias la="ls -stlhA"
alias ll="ls -stlh"
alias sl="ls"

# less alias
alias batp="bat -p --paging=always"
alias les="less -S"

# vim alias
alias n="nvim"
alias nv="nvim"
alias v="vim"
alias vi="vim"
alias memo="vim ~/.memo.md"
alias pass="vim_ai_off; pass"

# slurm alias
alias scancela="scancel -u $USER"
alias squeue_full="squeue -o '%.18i %.9P %.50j %.8u %.8T %.10M %.6D %R %y %Z %C %b'"

# tmux alias
alias ta="tmux a"
alias tkas="tmux kill-server"
alias tls="tmux ls"

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

chpwd() { ls -a }

# my function
tar-close() {
    tar -cvzf ${1}.tar.gz $1
}

tar-open() {
    tar -xvzf $1
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
    if command -v realpath &> /dev/null; then
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
    -t, --type {1,2,3,4}    Type of window. Choose {1,2,3}.
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
      -h|--help)
        echo "$USAGE"
        return 0
        ;;
      -n|--name)
        if [[ -z "$2" ]]; then
          echo "[ERROR] WINDOW_NAME is necessary, if -n/--name option is present" >&2
          return 1
        fi
        tmux_window_name="$2"
        shift 2
        continue
        ;;
      -t|--type)
        if [[ -z "$2" ]]; then
          echo "[ERROR] window_type is necessary, if -t/--type option is present" >&2
          return 1
        fi
        if [[ "$2" == "1" ]]; then
          echo "[INFO] window type is \"type1\""
          window_type="1"
        elif [[ "$2" == "2" ]]; then
          echo "[INFO] window type is \"type2\""
          window_type="2"
        elif [[ "$2" == "3" ]]; then
          echo "[INFO] window type is \"type3\""
          window_type="3"
        elif [[ "$2" == "4" ]]; then
            echo "[INFO] window type is \"type4\""
            window_type="4"
        else
          echo "[ERROR] window_type must be \"1\", \"2\" or \"3\" or \"4\", if -t/--type option is present" >&2
          return 1
        fi
        shift 2
        continue
        ;;
      -x|--top-off)
        top_off=1
        shift
        continue
        ;;
      -c|--cmd)
        if [[ -z "$2" ]]; then
          echo "[ERROR] command is necessary, if -c/--cmd option is present" >&2
          return 1
        fi
        cmd="$2"
        shift 2
        continue
        ;;
      --)
        shift
        break
        ;;
      -*)
        echo "[ERROR] Unknown option: $1" >&2
        return 1
        ;;
      *)
        break
        ;;
    esac
  done

  echo "[INFO] Start making tmux named \"$tmux_window_name\""

  tmux new -s "$tmux_window_name" -d

  if [[ "$window_type" == "1" ]]; then
    tmux split-window -h
    tmux split-window -v
    tmux split-window -v
    tmux select-pane -t 0
    tmux split-window -v
    tmux select-pane -t 2 && tmux resize-pane -D 35
    tmux select-pane -t 4 && tmux resize-pane -D 8
    if [[ $top_off -eq 0 ]]; then
      tmux send-keys -t 4 "top" C-m
    fi
    tmux select-pane -t 0

    if [[ -n "$cmd" ]]; then
      for i in {0..4}; do
        if [[ "$i" -eq 4 && $top_off -eq 0 ]]; then
          break
        fi
        tmux send-keys -t "$i" "$cmd" C-m
      done
    fi
  fi

  if [[ "$window_type" == "2" ]]; then
    tmux split-window -h
    tmux split-window -v
    tmux select-pane -t 0
    tmux split-window -v
    if [[ $top_off -eq 0 ]]; then
      tmux send-keys -t 3 "top" C-m
    fi
    tmux select-pane -t 0

    if [[ -n "$cmd" ]]; then
      for i in {0..3}; do
        if [[ "$i" -eq 3 && $top_off -eq 0 ]]; then
          break
        fi
        tmux send-keys -t "$i" "$cmd" C-m
      done
    fi
  fi

  if [[ "$window_type" == "3" ]]; then
    tmux split-window -h
    tmux select-pane -t 0
    if [[ -n "$cmd" ]]; then
      for i in {0..1}; do
        tmux send-keys -t "$i" "$cmd" C-m
      done
    fi
  fi

  if [[ "$window_type" == "4" ]]; then
    tmux split-window -v
    tmux select-pane -t 0
    if [[ -n "$cmd" ]]; then
      for i in {0..1}; do
        tmux send-keys -t "$i" "$cmd" C-m
      done
    fi
  fi

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
