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
  - [Update](#update)
    - [Simple](#simple)
    - [Overwrite](#overwrite)
    - [Submodule update](#submodule-update)
  - [Contents](#contents)

## Install
### For me
~~~
git clone --recursive -j 8 https://github.com/th2ch-g/dotfiles.git && \
cd ./dotfiles && \
./install.sh --link
~~~

### For Guest
~~~
git clone --recursive -j 8 https://github.com/th2ch-g/dotfiles.git && \
cd ./dotfiles && \
./install.sh --zsh --vim --tmux
~~~

### From Dockerfile
If you want to use as guest, change Dockerfile
~~~
git clone --recursive -j 8 https://github.com/th2ch-g/dotfiles.git && \
cd ./dotfiles && \
docker image build -t myenv:latest dotfiles/docker && \
docker run -it -d --name myenv $(docker images | grep myenv | awk '{print $1}') && \
docker exec -it $(docker ps | grep myenv | awk '{print $1}') zsh
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
