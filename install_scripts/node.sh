#!/bin/bash
set -e

VERSION="24.13.0"
VERSION_LATEST="$(echo $VERSION | cut -d '.' -f 1).x"

OS="$(uname)"
OS="$(echo $OS | tr '[:upper:]' '[:lower:]')"
CPU="$(uname -m)"

URL="https://nodejs.org/download/release/latest-v${VERSION_LATEST}/node-v${VERSION}-${OS}-${CPU}.tar.gz"
wget $URL
tar -xvzf $(basename $URL)
rm -rf $(basename $URL)

ln -s ${PWD}/node-v${VERSION}-${OS}-${CPU}/bin/* $HOME/works/bin

echo done
