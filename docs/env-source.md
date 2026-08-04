# Load project environments

`env-source` keeps per-project and per-toolchain environments in small files under `~/.config/env-source` and applies them on demand, so the global `.bashrc` PATH stays clean.

## How env files work

Each environment is a plain bash script stowed from `editors/.config/env-source/<name>` to `~/.config/env-source/<name>` (the `editors` stow package links them with `--no-folding`). The file can `export` variables, `source` a virtualenv, activate a conda env, or run any bash.

## Apply to the current shell

`es <name>` loads the environment into the running shell. `es()` comes from `env-source --init bash`, which `.bashrc` wires in:

```bash
if command -v env-source >/dev/null 2>&1; then
  eval "$(env-source --init bash)"
fi
```

`env-source <name>` prints `eval "$(direnv stdlib)"` followed by `source ~/.config/env-source/<name>`. `es` evals that output:

```sh
es() {
  eval "$(env-source "$@")"
}
```

Example:

```sh
es teroshdl
```

`--init bash` also installs tab completion for `env-source` and `es`, backed by `env-source --list`, so `es t<TAB>` completes the name.

## Temporary per session

Because `es` evals into the current shell, the environment lasts only for that session. A fresh shell starts clean, and `exec bash` resets the session. Nothing is permanent in `.bashrc`.

## List available environments

`env-source --list` prints every file in `~/.config/env-source`, one per line.

## Add a new environment

1. Create `editors/.config/env-source/<name>` as a bash script.
2. Run `./scripts/bin/sh/dotfiles-stow` to link it into `~/.config/env-source/`.
3. Verify with `env-source --list`; tab completion reads the same directory.

## Reuse with direnv

`.bashrc` also hooks direnv with `eval "$(direnv hook bash)"`. In a project's `.envrc`, reuse the same files with `source ~/.config/env-source/<name>`; direnv auto-applies it on `cd` into the project and unloads it when you leave, no `es` needed. The repo's own root `.envrc` uses `layout pyenv 3.14.5`, another per-project pattern from the direnv stdlib.

## Why this way

| Where | What | Why | Breaks if |
| ----- | ---- | --- | --------- |
| `~/.config/env-source` (stowed from `editors/.config/env-source/`) | one bash script per environment | versioned, stowed, and the global PATH stays lean | you add the exports directly to `.bashrc`, or forget to re-stow after adding a file |
| `es` evals the snippet printed by `env-source --init bash` | envs applied on demand instead of inlined in `.bashrc` | `.bashrc` stays minimal and only the environments you ask for load | the `--init` eval is removed from `.bashrc` — `es` and tab completion vanish |
| `env-source` emits `eval "$(direnv stdlib)"` first | direnv stdlib functions (`layout`, `PATH_add`, ...) are available inside env files and in the shell after loading | env files reuse the same helpers direnv provides | you call those functions in an env file loaded without the direnv stdlib |
| direnv `.envrc` `source ~/.config/env-source/<name>` for directory-scoped auto-apply vs explicit `es` | the same file is reused in both modes | one definition, two loading strategies | the `.envrc` edits the env file's contents instead of sourcing it — the two copies diverge |
