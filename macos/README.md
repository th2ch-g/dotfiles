# macOS

Apply macOS `defaults` (Dock, keyboard, trackpad, screenshots, sound, etc.).
The `--dockutil` flag additionally rebuilds the Dock via `dockutil`; install
it first (`brew "dockutil"`) and keep Homebrew on `PATH`.

```bash
export PATH="/opt/homebrew/bin:$PATH"
./run.sh --dockutil
```

Invoked by `./install.sh --macos` (which passes `--dockutil`).
