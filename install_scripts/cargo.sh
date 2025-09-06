
#!/bin/bash
set -e

if ! command -v cargo > /dev/null 2>&1; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    export PATH="${HOME}/.cargo/bin:$PATH"
else
    echo "cargo is already installed"
fi

echo done
