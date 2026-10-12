# macOS

Apply macOS `defaults` (Dock, keyboard, trackpad, screenshots, sound, etc.).
The `--dockutil` flag additionally rebuilds the Dock via `dockutil`; install
it first (`brew "dockutil"`) and keep Homebrew on `PATH`.

```bash
export PATH="/opt/homebrew/bin:$PATH"
./run.sh --dockutil
```

Invoked by `./install.sh --macos` (which passes `--dockutil`).

## Google Japanese Input

`brew/Brewfile` installs Google Japanese Input. Pass `--google-ime` to also
configure it when applying the macOS settings:

```bash
./run.sh --google-ime
```

This flag adds the input method and Hiragana mode to `AppleEnabledInputSources`
using only `defaults` and shell builtins. Existing sources are preserved, and
each missing entry is added separately so repeated runs do not create
duplicates. Without this flag, the IME preferences are left unchanged.

After adding entries, log out and back in for macOS to reload the preferences. This
does not switch the current input source or remove Apple's Japanese input.
Settings such as keymaps and user dictionaries are managed separately.
