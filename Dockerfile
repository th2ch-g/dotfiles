FROM ubuntu:latest

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV DOTFILES_DIR="/root/works/dotfiles" \
    MISE_AUTO_ENV="true" \
    MISE_ENV="container" \
    PATH="/root/.local/bin:/root/.local/share/mise/shims:${PATH}"
RUN curl -fsSL https://mise.run \
    | MISE_INSTALL_PATH=/root/.local/bin/mise MISE_VERSION=v2026.8.3 sh

WORKDIR /root/works/dotfiles
COPY . .

RUN mise trust --all --yes --cd /root/works/dotfiles \
    && mise bootstrap --yes --cd /root/works/dotfiles --skip task

CMD ["/bin/zsh", "-c", "echo 'This is the dotfiles example container.' && exec zsh"]
