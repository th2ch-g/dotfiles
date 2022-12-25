#!/bin/bash
#cargo install --list | grep ":" | cut -d " " -f 1 > list.txt && echo "[INFO] Update cargo install --list done" >&1
cargo install --list | grep ":"  \
    | awk '{split($0, arr, " "); if(length(arr) == 2){print $1} else{tmp = substr($3, 2, length($3)-3); split(tmp, arr2, "#"); print arr2[1]}}' > list.txt \
    && echo "[INFO] Update cargo install --list done" >&1

