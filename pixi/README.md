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
from conda-forge belong in `$TOOLS/<name>` instead -- `$TOOLS/ollama` is
installed from the upstream release tarball for that reason.

`llama.cpp` is pinned to the `cuda130*` build. Left unpinned it resolves to
the default variant, which ships only the Vulkan and CPU ggml backends.
