#!/bin/bash
cat list.txt | while IFS= read -r line; do brew install $line; done && echo "[INFO] brew-install-list done" >&1
