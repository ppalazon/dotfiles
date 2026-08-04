# Workstation reference

Why the workstation is configured the way it is. One entry per decision; if a "Why" is wrong or a decision is missing, fix it here.

## Repository

### Stow tree with `--no-folding`

- **Where**: `AGENTS.md`, `scripts/bin/sh/dotfiles-stow`
- **What**: Each top-level folder is a stow package mirroring `$HOME`; `dotfiles-stow` applies them with `stow -Sv --no-folding` for `base`, `editors`, `tui`, `x11`, `systemd`, `autokey`, `_private`.
- **Why**: Every dotfile is versioned in one repo while `$HOME` holds symlinks. `--no-folding` makes one symlink per file instead of one per directory, so separate packages can contribute to the same target directory (e.g. `~/.config`) without overwriting each other.
- **Breaks if**: You run raw `stow <pkg>` or rename a package folder — existing `$HOME` symlinks point at the old paths and need a re-stow.

### `scripts` stowed as a whole directory

- **Where**: `scripts/bin/sh`, `scripts/bin/py`, `stow -Sv scripts` in `dotfiles-stow`
- **What**: `scripts/bin` is symlinked to `~/bin` as a directory, not per file.
- **Why**: `~/bin` keeps real files, so adding a script needs no re-stow and `~/bin` stays clean of hundreds of symlinks.
- **Breaks if**: You add a script outside `scripts/bin/sh` or `scripts/bin/py` — it never lands on `$PATH`.

### `_private` excluded from git and syncthing

- **Where**: `_private/`, `.gitignore`, `.stignore`
- **What**: Host-private config, never committed or synced.
- **Why**: Some machines carry secrets and quirks that must not propagate to other hosts.
- **Breaks if**: A file leaks in — it gets committed and synced everywhere.

## Shell

### `set -euo pipefail` in every script

- **Where**: every script in `scripts/bin/sh` (AGENTS.md rule)
- **What**: Exits on any failing command, unset variable, or failing element of a pipeline.
- **Why**: Scripts fail loudly instead of continuing half-done — important when they touch `$HOME` or system state.
- **Breaks if**: You drop it — a failed command (e.g. a disconnected monitor) lets the script keep going with broken assumptions.

### `#!/usr/bin/env bash` shebang

- **Where**: AGENTS.md rule, normalized across `scripts/bin/sh`
- **What**: Resolves `bash` through `$PATH`.
- **Why**: Works on systems where bash is not `/bin/bash`.
- **Breaks if**: Nothing here — but keep `/bin/bash` out of new scripts, it is a portability trap.

## GPG

### gpg-agent cache and SSH support

- **Where**: `base/.gnupg/gpg-agent.conf`
- **What**: Passphrase cached 21600s (6h) with a 43200s (12h) maximum; same for SSH; `enable-ssh-support`; `pinentry-qt`.
- **Why**: One work session is ~6h, so the passphrase is cached for it and expires at 12h so keys are not left loaded overnight.
- **Breaks if**: You disable `enable-ssh-support` — `ssh` stops using the agent. Lower TTLs mean repeated prompts mid-session.

## Display

### `$mod+x` opens the layout picker

- **Where**: `x11/.config/i3/config:159`, `scripts/bin/sh/monitor-selection`
- **What**: `monitor-selection` lists `~/.screenlayout/*.sh` in rofi and loads the selection.
- **Why**: Layout switching without touching the i3 config or reopening `arandr`.
- **Breaks if**: `monitor-selection` drops off `$PATH` or the binding is reused elsewhere.

### polybar is started by `monitor-init-layout`, not i3

- **Where**: `x11/.config/i3/config:354` (comment), `scripts/bin/sh/monitor-init-layout`
- **What**: i3 does not launch polybar; `monitor-init-layout` does, on every layout load.
- **Why**: The bar must re-place itself for the current output geometry.
- **Breaks if**: You add a plain `exec polybar-launcher` to i3 — it starts before the layout applies and can land on the wrong output.
