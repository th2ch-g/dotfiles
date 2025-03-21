#==================================================
export XDG_DATA_HOME=$HOME/.local/share/
export XDG_CONFIG_HOME=$HOME/.config/
export XDG_STATE_HOME=$HOME/.local/state/
export XDG_CACHE_HOME=$HOME/.cache/
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/works/bin:$PATH"
export LD_LIBRARY_PATH="$HOME/works/tools/lib:$LD_LIBRARY_PATH" # for tmux
export TERMINFO=/usr/share/terminfo # for tmux
## by xdg-ninja
export HISTFILE="$HOME/.config/zsh/history"
export ZDOTDIR="$HOME/.config/zsh"

if [[ ( "$SHLVL" -eq 1 && ! -o LOGIN ) && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
    source "${ZDOTDIR:-$HOME}/.zprofile"
fi

# local specific file
if [ -e $HOME/.config/.zshenv_local ]; then
    source $HOME/.config/.zshenv_local
fi
#==================================================
