# macOS

Apply macOS `defaults` (Dock, keyboard, trackpad, screenshots, sound, etc.).
The `--dockutil` flag additionally rebuilds the Dock via `dockutil`; install
it first (`brew "dockutil"`) and keep Homebrew on `PATH`.

```bash
export PATH="/opt/homebrew/bin:$PATH"
./run.sh --dockutil
```

Invoked by `./install.sh --macos` (which passes `--dockutil`).

Login startup for AeroSpace, iTerm2, Google Chrome, Slack, and XQuartz is
configured with [loginitems](https://github.com/OJFord/loginitems), installed
from `brew/Brewfile`. Application paths are discovered by bundle identifier;
missing apps are skipped and existing login items are reused.

To configure only login startup, run from the repository root:

```bash
./macos/run.sh --login-items-only
loginitems -l
```

The terminal running the script needs permission to automate System Events.
If macOS denies access, allow it in System Settings > Privacy & Security >
Automation, then rerun the command.
