# dotfiles

![last-commit](https://img.shields.io/github/last-commit/th2ch-g/dotfiles)
![license](https://img.shields.io/github/license/th2ch-g/dotfiles)
![repo-size](https://img.shields.io/github/repo-size/th2ch-g/dotfiles)

macOS and Linux dotfiles bootstrapped by [mise](https://mise.jdx.dev/).

## Install

```shell
curl -fsSL https://raw.githubusercontent.com/th2ch-g/dotfiles/main/setup.sh | bash
```

`standard` is the default profile. The wrapper installs mise v2026.8.3 or
newer, fetches this repository when needed, writes the local profile selection,
and runs `mise bootstrap`.

```shell
./setup.sh --profile standard
./setup.sh --profile full --fetch ssh --yes
./setup.sh --profile guest
./setup.sh --profile hpc --dir ~/works/dotfiles
```

| Profile    | Behavior                                                                                                                  |
| ---------- | ------------------------------------------------------------------------------------------------------------------------- |
| `standard` | User tools, Cargo/Python CLIs, workstation dotfiles, and required system packages                                         |
| `full`     | Standard plus GUI applications, all tracked dotfiles, opencode, Claude/GitHub extras, iTerm2, warpd, llama.cpp, and hooks |
| `guest`    | Copies zsh, Vim, Neovim, tmux, Sheldon, and mise config; installs no tools or packages                                    |
| `hpc`      | Standard user-space tools and symlinked dotfiles; skips packages, login shell changes, and privileged settings            |

Supported platforms are macOS arm64 and Linux x64/arm64. Intel macOS,
Windows, and Cygwin are not supported.

mise itself does not require root privileges. `standard` and `full` may request
`sudo` for OS packages; `full` also uses it for warpd and Docker Desktop.
`guest` and `hpc` do not request root access.

The bootstrap refuses existing dotfile conflicts. Inspect the plan before
choosing whether to move the existing file or explicitly run mise with
`--force-dotfiles`.

## Profiles and configuration

The active profile is stored in the ignored `mise/miserc.toml`. The checkout
path is stored in the ignored `mise/config.local.toml`. Declarative resources
live in:

- `mise/config.toml`: common environment, dotfiles, and tasks
- `mise/config.standard.toml`: standard packages, tools, and dotfiles
- `mise/config.full.toml`: full additions and safe per-user macOS defaults
- `mise/config.guest.toml`: copy-only guest dotfiles
- `mise/config.hpc.toml`: sudo-less HPC overrides
- `mise/config.macos.toml` and `mise/config.linux.toml`: package-manager routing

Common operations:

```shell
mise bootstrap plan
mise bootstrap
mise bootstrap status
mise run setup
mise run lint
mise run tools:update
mise run update
```

`mise run macos:dock` destructively rebuilds the Dock and requires an explicit
confirmation. `mise run macos:privileged` applies root-owned and host-scoped
macOS settings and also requires an explicit confirmation. Neither task runs
automatically.

During migration, existing macOS app bundles keep their current owner. Missing
casks are installed through mise; Docker Desktop and AeroSpace use dedicated
install paths because their casks require lifecycle steps mise cannot express.

## Releases and Docker

```shell
mise run release
mise run release:delete -- vYYYY.MM.DD
mise run docker
mise run docker:pull
```

The container uses the internal `container` profile, which intentionally omits
the large Cargo/Python CLI set.

## Legacy cleanup

Bootstrap does not delete previous pixi environments, Rust toolchains,
Homebrew installations, or manually installed binaries. The shell no longer
adds the old `PIXI_HOME`, `CARGO_HOME`, or `RUSTUP_HOME` paths. After verifying
the mise setup, inspect and remove those legacy directories manually if they
are no longer needed. Homebrew packages are never pruned automatically.
