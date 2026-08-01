# pixi

Global CLI tools managed declaratively via `pixi-global.toml`.

`run.sh` links the manifest into `$PIXI_HOME/manifests/` and runs
`pixi global sync`.

```bash
./run.sh
```

## Gotchas

`run.sh` ends in `pixi global sync`, which prunes every environment under
`$PIXI_HOME/envs/` that this manifest does not declare. Anything installed by
hand into that directory is deleted on the next run. Tools that do not come
from conda-forge belong in `$TOOLS/<name>` instead -- `$TOOLS/ollama` was
installed from the upstream release tarball for that reason.

**This manifest is shared by every machine, so it cannot carry a
platform-specific build pin.** That is why `llama.cpp` no longer lives here:
conda-forge builds it per accelerator (`cuda130*` on linux-64, `metal*` and
`cpu_accelerate*` on osx-arm64), so pinning the CUDA build made
`pixi global sync` fail on the Mac with `No candidates were found for
llama.cpp * cuda130*`, while leaving it unpinned silently picked the
CPU/Vulkan variant. `pixi global` has no per-platform dependency table -- its
`--platform` flag selects a target to install _for_, not a condition.
`install_scripts/llama-cpp.sh` replaces it: the upstream installer probes the
machine at install time and fetches the matching accelerator build. It is the
one tool that ignores the `$TOOLS/<name>` convention, because the installer
hardcodes `~/.llama-app` + `~/.local/bin` with no override.
