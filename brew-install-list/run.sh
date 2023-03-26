#!/bin/bash
set -e
cat list.txt | while IFS= read -r line; do [[ "$line" =~ "#" ]] && continue; brew install $line; done && echo "[INFO] brew-install-list done" >&1
