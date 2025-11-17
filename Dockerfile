FROM ubuntu:latest
RUN apt-get update \
        && apt-get install -y \
        autoconf \
        bash \
        cmake \
        curl \
        gcc \
        gettext \
        git \
        make \
        ncurses-dev \
        neovim \
        pkg-config \
        tmux \
        vim \
        wget \
        zsh \
        && apt install -y locales-all
RUN chsh -s /bin/zsh

# vim: /usr/bin/vim.basic because of alternative system
RUN ln -sf /usr/bin/vim.basic /usr/bin/vim

RUN mkdir -p \
        /root/works/dotfiles \
        /root/works/dotfiles/install_scripts \
        /root/works/tools \
        /root/works/bin \
        /root/works/share \
        /root/works/misc \
        /root/works/others

WORKDIR /root/works/dotfiles
COPY install_scripts/ /root/works/dotfiles/install_scripts/

WORKDIR /root/works/tools
RUN ../dotfiles/install_scripts/nvim.sh
RUN ../dotfiles/install_scripts/vim.sh
WORKDIR /root/works/bin
RUN ln -s /root/works/tools/neovim-*/build/bin/nvim .
RUN ln -s /root/works/tools/vim-*/build/bin/vim .

WORKDIR /root/works/dotfiles
COpy . .
RUN ./link.sh --git --zsh --tmux --vim --neovim --ssh --alacritty

# skip cargo/python install for saving time
WORKDIR /root/works
CMD ["/bin/zsh", "-c", "echo 'This example container. Some features are not available.' && zsh"]
