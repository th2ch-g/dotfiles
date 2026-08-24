#==================================================
# Re-prepend custom paths after /etc/zprofile's path_helper reorders them.
# Full path setup lives in .zshenv (sourced for all zsh invocations).
path=(
    $BIN
    $HOME/.local/bin
    $CARGO_HOME/bin
    $RUSTUP_HOME/bin
    $PIXI_HOME/bin
    $path
)

# /etc/zprofile has already run. Avoid the duplicate macOS interactive setup;
# Apple Terminal still needs its global zshrc for session integration.
if [[ $OSTYPE == darwin* && ${TERM_PROGRAM:-} != Apple_Terminal && -o interactive ]]; then
    unsetopt GLOBAL_RCS
fi
#==================================================
