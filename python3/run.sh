#!/bin/bash
set -e

cat requirements.txt | while IFS= read -r line;
do
    line_1=$(echo $line | awk '{print $1}')
    line_2=$(echo $line | awk '{print $2}')
    [[ "$line_1" =~ "#" ]] && continue
    echo "+ $line_1" >&1
    uv tool install $line_1
done

echo done
