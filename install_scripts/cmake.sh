#!/bin/bash
set -eux

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

VERSION="3.31.6"
BIN=${BIN:-$HOME/works/bin}
OS_NAME="$(uname -s)"
CPU="$(uname -m)"

case "$OS_NAME" in
    Darwin)
        ARCHIVE_PLATFORM="macos-universal"
        ;;
    Linux)
        case "$CPU" in
            x86_64 | amd64)
                ARCHIVE_PLATFORM="linux-x86_64"
                ;;
            aarch64 | arm64)
                ARCHIVE_PLATFORM="linux-aarch64"
                ;;
            *)
                print_error "Unsupported architecture for CMake binary: $CPU"
                exit 1
                ;;
        esac
        ;;
    *)
        print_error "Unsupported OS for CMake binary: $OS_NAME"
        exit 1
        ;;
esac

ARCHIVE="cmake-${VERSION}-${ARCHIVE_PLATFORM}.tar.gz"
EXTRACT_DIR="cmake-${VERSION}-${ARCHIVE_PLATFORM}"

[ -d "$EXTRACT_DIR" ] && { print_info "$EXTRACT_DIR already present, skipping"; exit 0; }

URL="https://github.com/Kitware/CMake/releases/download/v${VERSION}/${ARCHIVE}"
curl -fL -o "$ARCHIVE" "$URL"
tar -xvzf "$ARCHIVE"
rm -f "$ARCHIVE"

if [ -d "${PWD}/${EXTRACT_DIR}/bin" ]; then
    BIN_DIR="${PWD}/${EXTRACT_DIR}/bin"
elif [ -d "${PWD}/${EXTRACT_DIR}/CMake.app/Contents/bin" ]; then
    BIN_DIR="${PWD}/${EXTRACT_DIR}/CMake.app/Contents/bin"
else
    print_error "CMake binary directory was not found in ${EXTRACT_DIR}"
    exit 1
fi

for f in "${BIN_DIR}/"*; do
    ensure_bin "$f"
done

print_info "cmake install done"
