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
#==================================================
