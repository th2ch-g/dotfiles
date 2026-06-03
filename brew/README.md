# brew

Sync Homebrew to `Brewfile`: `brew bundle install --cleanup --force-cleanup`
installs/upgrades listed packages and **uninstalls anything not in
`Brewfile`**. Invoked by `./install.sh --brew-pkgs` (Mac only).

```bash
./run.sh
```

`Brewfile` must stay sorted (enforced by the `sort-brewfile` pre-commit hook).
