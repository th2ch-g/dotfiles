#=================================================
# additional settings
# sheldon
if ! command -v sheldon &> /dev/null; then
    curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh \
        | bash -s -- --repo rossmacarthur/sheldon --to ~/.local/bin
fi
eval "$(sheldon source)"

# zoxide
if command -v zoxide > /dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

# exa
if command -v exa > /dev/null 2>&1; then
    alias ls="exa"
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
autoload -Uz compinit && compinit
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

# conda alias
alias cb="conda activate base && conda info -e"
alias ce="conda info -e"
alias cl="conda list"

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

update_dotfiles() {
    CWD=$PWD
    cd $WORKS/dotfiles
    git pull
    cd $CWD
    echo "[INFO] dotfiles is updated" >&1
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

prepare_all() {
    prepare_base_dir
    make_local_file
}

function tide() {
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
          echo "[ERROR] window_type must be \"1\", \"2\" or \"3\"" >&2
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

function ssa() {
  local USAGE='
ssa:
    search_server_availability

USAGE:
    ssa
    cat [SERVER_NAME_FILE] | ssa -f -
    ssa -f [SERVER_NAME_FILE] -t 20
    ssa --dump > ~/.ssh/server_name.txt

DESCRIPTION:
    search server availability by load average

OPTIONS:
    -h, --help          Print help
    -d, --dump          prepare server name list file
    -f, --file          specify server name list file. "-f -" means stdin.
                        [default: ~/.ssh/server_name.txt]
    -t, --thread        number of thread when ssh. [default: 8]
                        If number of thread exceeds number of logical cpu, bug may occur.
'

  local FILE="$HOME/.ssh/server_name.txt"
  local dump_flag=1
  local num_thread=8

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        echo "$USAGE"
        return 0
        ;;
      -d|--dump)
        dump_flag=0
        break
        ;;
      -f|--file)
        if [[ -z "$2" ]]; then
          echo "[ERROR] file path is necessary, if -f/--file option is present" >&2
          return 1
        fi
        FILE="$2"
        shift 2
        continue
        ;;
      -t|--thread)
        if [[ -z "$2" ]]; then
          echo "[ERROR] number of thread is necessary, if -t/--thread option is present" >&2
          return 1
        fi
        num_thread="$2"
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
    shift
  done

  # dump server name list file
  if [[ $dump_flag -eq 0 ]]; then
    grep "Host" "$HOME/.ssh/config" | grep -v "HostName" | grep -v "git" | grep -v "*" | awk '{print $2}'
    return 0
  fi

  local temp
  temp=$(mktemp)
  echo "<server> <users> <load_average>" > "$temp"
  echo "[INFO] temp file : $temp"
  echo "[INFO] number of thread is $num_thread"

  if [[ "$FILE" == "-" ]]; then
    echo "[INFO] file input is execute by stdin"
    cat - | xargs -I SERVER -P "$num_thread" ssh SERVER 'echo "$(hostname) $(uptime)"' \
      | awk '{split($0, arr, " "); for(i in arr){if(arr[i] ~ /average/){la=arr[i+1]} if(arr[i] ~ /user/){user=arr[i-1]}} print $1, user, la}' \
      | sort -n -k 1 >> "$temp"
  else
    echo "[INFO] file input is execute by path \"$FILE\""
    if [[ ! -e "$FILE" ]]; then
      echo "[ERROR] $FILE does not exist" >&2
      return 1
    fi
    cat "$FILE" | xargs -I SERVER -P "$num_thread" ssh SERVER 'echo "$(hostname) $(uptime)"' \
      | awk '{split($0, arr, " "); for(i in arr){if(arr[i] ~ /average/){la=arr[i+1]} if(arr[i] ~ /user/){user=arr[i-1]}} print $1, user, la}' \
      | sort -n -k 1 >> "$temp"
  fi

  echo "[INFO] result:"
  cat "$temp" | column -s " " -t | while IFS= read -r line; do
    echo "  $line"
  done

  echo "[INFO] recommend server (load average < 1.0)"
  cat "$temp" | column -s " " -t | awk '{if($3 < 1){print $0}}' | while IFS= read -r line; do
    echo "  $line"
  done

  echo "[INFO] clean temp file : ${temp}"
  rm -f "$temp"
}


