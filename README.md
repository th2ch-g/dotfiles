# dotfiles
![last-commit](https://img.shields.io/github/last-commit/th2ch-g/dotfiles)
![license](https://img.shields.io/github/license/th2ch-g/dotfiles)
![repo-size](https://img.shields.io/github/repo-size/th2ch-g/dotfiles)
![CI](https://github.com/th2ch-g/dotfiles/actions/workflows/CI.yaml/badge.svg)

![example](others/example.png)

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
~~~shell
git clone --recursive -j 8 https://github.com/th2ch-g/dotfiles.git && \
cd ./dotfiles && \
./install.sh --link
~~~

### For Guest
~~~shell
git clone --recursive -j 8 https://github.com/th2ch-g/dotfiles.git && \
cd ./dotfiles && \
./install.sh --zsh --vim --tmux
~~~

### From Dockerfile
#### Case1: Pull from ghcr
~~~shell
docker pull ghcr.io/th2ch-g/dotfiles:latest
docker run --rm -it ghcr.io/th2ch-g/dotfiles zsh
~~~

#### Case2: Build locally
- If you want to use as guest, change Dockerfile
~~~shell
git clone --recursive -j 8 https://github.com/th2ch-g/dotfiles.git && \
docker image build -t myenv dotfiles/docker && \
docker run --rm -it myenv zsh
~~~

## Update
### Simple
~~~
git pull origin main
~~~

### Overwrite
~~~
git fetch origin main && \
git reset --hard origin/main
~~~

### Submodule update
~~~
git submodule update --remote <submodule_path>
~~~

## Contents
- vim (>= v8.2 tested)
- zsh (>= v5.8 tested)
- tmux (>= 3.0a tested)
- iterm2
- mytools
- brew
- cargo
- docker
- others
