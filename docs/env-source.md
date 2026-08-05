# Load project environments

`env-source` keeps per-project and per-toolchain environments in small files under `~/.config/env-source` and applies them on demand, so the global `.bashrc` PATH stays clean.

## How env files work

Each environment is a plain bash script stowed from `editors/.config/env-source/<name>` to `~/.config/env-source/<name>`. The `editors` stow package links them with `--no-folding`. The file can `export` variables, `source` a virtualenv, activate a conda env, or run any bash.

## Apply to the current shell

`es <name>` loads the environment into the running shell. `es()` comes from `env-source --init bash`, which `.bashrc` evaluates:

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

`--init bash` also installs tab completion for `env-source` and `es`. Completion is backed by `env-source --list`, so `es t<TAB>` completes the name.

## Temporary per session

Because `es` evals into the current shell, the environment lasts only for that session. A fresh shell starts clean, and `exec bash` resets the session. Nothing is permanent in `.bashrc`.

## List available environments

`env-source --list` prints every file in `~/.config/env-source`, one per line.

## Add a new environment

1. Create `editors/.config/env-source/<name>` as a bash script.
2. Run `./scripts/bin/sh/dotfiles-stow` to link the file into `~/.config/env-source/`.
3. Make sure that `env-source --list` prints the new file. Tab completion reads the same directory.

## Reuse with direnv

`.bashrc` also hooks direnv with `eval "$(direnv hook bash)"`. In the `.envrc` of a project, reuse the same files with `source ~/.config/env-source/<name>`. Direnv auto-applies the file on `cd` into the project and unloads it on exit, so no `es` is needed. The `.envrc` at the repo root uses `layout pyenv 3.14.5`, another per-project pattern from the direnv stdlib.

## Why this way

| Where | What | Why | Breaks if |
| ----- | ---- | --- | --------- |
| `~/.config/env-source` (stowed from `editors/.config/env-source/`) | One bash script holds each environment. | The files are versioned and stowed, and the global PATH stays lean. | If the exports go directly into `.bashrc`, every shell loads them. If a file is added without a re-stow, the environment stays missing. |
| `es()` from `env-source --init bash` (wired in `base/.bashrc`) | `es <name>` evals the printed snippet, so environments load on demand. | `.bashrc` stays minimal, and only the requested environments load. | If the `--init` eval is removed from `.bashrc`, `es` and tab completion vanish. |
| `env-source` emits `eval "$(direnv stdlib)"` first | The direnv stdlib functions, for example `layout` and `PATH_add`, are available inside env files and in the shell after loading. | Env files reuse the same helpers that direnv provides. | If an env file calls those functions without the direnv stdlib, the load fails. |
| `source ~/.config/env-source/<name>` in a project `.envrc` | The same file runs in both modes, explicit `es` and direnv auto-apply. | One definition serves two loading strategies. | If the `.envrc` edits the env file contents instead of sourcing the file, the two copies diverge. |
