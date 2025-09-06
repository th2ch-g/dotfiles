#!/bin/bash
set -e

if ! command -v brew > /dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    export PATH="/opt/homebrew/bin:$PATH"
else
    echo "brew is already installed"
fi

# run: brew bundle in brew/

echo done
