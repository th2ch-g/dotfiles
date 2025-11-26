#!/bin/bash
set -eux
XDG_CONFIG_HOME=${HOME}/.config
git clone --depth 1 https://github.com/junegunn/fzf.git $XDG_CONFIG_HOME/fzf && \
$XDG_CONFIG_HOME/fzf/install
echo done
