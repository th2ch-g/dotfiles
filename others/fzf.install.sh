#!/bin/bash
set -e
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && \
~/.fzf/install
echo done
