#!/bin/bash
set -eux

cat list.txt | grep -v "^#" | while IFS= read -r line;
do
    $line
done

echo done
