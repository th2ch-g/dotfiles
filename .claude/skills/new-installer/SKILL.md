---
name: new-installer
description: Scaffold a new tool installer for this dotfiles repo — create install_scripts/<tool>.sh following lib/utils.sh conventions, wire the flag into install.sh and setup.sh, and update the AGENTS.md/README flag tables
disable-model-invocation: true
argument-hint: <tool-name>
---

# new-installer

Add a new tool installer end-to-end. The argument is the tool name
(e.g. `/new-installer zellij`). Follow every step; the wiring is spread
across several files and is easy to miss.

## Step 0 — Confirm install_scripts/ is the right place

Prefer `pixi/pixi-global.toml` (conda-forge) when the tool is packaged
there and needs no per-machine build pin — add it to the manifest and
stop (see the pixi section in AGENTS.md). Use `install_scripts/` only
when the tool needs a first-party installer, a pinned release tarball,
a source build, or a per-machine accelerator pin (see
`install_scripts/llama-cpp.sh`).

## Step 1 — Gather facts (ask the user if unclear)

- Install method and URL (official installer script / release tarball /
  source build)
- OS support: both, or Mac/Linux only
- Self-update command, if the tool has a first-party one
- Which binaries must land on PATH

## Step 2 — Create `install_scripts/<tool>.sh`

Pattern A — first-party installer with self-update (see `uv.sh`):

```bash
#!/bin/bash
set -e

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

update_if_installed <tool> <tool> self-update

curl -LsSf https://example.com/install.sh | sh

print_info "<tool> install done"
```

Pattern B — pinned release tarball / source build (see
`password-store.sh`):

```bash
#!/bin/bash
set -e

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

VERSION="X.Y.Z"
BIN=${BIN:-$HOME/works/bin}

[ -d "<tool>-${VERSION}" ] && {
    print_info "<tool>-${VERSION} already present, skipping"
    exit 0
}

# fetch, extract, build into ${PWD}/<tool>-${VERSION} ...
ensure_bin "${PWD}/<tool>-${VERSION}/bin/<tool>"

print_info "<tool> install done"
```

Conventions:

- `#!/bin/bash` + `set -e`; source `lib/utils.sh` exactly as above
- The script runs with cwd = `$TOOLS` (`install.sh` wraps it in
  `(cd "$TOOLS" && ...)`) — extract/build into `$PWD/<tool>-<version>`
- Expose binaries with `ensure_bin` (symlinks into `$BIN`)
- Idempotency: `update_if_installed` for self-updating tools;
  `skip_if_installed` or a version-dir check for pinned builds
- No absolute or machine-specific paths
- `chmod +x install_scripts/<tool>.sh` (pre-commit enforces the
  shebang/executable pairing)

## Step 3 — Wire into `install.sh` (4 spots)

1. `USAGE` — add a `--<tool>` line, aligned with the others
2. Flag var — `do_<tool>=0` in the flags block
3. Option parser — a `--<tool>)` case setting `do_<tool>=1`
4. Execution — `[[ $do_<tool> -eq 1 ]] && install_script <tool>`.
   For Mac-only tools copy the `if/else` + `print_warn` pattern used by
   `--brew` (not `&& ... || warn`; the comment there explains why)

## Step 4 — Wire into `setup.sh` (2–3 spots)

1. Add `--<tool>` to the "install.sh passthrough toggles" case pattern
2. Add it to the USAGE "install passthrough" list
3. Decide profile membership: `build_full` (Mac and/or Linux
   `INSTALL_FLAGS` lists), `build_standard`, and optionally an `ask_yn`
   prompt in the customize flow

## Step 5 — Update docs

- `AGENTS.md`: add a row to the "Flags for tool installers" table;
  note anything non-obvious in the "Install Scripts" section
- `README.md`: add the flag to the "For me" one-liner if it joined the
  full profile

## Step 6 — Verify and commit

```bash
bash -n install_scripts/<tool>.sh
zsh -n install.sh
bash -n setup.sh
pre-commit run --files install_scripts/<tool>.sh install.sh setup.sh AGENTS.md README.md
```

Optionally run `./install.sh --<tool>` for a live test. Then commit and
push to main (repo rule).
