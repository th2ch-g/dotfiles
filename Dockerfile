FROM ubuntu:latest

# Minimal base: pixi global provides the CLIs (git, vim, nvim, tmux, less,
# imagemagick, autoconf, cmake, node, etc.) from conda-forge, so apt only
# needs the bootstrap toolchain. zsh is kept from apt to act as the login
# shell (chsh below); the pixi zsh stays on PATH for interactive use.
RUN apt-get update \
        && apt-get install -y \
        bash \
        build-essential \
        ca-certificates \
        curl \
        git \
        locales-all \
        zsh \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/works/dotfiles

# for zsh
# Link zsh config before install.sh so that env vars in zshenv (e.g. PATH)
# are available when install.sh runs. Also run zsh once to initialize sheldon.
WORKDIR /root/works/dotfiles
COPY ./lib/ ./lib
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
COPY ./pixi ./pixi
COPY ./python3 ./python3
COPY ./cargo ./cargo
# Install pixi/uv/cargo, then sync the pixi global manifest. --pixi-pkgs
# installs every tool in pixi/pixi-global.toml (git, vim, nvim, tmux, zsh,
# less, imagemagick, autoconf, cmake, node + wget, gh, tor, typst, rclone,
# htop, vhs, fzf).
RUN ./install.sh \
        --cargo \
        --pixi \
        --pixi-pkgs \
        --python3 \
        --uv \
        --claude-code
        # Skipped in the container image:
        # --brew --brew-pkgs --macos --iterm2 --warpd  # macOS only
        # --gemini-cli --supertuxkart --conda  # not needed here
        # --mold  # Linux linker, wild is the alternative
        # --password-store  # no conda-forge package
        # --cargo-pkgs  # takes too long

# copy remain
WORKDIR /root/works/dotfiles
COPY . .
RUN ./link.sh --git --tmux --vim --neovim --ssh --alacritty

# vim ai off
RUN echo "export VIM_AI=0" >> /root/works/dotfiles/zsh/.zshenv_local

# skip cargo/python install for saving time
WORKDIR /root/works
CMD ["/bin/zsh", "-c", "echo 'This example container. Some features are not available.' && zsh"]
