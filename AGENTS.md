# AGENTS.md

## Overview

Personal dotfiles repository for macOS and Linux. The core mechanism is
`link.sh`, which creates symlinks from this repository into `~/.config/`
(XDG_CONFIG_HOME) and `$HOME`.

## Key Scripts

### `link.sh` — Dotfiles linker

Must be run from the repository root. Links individual tool configs via flags:

```bash
./link.sh --zsh --git --tmux --vim --neovim --ssh --aerospace
./link.sh --unlink   # remove all symlinks
./link.sh --cp       # copy instead of symlink (for remote/guest use)
```

### `install.sh` — Bootstrap installer

Installs tools and packages. Must be run from the repository root.

```bash
./install.sh                              # full install for current OS (Mac/Linux defaults)
./install.sh --pixi --uv --python3        # selective: install only specified tools
./install.sh --vim --nvim --cargo --cargo-pkgs
```

Flags for tool installers (`install_scripts/`):

| Flag | Tool |
|------|------|
| `--pixi` | pixi |
| `--uv` | uv |
| `--brew` | Homebrew (Mac only) |
| `--cargo` | Rust toolchain |
| `--warpd` | warpd (Mac only) |
| `--claude-code` | claude-code |
| `--fzf` | fzf |
| `--vim` | vim |
| `--nvim` | neovim |
| `--tmux` | tmux |
| `--imagemagick` | imagemagick |
| `--zsh` | zsh |
| `--node` | Node.js |
| `--conda` | conda (miniconda) |
| `--gemini-cli` | gemini-cli |
| `--git` | git |
| `--autoconf` | autoconf |
| `--cmake` | cmake |
| `--mold` | mold linker |
| `--less` | less |
| `--password-store` | password-store |
| `--supertuxkart` | SuperTuxKart |

Flags for package runners (`*/run.sh`):

| Flag | Action |
|------|--------|
| `--brew-pkgs` | install Homebrew packages (Mac only) |
| `--cargo-pkgs` | install cargo packages |
| `--python3` | install Python packages |
| `--macos` | configure macOS settings (Mac only) |
| `--iterm2` | configure iTerm2 (Mac only) |

## Symlink Targets

| Flag | Source | Destination |
|------|--------|-------------|
| `--zsh` | `zsh/` | `~/.config/zsh/`, `~/.zshenv` |
| `--vim` | `vim/` | `~/.config/vim/` |
| `--neovim` | `nvim/` | `~/.config/nvim/` |
| `--git` | `git/` | `~/.config/git/` |
| `--tmux` | `tmux/` | `~/.config/tmux/` |
| `--aerospace` | `aerospace/` | `~/.config/aerospace/` |
| `--alacritty` | `alacritty/` | `~/.config/alacritty/` |
| `--yabai` | `yabai/` | `~/.config/yabai/` (Mac only, auto-restarts service) |
| `--skhd` | `skhd/` | `~/.config/skhd/` (Mac only, auto-restarts service) |
| `--sheldon` | `sheldon/` | `~/.config/sheldon/` |
| `--claude` | `claude/` | `~/.claude/` |
| `--gemini` | `gemini/` | `~/.gemini/` |
| `--codex` | `codex/` | `~/.codex/` |
| `--ssh` | `ssh/config` | `~/.ssh/config` (copy, not link) |

## Architecture

### zsh

- Entry: `zsh/.zshenv` → sets `ZDOTDIR`, loads `zsh/.zshrc`
- Plugin manager: [sheldon](https://sheldon.cli.rs/) with cache at
  `zsh/sheldon_cache.zsh`
- Local overrides: `zsh/.zshrc_local`, `zsh/.zshenv_local`
  (machine-specific, not committed)
- `.zshrc` files are compiled to `.zwc` on change for faster startup

### Neovim

- Single file config: `nvim/init.lua`
- Plugin manager: [lazy.nvim](https://github.com/folke/lazy.nvim)
  (auto-installed on first run)
- Lock file: `nvim/lazy-lock.json`

### Vim

- Config: `vim/vimrc`
- Plugin manager: vim-jetpack
  (stored as git submodule under `vim/pack/jetpack/`)

### Shared Utilities

- `lib/utils.sh` — sourced by `install.sh`, `link.sh`, and all
  `install_scripts/*.sh`; provides:
  - `detect_os` → `$OS`: `Mac`/`Linux`/`Cygwin`
  - `print_info` / `print_warn` / `print_error` — logging helpers
  - `need_cmd <cmd>` — check if command exists on PATH
  - `skip_if_installed <cmd>` — exit 0 with message if already installed
  - `ensure_bin <path>` — `ln -sf` binary into `$BIN`
    (default: `$HOME/works/bin`)
  - `detect_nproc` — cross-platform CPU count
    (macOS: `sysctl -n hw.ncpu`, Linux: `nproc`)

## Gotchas

- `link.sh --codex` copies `codex/` into `~/.codex`; it does not create
  a symlink.
- `link.sh --claude` links `claude/` into `~/.claude` and, when `claude`
  is installed, also registers user-scoped MCP entries with
  `claude mcp add`.
- `claude/plugins/cache/` contains vendored plugin cache data; treat it as
  external snapshot data unless the task explicitly targets plugin cache
  updates.

### Install Scripts

- `install_scripts/*.sh` — individual tool installers
  (invoked by `install.sh`)
- Built tools are symlinked into `$BIN` (`$HOME/works/bin`); sources are
  extracted to `$TOOLS` (`$HOME/works/tools`)
- All scripts source `lib/utils.sh` via `$DOTFILES_DIR`; re-running is safe
  (idempotency checks built in)
- `brew/run.sh` — Homebrew package list
- `cargo/run.sh` — Cargo package list (use `--cargo-pkgs` flag)
- `python3/run.sh` — Python package installs

## Local Customization Pattern

Machine-specific settings go in untracked local files:

- `zsh/.zshrc_local` — extra zsh config
- `zsh/.zshenv_local` — extra env vars (e.g., `PATH` additions)

## Release Workflow

```bash
TAG=v$(date +'%Y.%m.%d') && git tag -a $TAG -m "Release $TAG" && git push origin $TAG
```

CI (`.github/workflows/release.yml`) handles Docker image builds on
tag push.

## Pre-commit Hooks

This repository uses [pre-commit](https://pre-commit.com/) for automated
linting and formatting. Configuration: `.pre-commit-config.yaml`.

After cloning, activate hooks:

```bash
make setup    # runs: pre-commit install
```

Run all hooks manually:

```bash
make l        # runs: pre-commit run --all-files
```

Configured hooks: trailing-whitespace, end-of-file-fixer, mixed-line-ending,
check-yaml/toml/json, check-added-large-files, check-case-conflict,
check-merge-conflict, check-symlinks, destroyed-symlinks, detect-private-key,
check-executables-have-shebangs, check-shebang-scripts-are-executable,
actionlint, shellcheck (excludes `zsh/`), stylua (for `nvim/*.lua`), shfmt,
typos, markdownlint-cli2, taplo TOML formatter, bash syntax check, zsh syntax
check (`zsh/` and `install.sh`).

## Makefile Shortcuts

```bash
make setup
make l
make s
make u
make delete-release TAG=vYYYY.MM.DD
```
