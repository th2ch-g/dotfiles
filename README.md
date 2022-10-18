# dotfiles

- [dotfiles](#dotfiles)
  - [Install](#install)
  - [Update](#update)
  - [Contents](#contents)

## Install
~~~
git clone --recursive -j 8 https://github.com/th2ch-g/dotfiles.git && \
cd ./dotfiles && \
./install.sh --link
~~~

## Update
- Simple update
~~~
git pull origin main
~~~

- Force overwriting
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
