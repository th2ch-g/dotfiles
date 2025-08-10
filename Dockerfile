FROM ubuntu:latest
RUN apt-get update \
        && apt-get install -y autoconf curl git zsh bash make gcc ncurses-dev vim neovim tmux pkg-config \
        && apt install -y locales-all

# vim: /usr/bin/vim.basic because of alternative system
RUN ln -sf /usr/bin/vim.basic /usr/bin/vim

RUN mkdir -p ~/works \
        && cd ~/works \
        && git clone --branch main --recursive https://github.com/th2ch-g/dotfiles.git \
        && cd ./dotfiles \
        && ./install.sh --git --zsh --tmux --vim --neovim --alacrity --ssh

# `git clone --depth 1 -j 8 --filter=blob:none` will be slower and bigger

RUN chsh -s /bin/zsh

# skip this for saving time
# it takes longer time and generates errors
# RUN cd ~/works/dotfiles && ./install -c -p

CMD ["/bin/zsh", "-c", "vim -c PlugInstall -c qa && echo 'Run: prepare_all && ./install.sh --cargo --pixi' && zsh"]
