#!/bin/bash
set -e

cat list.txt | grep -v "^#" | while IFS= read -r line;
do
    echo "Run: ${line}"
    $line
done


echo done
