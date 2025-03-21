FROM ubuntu:latest
RUN apt-get update \
        && apt-get install -y autoconf curl git zsh bash make gcc ncurses-dev vim neovim tmux pkg-config \
        && apt install -y locales-all

# vim: /usr/bin/vim.basic because of alternative system
RUN ln -sf /usr/bin/vim.basic /usr/bin/vim

RUN mkdir -p ~/works \
        && cd ~/works \
        && git clone --depth 1 --branch dev/nvim --recursive -j 8 https://github.com/th2ch-g/dotfiles.git \
        && cd ./dotfiles \
        && ./install.sh -c -v -z -t -g -n

RUN chsh -s /bin/zsh

# install cargo subcommands
RUN cd ~/works/dotfiles && ./install.sh -c
