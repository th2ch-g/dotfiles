#==================================================
export EDITOR="vim"
export LANG="ja_JP.UTF-8"
# export LANG=en_US.UTF-8 # for preventing tab completion duplicate bug, default settings: ja_JP.UTF-8
export LS_COLORS='di=38;2;171;144;121' # ls color -> light brown
export PAGER='less'
export TERM="xterm-256color"
export TERMINFO=/usr/share/terminfo # for tmux
export VISUAL='vim'
export XDG_CACHE_HOME=$HOME/.cache
export XDG_CONFIG_HOME=$HOME/.config
export XDG_DATA_HOME=$HOME/.local/share
export XDG_STATE_HOME=$HOME/.local/state
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
if [[ -z "$BROWSER" && "$OSTYPE" == darwin* ]]; then
  export BROWSER='open'
fi

# custom
export CONFIG="$XDG_CONFIG_HOME"
export WORKS="$HOME/works"
export TOOLS="$WORKS/tools"
export SHARE="$WORKS/share"
export MISC="$WORKS/misc"
export BIN="$WORKS/bin"
export OTHERS="$WORKS/others"
export VIM_AI=1 # ON
export CARGO_HOME="$TOOLS/rust/cargo"
export RUSTUP_HOME="$TOOLS/rust/rustup"
export UV_NO_MODIFY_PATH=1
export PIXI_FROZEN=true
export PIXI_HOME="$TOOLS/pixi"
export PIXI_NO_PATH_UPDATE=1

# path
export PATH="$BIN:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$CARGO_HOME/bin:$PATH"
export PATH="$RUSTUP_HOME/bin:$PATH"
export PATH="$PIXI_HOME/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/sbin:$PATH"
typeset -gU cdpath fpath mailpath path
path=(
  $HOME/{,s}bin(N)
  /opt/{homebrew,local}/{,s}bin(N)
  /usr/local/{,s}bin(N)
  $path
)

# local specific file
if [ -e ${ZDOTDIR:-$HOME/.config/zsh}/.zshenv_local ]; then
    source ${ZDOTDIR:-$HOME/.config/zsh}/.zshenv_local
fi
#==================================================
