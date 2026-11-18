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

macOS does not enable a third-party input method from these entries alone, even
after logging out or rebooting. When Google Japanese Input is not enabled yet,
the script opens System Settings > Keyboard; add "Hiragana (Google)" via
Input Sources > Edit..., then re-run `./run.sh --google-ime`. Once it is
enabled, the script selects it as the current input source via the Text Input
Sources API (`swift` from the Command Line Tools), and macOS keeps that
selection across logins. Apple's Japanese input is not removed. Settings such
as keymaps and user dictionaries are managed separately.
