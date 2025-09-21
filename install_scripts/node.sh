#!/bin/bash
set -e

URL="https://nodejs.org/download/release/latest/node-v24.8.0-linux-x64.tar.gz"
wget $URL
tar -xvzf $(basename $URL)

echo done
