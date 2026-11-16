if [ -t 0 ]; then
    stty stop undef
    [ -x /bin/zsh ] && exec /bin/zsh
fi