function ssj() {
  local USAGE='
ssj:
    server_search_jobs

USAGE:
    ssj -n [TARGET_NAME] -f [FILE]

DESCRIPTION:
    This is a script to check if a job remains on the server

EXAMPLE:
    ssj -n "cargo"                  Search jobs named "cargo"
    ssj -n "$USER"                  Search jobs named "$USER"

OPTIONS:
    -h, --help                      Print help
    -n, --name [TARGET_NAME]        Target name for Search
    -f, --file [FILE]               Server name file, For stdin, use "-f -"
                                    [default: ~/.ssh/server_name.txt]
'

  local FILE="$HOME/.ssh/server_name.txt"
  local TARGET_NAME=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        echo "$USAGE"
        return 0
        ;;
      -n|--name)
        TARGET_NAME="$2"
        if [[ -z "$TARGET_NAME" ]]; then
          echo "[ERROR] target name is necessary" >&2
          return 1
        fi
        shift 2
        continue
        ;;
      -f|--file)
        FILE="$2"
        if [[ -z "$FILE" ]]; then
          echo "[ERROR] file path is necessary, if -f/--file option is present" >&2
          return 1
        fi
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
    shift
  done

  if [[ -z "$TARGET_NAME" ]]; then
    echo "[ERROR] target name is necessary" >&2
    return 1
  fi

  local server_arr
  if [[ "$FILE" == "-" ]]; then
    echo "[INFO] execute file input by stdin" >&1
    server_arr=($(cat - | xargs))
  else
    echo "[INFO] execute file input by file path \"$FILE\"" >&1
    if [[ ! -e "$FILE" ]]; then
      echo "[ERROR] $FILE not exists" >&2
      return 1
    fi
    server_arr=($(cat "$FILE" | xargs))
  fi

  for server in "${server_arr[@]}"; do
    echo "[INFO] Search $server" >&1
    ssh "$server" ps ax | grep -v "\[" | grep "$TARGET_NAME" && echo
  done

  wait && echo "[INFO] Search_Jobs_Result done" >&1
}

function tas() {
  local USAGE='
tas:
    tmux_all_server

USAGE:
    tas -c [COMMAND] -f [FILE]

DESCRIPTION:
    Run tmux locally and split the screen into 4x4.
    From there, login to the remote server and send the same command

EXAMPLE:
    tas                      Send top command
    tas -c "echo hoge"       Send "echo hoge" command

OPTIONS:
    -h, --help                  Print help
    -c, --command [COMMAND]     Message to be sent to the server [default: top]
    -f, --file [FILE]           Server name file path. For stdin, use "-f -"
                                [default: ~/.ssh/server_name.txt]
    -n, --name [WINDOW_NAME]    window name [default: tas_{COMMAND}]
'

  local COMMAND="top"
  local FILE="$HOME/.ssh/server_name.txt"
  local NAME=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        echo "$USAGE"
        return 0
        ;;
      -c|--command)
        if [[ -z "$2" ]]; then
          echo "[ERROR] command is necessary, if -c/--command option is present" >&2
          return 1
        fi
        COMMAND="$2"
        shift 2
        continue
        ;;
      -f|--file)
        if [[ -z "$2" ]]; then
          echo "[ERROR] file path is necessary, if -f/--file option is present" >&2
          return 1
        fi
        FILE="$2"
        shift 2
        continue
        ;;
      -n|--name)
        if [[ -z "$2" ]]; then
          echo "[ERROR] window name is necessary, if -n/--name option is present" >&2
          return 1
        fi
        NAME="$2"
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

  echo "[INFO] start sending command \"$COMMAND\"" >&1

  local server_arr
  if [[ "$FILE" == "-" ]]; then
    echo "[INFO] execute file input by stdin" >&1
    server_arr=($(cat - | xargs))
  else
    echo "[INFO] execute file input by file path \"$FILE\"" >&1
    if [[ ! -e "$FILE" ]]; then
      echo "[ERROR] $FILE not exists" >&2
      return 1
    fi
    server_arr=($(cat "$FILE" | xargs))
  fi

  local tmux_window_name
  if [[ -z "$NAME" ]]; then
    tmux_window_name="tas_${COMMAND}"
  else
    tmux_window_name="$NAME"
  fi
  echo "[INFO] make tmux window named \"$tmux_window_name\"" >&1

  tmux new -s "$tmux_window_name" -d

  tmux split-window -h
  tmux split-window -h
  tmux select-pane -t 0
  tmux split-window -h

  for i in 0 4 8 12; do
    tmux select-pane -t "$i"
    tmux split-window -v
    tmux select-pane -t "$i"
    tmux split-window -v
    tmux select-pane -t "$(( i + 2 ))"
    tmux split-window -v
  done

  local count=0
  for server in "${server_arr[@]}"; do
    echo "[INFO] Login server to \"$server\"" >&1
    tmux send-keys -t "$count" "ssh $server" C-m
    count=$(( count + 1 ))
  done

  sleep 3

  count=0
  for server in "${server_arr[@]}"; do
    tmux send-keys -t "$count" "$COMMAND" C-m
    count=$(( count + 1 ))
  done

  echo "[INFO] Send command to Server done" >&1
  echo "[INFO] tmux ls Result" >&1
  tmux ls

  tmux attach
}
#==================================================
