# dotfiles

![last-commit](https://img.shields.io/github/last-commit/th2ch-g/dotfiles)
![license](https://img.shields.io/github/license/th2ch-g/dotfiles)
![repo-size](https://img.shields.io/github/repo-size/th2ch-g/dotfiles)

<!-- TOC GFM -->

- [Install](#install)
  - [Quick start (interactive)](#quick-start-interactive)
  - [For me](#for-me)
  - [For Guest](#for-guest)
  - [From Dockerfile](#from-dockerfile)
    - [Case1: Pull from ghcr](#case1-pull-from-ghcr)
    - [Case2: Build locally](#case2-build-locally)
- [set-url for commit](#set-url-for-commit)
- [Update](#update)
- [Add release](#add-release)
- [Delete release (not recommended)](#delete-release-not-recommended)
- [Development setup](#development-setup)

<!-- /TOC -->

## Install

### Quick start (interactive)

Bootstrap with a single `curl ... | bash` command (rustup-style). It prompts for
how to fetch the repo, an install profile, and optional developer setup, then
delegates to `link.sh` / `install.sh`:

```shell
curl -fsSL https://raw.githubusercontent.com/th2ch-g/dotfiles/main/setup.sh | bash
```

- Fetch method: `HTTPS clone`, `SSH clone`, or `ZIP download` (no git history —
  the "without git" path).
- Profiles: `full` (everything for this machine), `standard` (core tools),
  `guest` (link-only), or `customize` (toggle each component).
- Prerequisites: missing `git` / `zsh` / `unzip` can be installed on the spot
  after a confirmation prompt (Linux: apt/dnf/pacman/zypper/apk via sudo;
  macOS: `xcode-select --install`).
- Developer setup (git checkouts only): optionally switch `origin` to SSH and
  run `make setup` (pre-commit hooks).
- Install location: defaults to `~/works/dotfiles`; override with
  `SETUP_DIR=/path/to/dir` or by typing a path at the interactive prompt.
- Non-interactive (CI / containers): set `SETUP_PROFILE=full|standard|guest`
  (and optionally `SETUP_FETCH=https|ssh|zip`), e.g.
  `curl -fsSL .../setup.sh | SETUP_PROFILE=standard bash`.
- The manual one-liners below remain available and produce the same result.

### For me

- Bootstrap Installation on local
  - Prerequisite: git, zsh (check by `git --version && zsh --version`)
    - macos: `xcode-select --install`
      - **DO NOT** launch zsh in other terminal until the installation is done
        (up to brew) because of OpenSSL issue
    - linux: `sudo apt install zsh git` or manually install by
      `install_scripts/`

```shell
mkdir -p ${HOME}/works && \
cd ${HOME}/works && \
git clone https://github.com/th2ch-g/dotfiles.git && \
cd ./dotfiles && \
./link.sh --zsh && \
./install.sh --pixi --pixi-pkgs --uv --cargo --cargo-pkgs --brew --brew-pkgs --warpd --claude-code --codex --python3 --gh-ext --iterm2 --macos && \
./link.sh --git --tmux --vim --neovim --ssh --aerospace && \
git remote set-url origin git@github.com:th2ch-g/dotfiles.git && \
make setup
```

- Install on local via SSH

```shell
mkdir -p ${HOME}/works && \
cd ${HOME}/works && \
git clone git@github.com:th2ch-g/dotfiles.git && \
cd ./dotfiles && \
./link.sh --git --zsh --tmux --vim --neovim --ssh --aerospace && \
./install.sh --pixi --pixi-pkgs --uv --cargo --cargo-pkgs --claude-code --codex --python3
```

- Install on local via HTTPS

```shell
mkdir -p ${HOME}/works && \
cd ${HOME}/works && \
git clone https://github.com/th2ch-g/dotfiles.git && \
cd ./dotfiles && \
./link.sh --git --zsh --tmux --vim --neovim --ssh --aerospace && \
./install.sh --pixi --pixi-pkgs --uv --cargo --cargo-pkgs --claude-code --codex --python3
```

- Install without git

```shell
mkdir -p ${HOME}/works && \
wget https://github.com/th2ch-g/dotfiles/archive/refs/heads/main.zip && \
unzip main.zip && \
rm main.zip && \
mv dotfiles-main dotfiles && \
cd ./dotfiles && \
./link.sh --git --zsh --tmux --vim --neovim --ssh --aerospace && \
./install.sh --pixi --pixi-pkgs --uv --cargo --cargo-pkgs --claude-code --codex --python3
```

### For Guest

```shell
git clone https://github.com/th2ch-g/dotfiles.git && \
cd ./dotfiles && \
./link.sh --zsh --vim --tmux --neovim
```

### From Dockerfile

#### Case1: Pull from ghcr

```shell
docker pull --platform linux/amd64 ghcr.io/th2ch-g/dotfiles:latest
docker run --platform linux/amd64 --rm -it ghcr.io/th2ch-g/dotfiles
```

#### Case2: Build locally

```shell
git clone https://github.com/th2ch-g/dotfiles.git && \
cd ./dotfiles && \
docker image build -t myenv . && \
docker run --rm -it myenv
```

## set-url for commit

```shell
make s
```

## Update

```shell
make u
```

## Add release

```bash
make r
```

## Delete release (not recommended)

```bash
make delete-release TAG=vYYYY.MM.DD
```

## Development setup

Activate pre-commit hooks after cloning:

```bash
make setup
```

Run all linters/formatters manually:

```bash
make l
```
