#==================================================
export XDG_DATA_HOME=$HOME/.local/share/
export XDG_CONFIG_HOME=$HOME/.config/
export XDG_STATE_HOME=$HOME/.local/state/
export XDG_CACHE_HOME=$HOME/.cache/
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/works/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export TERMINFO=/usr/share/terminfo # for tmux
## by xdg-ninja
export CONFIG="$XDG_CONFIG_HOME"
export HISTFILE="$XDG_CONFIG_HOME/zsh/history"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export WORKS="$HOME/works/"
export TOOLS="$WORKS/tools/"
export SHARE="$WORKS/share/"
export MISC="$WORKS/misc/"
export BIN="$WORKS/bin/"
export EDITOR="vim"
export VIM_AI=1 # ON

if [[ ( "$SHLVL" -eq 1 && ! -o LOGIN ) && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
    source "${ZDOTDIR:-$HOME}/.zprofile"
fi

# local specific file
if [ -e ${ZDOTDIR:-$HOME}.zshenv_local ]; then
    source ${ZDOTDIR:-$HOME}/.config/.zshenv_local
fi
#==================================================
