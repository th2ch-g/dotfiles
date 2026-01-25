#!/bin/bash
# set -eux

rustup self update
rustup update

# cargo install --locked --force cargo-quickinstall
cargo install --locked --force cargo-binstall

cat list.txt | while IFS= read -r line;
do
    line_1=$(echo $line | awk '{print $1}')
    line_2=$(echo $line | awk '{print $2}')
    [[ "$line_1" =~ "#" ]] && continue
    echo "+ $line_1" >&1
    if [[ $line_1 =~ "https://" ]]; then
        if [[ $line_2 =~ "#" ]]; then
            cargo install --locked --force --git $line_1
            # cargo binstall -y --force --locked --git $line_1 $line_2
        else
            cargo install --locked --force --git $line_1 $line_2
            # cargo binstall -y --force --locked --git $line_1 $line_2
        fi
    else
        # cargo quickinstall $line_1
        cargo binstall -y --locked --force $line_1
    fi
done \
    && echo "[INFO] cargo-install-list done" >&1

