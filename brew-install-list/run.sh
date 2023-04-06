#!/bin/bash
set -e
cat list.txt | grep -v "#" | while IFS= read -r line; do brew install $line; done && echo "[INFO] brew-install-list done" >&1
