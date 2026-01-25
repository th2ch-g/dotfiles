# dotfiles
![last-commit](https://img.shields.io/github/last-commit/th2ch-g/dotfiles)
![license](https://img.shields.io/github/license/th2ch-g/dotfiles)
![repo-size](https://img.shields.io/github/repo-size/th2ch-g/dotfiles)

<!-- TOC GFM -->

* [Install](#install)
    * [For me](#for-me)
    * [For Guest](#for-guest)
    * [From Dockerfile](#from-dockerfile)
        * [Case1: Pull from ghcr](#case1-pull-from-ghcr)
        * [Case2: Build locally](#case2-build-locally)
* [set-url for commit](#set-url-for-commit)
* [Update](#update)
* [Add release](#add-release)
* [Delete release (not recommended)](#delete-release-not-recommended)

<!-- /TOC -->

## Install

### For me
- Bootstrap Installation on local
~~~shell
mkdir -p ${HOME}/works && \
cd ${HOME}/works && \
git clone https://github.com/th2ch-g/dotfiles.git && \
cd ./dotfiles && \
./link.sh --zsh && \
./install.sh && \
./link.sh --git --tmux --vim --neovim --ssh --yabai --skhd && \
git remote set-url origin git@github.com:th2ch-g/dotfiles.git
~~~

- Install on local via SSH
~~~shell
mkdir -p ${HOME}/works && \
cd ${HOME}/works && \
git clone git@github.com:th2ch-g/dotfiles.git && \
cd ./dotfiles && \
./link.sh --git --zsh --tmux --vim --neovim --ssh --yabai --skhd
~~~

- Install on local via HTTPS
~~~shell
mkdir -p ${HOME}/works && \
cd ${HOME}/works && \
git clone https://github.com/th2ch-g/dotfiles.git && \
cd ./dotfiles && \
./link.sh --git --zsh --tmux --vim --neovim --ssh --yabai --skhd
./install.sh
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
git remote set-url origin git@github.com:th2ch-g/dotfiles.git
~~~

## Update
~~~
git pull
~~~

## Add release
```bash
git tag -a vYYYY.MM.DD -m "message"
git push origin vYYYY.MM.DD
```

## Delete release (not recommended)
```bash
git tag -d vYYYY.MM.DD
git push origin --delete vYYYY.MM.DD
```
