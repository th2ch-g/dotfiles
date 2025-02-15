#!/bin/bash
cargo install cargo-quickinstall
cat list.txt | while IFS= read -r line;
do
    line_1=$(echo $line | awk '{print $1}')
    [[ "$line_1" =~ "#" ]] && continue
    if [[ $line_1 =~ "https://" ]]; then
        cargo install --locked --git $line_1
    else
        cargo quickinstall $line_1
    fi
done \
    && echo "[INFO] cargo-install-list done" >&1
