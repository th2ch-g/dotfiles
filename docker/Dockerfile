FROM ubuntu:latest
RUN apt-get update \
        && apt-get install -y autoconf curl git zsh bash make gcc ncurses-dev vim tmux pkg-config \
        && apt install -y locales-all

RUN mkdir -p ~/works \
        && cd ~/works \
        && git clone --recursive -j 8 https://github.com/th2ch-g/dotfiles.git \
        && cd ./dotfiles \
        && ./install.sh --link \
        && ./install.sh --mytools


RUN chsh -s /bin/zsh
