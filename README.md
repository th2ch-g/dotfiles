# dotfiles

- [dotfiles](#dotfiles)
  - [Install](#install)
  - [Update](#update)
  - [Contents](#contents)


## Install
~~~
git clone --recursive https://github.com/th2ch-g/dotfiles.git && \
cd ./dotfiles && \
./install.sh --link
~~~

## Update
- Simple update
~~~
git pull origin master
~~~

- Force overwriting
~~~
git fetch origin master && \
git reset --hard origin/master
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
    - [vim](others/vim.install.sh)
    - [zsh](others/zsh.install.sh)
    - [tmux](others/tmux.install.sh)
    - [prezto](others/prezto.install.sh)
    - [bash](others/bash/)
    - [vim-instant-installer](others/vim-instant-installer/)
