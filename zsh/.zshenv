#==================================================
export CARGO_HOME="$HOME/.cargo/"
export CLICOLOR=1
export EDITOR="vim"
export GPG_TTY=$(tty)
export HISTSIZE=100000
export LANG="ja_JP.UTF-8"
# export LANG=en_US.UTF-8 # for preventing tab completion duplicate bug, default settings: ja_JP.UTF-8
export LS_COLORS='di=38;2;171;144;121' # ls color -> light brown
export PAGER='less'
export SAVEHIST=100000000
export TERM="xterm-256color"
export TERMINFO=/usr/share/terminfo # for tmux
export VISUAL='vim'
export XDG_CACHE_HOME=$HOME/.cache/
export XDG_CONFIG_HOME=$HOME/.config/
export XDG_DATA_HOME=$HOME/.local/share/
export XDG_STATE_HOME=$HOME/.local/state/
export LESS='-g -i -M -R -S -w -X -z-4'
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
if [[ -z "$BROWSER" && "$OSTYPE" == darwin* ]]; then
  export BROWSER='open'
fi
if [[ -z "$LESSOPEN" ]] && (( $#commands[(i)lesspipe(|.sh)] )); then
  export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
fi

# custom
export CONFIG="$XDG_CONFIG_HOME"
export HISTFILE="$XDG_CONFIG_HOME/zsh/history"
export WORKS="$HOME/works/"
export TOOLS="$WORKS/tools/"
export SHARE="$WORKS/share/"
export MISC="$WORKS/misc/"
export BIN="$WORKS/bin/"
export OTHERS="$WORKS/others/"
export VIM_AI=1 # ON

# path
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$BIN:$PATH"

typeset -gU cdpath fpath mailpath path
path=(
  $HOME/{,s}bin(N)
  /opt/{homebrew,local}/{,s}bin(N)
  /usr/local/{,s}bin(N)
  $path
)

# local specific file
if [ -e ${ZDOTDIR:-$HOME}.zshenv_local ]; then
    source ${ZDOTDIR:-$HOME}/.config/.zshenv_local
fi
#==================================================
