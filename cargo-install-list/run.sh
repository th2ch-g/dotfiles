#!/bin/sh
cat list.txt | while IFS= read -r line;
do
    if [[ $line =~ "https" ]]; then
        cargo install --git $line
    else
        cargo install $line
    fi
done \
    && echo "[INFO] cargo-install-list done" >&1
