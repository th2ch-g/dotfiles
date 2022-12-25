#!/bin/bash
cat list.txt | while IFS= read -r line;
do
    if [[ $line =~ "https" ]]; then
        cargo install --locked --git $line
    else
        cargo install --locked $line
    fi
done \
    && echo "[INFO] cargo-install-list done" >&1
