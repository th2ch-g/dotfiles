# dotfiles
![last-commit](https://img.shields.io/github/last-commit/th2ch-g/dotfiles)
![license](https://img.shields.io/github/license/th2ch-g/dotfiles)
![repo-size](https://img.shields.io/github/repo-size/th2ch-g/dotfiles)
![CI](https://github.com/th2ch-g/dotfiles/actions/workflows/CI.yaml/badge.svg)

![example](others/example.png)

- [dotfiles](#dotfiles)
  - [Install](#install)
    - [Install as Guest](#install-as-guest)
  - [Update](#update)
    - [Simple update](#simple-update)
    - [Force overwriting](#force-overwriting)
  - [Contents](#contents)

## Install
~~~
git clone --recursive -j 8 https://github.com/th2ch-g/dotfiles.git && \
cd ./dotfiles && \
./install.sh --link
~~~

### Install as Guest
~~~
git clone --recursive -j 8 https://github.com/th2ch-g/dotfiles.git && \
cd ./dotfiles && \
./install.sh --zsh --vim --tmux
~~~

## Update
### Simple update
~~~
git pull origin main
~~~

### Force overwriting
~~~
git fetch origin main && \
git reset --hard origin/main
~~~

## Contents
- vim (>= v8.2 tested)
- zsh (>= v5.8 tested)
- tmux (>= 3.0a tested)
- iterm2
- mytools
- brew
- cargo
- others
