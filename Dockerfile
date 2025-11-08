FROM ubuntu:latest
RUN apt-get update \
        && apt-get install -y autoconf curl git zsh bash make gcc ncurses-dev vim neovim tmux pkg-config \
        && apt install -y locales-all

# vim: /usr/bin/vim.basic because of alternative system
RUN ln -sf /usr/bin/vim.basic /usr/bin/vim

RUN mkdir -p /root/works/dotfiles

WORKDIR /root/works/dotfiles

# `git clone --depth 1 -j 8 --filter=blob:none` will be slower and bigger
COPY . .

RUN ./link.sh --git --zsh --tmux --vim --neovim --ssh --alacritty

RUN chsh -s /bin/zsh

# skip cargo/python install for saving time

CMD ["/bin/zsh", "-c", "echo 'This example container. Some features are not available. Run: prepare_all' && zsh"]
