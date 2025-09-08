#!/bin/bash
set -e

if command -v pixi >/dev/null 2>&1; then
    echo "pixi is already installed"
else
    echo "pixi is not installed"
    echo "run first: ./install.sh --cargo"
    echo "or run:"
    PIXI_VERSION="v0.50.2"
    if [ $OS == "Mac" ]; then
        if [[ $arch == "x86_64" || $arch == "amd64" ]]; then
            echo "wget https://github.com/prefix-dev/pixi/releases/download/${PIXI_VERSION}/pixi-x86_64-apple-darwin.tar.gz"
        elif [[ $arch == "aarch64" || $arch == "arm64" ]]; then
            echo "wget https://github.com/prefix-dev/pixi/releases/download/${PIXI_VERSION}/pixi-aarch64-apple-darwin.tar.gz"
        else
            echo "Unknown architecture"
            echo "open https://github.com/prefix-dev/pixi/releases"
            exit 1
        fi
    fi
    if [ $OS == "Linux" ]; then
        if [[ $arch == "x86_64" || $arch == "amd64" ]]; then
            echo "wget https://github.com/prefix-dev/pixi/releases/download/${PIXI_VERSION}/pixi-x86_64-unknown-linux-musl.tar.gz"
        elif [[ $arch == "aarch64" || $arch == "arm64" ]]; then
            echo "wget https://github.com/prefix-dev/pixi/releases/download/${PIXI_VERSION}/pixi-aarch64-unknown-linux-musl.tar.gz"
        else
            echo "Unknown architecture"
            echo "open https://github.com/prefix-dev/pixi/releases"
            exit 1
        fi
    fi
fi

echo done
