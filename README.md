# dotfiles
![last-commit](https://img.shields.io/github/last-commit/th2ch-g/dotfiles)
![license](https://img.shields.io/github/license/th2ch-g/dotfiles)
![repo-size](https://img.shields.io/github/repo-size/th2ch-g/dotfiles)

- [dotfiles](#dotfiles)
  - [Install](#install)
    - [For me](#for-me)
    - [For Guest](#for-guest)
    - [From Dockerfile](#from-dockerfile)
      - [Case1: Pull from ghcr](#case1-pull-from-ghcr)
      - [Case2: Build locally](#case2-build-locally)
  - [Update](#update)
    - [Simple](#simple)
    - [Overwrite](#overwrite)
    - [Submodule update](#submodule-update)
  - [Contents](#contents)

## Install

### For me
- Install on local via SSH
~~~shell
mkdir -p ${HOME}/works && \
cd ${HOME}/works && \
git clone --branch main --recursive git@github.com:th2ch-g/dotfiles.git && \
cd ./dotfiles && \
./link.sh --git --zsh --tmux --vim --neovim --ssh --yabai --skhd
~~~

- Install on local via HTTPS
~~~shell
mkdir -p ${HOME}/works && \
cd ${HOME}/works && \
git clone --branch main --recursive https://github.com/th2ch-g/dotfiles.git && \
cd ./dotfiles && \
./link.sh --git --zsh --tmux --vim --neovim --ssh --yabai --skhd
~~~

### For Guest
~~~shell
git clone --branch main --recursive https://github.com/th2ch-g/dotfiles.git && \
cd ./dotfiles && \
./link.sh --zsh --vim --tmux --neovim
~~~

### From Dockerfile
#### Case1: Pull from ghcr
~~~shell
docker pull ghcr.io/th2ch-g/dotfiles:latest
docker run --rm -it ghcr.io/th2ch-g/dotfiles
~~~

#### Case2: Build locally
~~~shell
git clone --branch main --recursive https://github.com/th2ch-g/dotfiles.git && \
cd ./dotfiles && \
docker image build -t myenv . && \
docker run --rm -it myenv
~~~

## set-url for commit
~~~shell
git remote set-url origin git@github.com:th2ch-g/dotfiles.git
~~~

## Update
~~~
git pull
~~~

# Add release
```bash
git tag -a vYYYY.MM.DD -m "message"
git push origin vYYYY.MM.DD
```

## Contents
- [vim](https://github.com/vim/vim) (>= v8.2 tested)
- [neovim](https://github.com/neovim/neovim) (>= v0.10.4 tested)
  - [lazy.nvim](https://github.com/folke/lazy.nvim)
- [zsh](https://github.com/zsh-users/zsh) (>= v5.8 tested)
- [tmux](https://github.com/tmux/tmux) (>= 3.0a tested)
- [iTerm2](https://github.com/gnachman/iTerm2)
  - [Iceberg-iTerm2](https://github.com/Arc0re/Iceberg-iTerm2)
- [Alacritty](https://github.com/alacritty/alacritty)
- [brew](https://github.com/Homebrew/brew)
- macos
  - [dockutil](https://github.com/kcrawford/dockutil)
- cargo
- docker
- others
