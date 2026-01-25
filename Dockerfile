FROM ubuntu:latest
RUN apt-get update \
        && apt-get install -y \
        autoconf \
        bash \
        build-essential \
        cmake \
        curl \
        gcc \
        gettext \
        git \
        make \
        ncurses-dev \
        neovim \
        pkg-config \
        imagemagick \
        tmux \
        vim \
        wget \
        zsh \
        && apt install -y locales-all \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

# vim: /usr/bin/vim.basic because of alternative system
RUN ln -sf /usr/bin/vim.basic /usr/bin/vim

RUN mkdir -p /root/works/dotfiles

# for zsh
WORKDIR /root/works/dotfiles
COPY ./link.sh .
COPY ./zsh ./zsh
COPY ./sheldon/ ./sheldon
RUN ./link.sh --zsh
RUN zsh -i -c exit
RUN chsh -s /bin/zsh

# for layer cache
WORKDIR /root/works/dotfiles
COPY ./install_scripts ./install_scripts
COPY ./install.sh .
COPY ./python3 ./python3
COPY ./cargo ./cargo
RUN ./install.sh --test # for using ENV in zshenv

# copy remain
WORKDIR /root/works/dotfiles
COPY . .
RUN ./link.sh --git --tmux --vim --neovim --ssh --alacritty

# vim ai off
RUN echo "export VIM_AI=0" >> /root/works/dotfiles/zsh/.zshenv_local

# skip cargo/python install for saving time
WORKDIR /root/works
CMD ["/bin/zsh", "-c", "echo 'This example container. Some features are not available.' && zsh"]
