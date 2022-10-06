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
git pull origin main
~~~

- Force overwriting
~~~
git fetch origin main && \
git reset --hard origin/main
~~~


## Contents
- vim (>= v8.2 tested)
    - vim-plug
    - vscode, atom theme
- zsh (>= v5.8 tested)
    - prezto
        - pure
- tmux (>= 3.0a tested)
- iterm2
- mytools
- brew
- cargo
- others
    - [vim.install](others/vim.install.sh)
    - [zsh.install](others/zsh.install.sh)
    - [tmux.install](others/tmux.install.sh)
    - [prezto.install](others/prezto.install.sh)
    - [bash_for_zsh](others/bash_for_zsh/)
    - [vim-instant-installer](others/vim-instant-installer/)
