# dotfiles

![last-commit](https://img.shields.io/github/last-commit/th2ch-g/dotfiles)
![license](https://img.shields.io/github/license/th2ch-g/dotfiles)
![repo-size](https://img.shields.io/github/repo-size/th2ch-g/dotfiles)

<!-- TOC GFM -->

- [Install](#install)
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

### For me

- Bootstrap Installation on local
  - Prerequisite: git, zsh (check by `git --version && zsh --version`)
    - macos: `xcode-select --install`
      - **DO NOT** launch zsh in other terminal until the installation is done
        (up to brew) because of OpenSSL issue
    - linux: `sudo apt install zsh git` or manually install by
      `install_scripts/`

~~~shell
mkdir -p ${HOME}/works && \
cd ${HOME}/works && \
git clone https://github.com/th2ch-g/dotfiles.git && \
cd ./dotfiles && \
./link.sh --zsh && \
./install.sh --pixi --uv --cargo --cargo-pkgs --brew --brew-pkgs --warpd --claude-code --python3 --iterm2 --macos && \
./link.sh --git --tmux --vim --neovim --ssh --aerospace && \
git remote set-url origin git@github.com:th2ch-g/dotfiles.git && \
pre-commit install
~~~

- Install on local via SSH

~~~shell
mkdir -p ${HOME}/works && \
cd ${HOME}/works && \
git clone git@github.com:th2ch-g/dotfiles.git && \
cd ./dotfiles && \
./link.sh --git --zsh --tmux --vim --neovim --ssh --aerospace && \
./install.sh --pixi --uv --cargo --cargo-pkgs --claude-code --python3
~~~

- Install on local via HTTPS

~~~shell
mkdir -p ${HOME}/works && \
cd ${HOME}/works && \
git clone https://github.com/th2ch-g/dotfiles.git && \
cd ./dotfiles && \
./link.sh --git --zsh --tmux --vim --neovim --ssh --aerospace && \
./install.sh --pixi --uv --cargo --cargo-pkgs --claude-code --python3
~~~

- Install without git

~~~shell
mkdir -p ${HOME}/works && \
wget https://github.com/th2ch-g/dotfiles/archive/refs/heads/main.zip && \
unzip main.zip && \
rm main.zip && \
mv dotfiles-main dotfiles && \
cd ./dotfiles && \
./link.sh --git --zsh --tmux --vim --neovim --ssh --aerospace && \
./install.sh --pixi --uv --cargo --cargo-pkgs --claude-code --python3
~~~

### For Guest

~~~shell
git clone https://github.com/th2ch-g/dotfiles.git && \
cd ./dotfiles && \
./link.sh --zsh --vim --tmux --neovim
~~~

### From Dockerfile

#### Case1: Pull from ghcr

~~~shell
docker pull --platform linux/amd64 ghcr.io/th2ch-g/dotfiles:latest
docker run --platform linux/amd64 --rm -it ghcr.io/th2ch-g/dotfiles
~~~

#### Case2: Build locally

~~~shell
git clone https://github.com/th2ch-g/dotfiles.git && \
cd ./dotfiles && \
docker image build -t myenv . && \
docker run --rm -it myenv
~~~

## set-url for commit

~~~shell
make s
~~~

## Update

~~~shell
make u
~~~

## Add release

~~~bash
make r
~~~

## Delete release (not recommended)

~~~bash
make delete TAG=vYYYY.MM.DD
~~~

## Development setup

Activate pre-commit hooks after cloning:

~~~bash
make setup
~~~

Run all linters/formatters manually:

~~~bash
make l
~~~
