#==================================================
# Re-prepend custom paths after /etc/zprofile's path_helper reorders them.
# Full path setup lives in .zshenv (sourced for all zsh invocations).
path=(
    $BIN
    $HOME/.local/bin
    ${XDG_DATA_HOME:-$HOME/.local/share}/mise/shims
    $path
)
#==================================================
