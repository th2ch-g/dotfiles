# AGENTS.md

## Overview

Personal dotfiles for macOS arm64 and Linux x64/arm64. mise v2026.8.3 or newer
owns tool versions, OS packages, dotfile application, macOS user defaults, and
repository tasks. `setup.sh` is the only pre-mise bootstrap wrapper.

## Bootstrap

```bash
./setup.sh --profile standard
./setup.sh --profile full --fetch ssh --yes
./setup.sh --profile guest
./setup.sh --profile hpc
```

Profiles are selected through the ignored `mise/miserc.toml`; the checkout path
is stored in the ignored `mise/config.local.toml`.

| Profile    | Scope                                                                                          |
| ---------- | ---------------------------------------------------------------------------------------------- |
| `standard` | Full user-space CLI set, workstation dotfiles, system build/runtime packages                   |
| `full`     | Standard plus GUI apps, all dotfiles, opencode, warpd, llama.cpp, external integrations, hooks |
| `guest`    | Copy-only zsh/Vim/Neovim/tmux/Sheldon config; no tools or packages                             |
| `hpc`      | Standard tools/dotfiles; skips packages, login shell, macOS defaults, and sudo                 |

## mise configuration

- `mise/config.toml`: shared environment, common dotfiles, and tasks
- `mise/config.standard.toml`: standard packages, tools, and dotfiles
- `mise/config.full.toml`: full-only resources and safe macOS defaults
- `mise/config.guest.toml`: copy-mode guest resources
- `mise/config.hpc.toml`: no-sudo HPC settings
- `mise/config.macos.toml`, `mise/config.linux.toml`: platform package managers
- `mise/config.ci.toml`, `mise/config.container.toml`: reduced internal profiles
- `mise/tasks/*.sh`: idempotent imperative setup not expressible declaratively

Cargo registry CLIs use the `cargo:` backend. Git Cargo tools are pinned to an
exact `rev:`. Python CLIs use `pipx:` through uv. GUI applications and native
dependencies use `[bootstrap.packages]`. Missing macOS casks are installed by
`mise/tasks/macos-casks.sh` through mise's built-in cask manager while existing
app bundles are left unchanged. Docker Desktop and AeroSpace use dedicated
install paths. There is no Brewfile.

## Tasks

```bash
mise bootstrap plan
mise bootstrap
mise run setup
mise run lint
mise run tools:update
mise run update
mise run release
mise run release:delete -- vYYYY.MM.DD
mise run docker
mise run docker:pull
mise run macos:dock
mise run macos:privileged
mise run llama:update
```

`macos:dock` is destructive and interactive. `macos:privileged` is explicit
and may invoke sudo. Neither is part of automatic bootstrap.

## Dotfile behavior

Standard/full/HPC use symlinks. Guest copies files. SSH and Codex config are
always copied. mise refuses unmanaged conflicts unless the user explicitly
passes `--force-dotfiles`.

Neovim setup uses `Lazy restore` against `nvim/lazy-lock.json`; it must not
update the lock during bootstrap. Generated zsh caches and machine-local files
remain ignored.

## Validation

```bash
bash -n setup.sh mise/tasks/*.sh
zsh -n zsh/.zshenv zsh/.zprofile zsh/.zshrc
mise tasks validate
mise run lint
```

CI uses `jdx/mise-action` with the `ci` profile and executes `mise run lint`.

## Gotchas

- mise itself is rootless; standard/full OS packages and full warpd/Docker
  Desktop may request sudo.
- Bootstrap never removes legacy pixi, Rust, Homebrew, or manually installed data.
- Package/bootstrap resources merge additively; HPC skips the package phase
  instead of attempting to subtract standard entries.
- Do not run package prune automatically.
- Do not edit generated lockfiles as a side effect of editor bootstrap.
