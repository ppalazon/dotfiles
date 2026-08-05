# Workstation reference

Each entry explains why one config decision exists. If a why is wrong or a decision is missing, fix the page.

## Repository

### Stow tree with `--no-folding`

| Where | What | Why | Breaks if |
| ----- | ---- | --- | --------- |
| `AGENTS.md`, `scripts/bin/sh/dotfiles-stow` | Each top-level folder is a stow package that mirrors `$HOME`. `dotfiles-stow` runs `stow -Sv --no-folding` for `base`, `editors`, `tui`, `x11`, `systemd`, `autokey`, `_private`. | Every dotfile lives in one repo while `$HOME` holds symlinks. `--no-folding` makes one symlink per file instead of one per directory. Separate packages can contribute to the same target directory, for example `~/.config`, without overwriting each other. | If raw `stow <pkg>` runs or a package folder is renamed, existing `$HOME` symlinks point at the old paths. A re-stow restores them. |

### `scripts` stowed as a whole directory

| Where | What | Why | Breaks if |
| ----- | ---- | --- | --------- |
| `scripts/bin/sh`, `scripts/bin/py`, `stow -Sv scripts` in `dotfiles-stow` | `stow -Sv scripts` links `scripts/bin` to `~/bin` as a directory. | A new script needs no re-stow, and `~/bin` stays clean of hundreds of symlinks. | If a script is added outside `scripts/bin/sh` or `scripts/bin/py`, it never lands on `$PATH`. |

### `_private` excluded from git and syncthing

| Where | What | Why | Breaks if |
| ----- | ---- | --- | --------- |
| `_private/`, `.gitignore`, `.stignore` | `_private` holds host-private config and never gets committed or synced. | Some machines carry secrets and quirks that must not propagate to other hosts. | If a file leaks into `_private`, it gets committed and synced everywhere. |

## Shell

### `set -euo pipefail` in every script

| Where | What | Why | Breaks if |
| ----- | ---- | --- | --------- |
| Every script in `scripts/bin/sh` (AGENTS.md rule) | `set -euo pipefail` exits on any failing command, unset variable, or failing element of a pipeline. | Scripts fail loudly instead of continuing half-done. This matters when they touch `$HOME` or system state. | If the line is dropped, a failed command lets the script continue with broken assumptions, for example a disconnected monitor. |

### `#!/usr/bin/env bash` shebang

| Where | What | Why | Breaks if |
| ----- | ---- | --- | --------- |
| `AGENTS.md` rule, normalized across `scripts/bin/sh` | `#!/usr/bin/env bash` resolves `bash` through `$PATH`. | The shebang works on systems where `bash` does not sit at `/bin/bash`. | If a script uses the `#!/bin/bash` shebang, the script fails on systems without `/bin/bash`. |

## GPG

### gpg-agent cache and SSH support

| Where | What | Why | Breaks if |
| ----- | ---- | --- | --------- |
| `base/.gnupg/gpg-agent.conf` and `~/.gnupg/gpg-agent.conf` | `default-cache-ttl 21600` and `max-cache-ttl 43200` set the GPG passphrase cache window. The `-ssh` variants set the same values for SSH, with `enable-ssh-support` and `pinentry-qt`. | `default-cache-ttl 21600` keeps the passphrase cached during a long work session. `max-cache-ttl 43200` forces expiry, so keys are not left loaded overnight. | If `enable-ssh-support` is disabled, `ssh` stops using the agent. Lower TTLs cause repeated prompts mid-session. |

## Display

### `$mod+x` opens the layout picker

| Where | What | Why | Breaks if |
| ----- | ---- | --- | --------- |
| `x11/.config/i3/config:159` and `~/.config/i3/config`, `scripts/bin/sh/monitor-selection` | `monitor-selection` lists `~/.screenlayout/*.sh` in rofi and calls `monitor-init-layout` with the selection. | This switches layouts without touching the i3 config or reopening `arandr`. | If `monitor-selection` drops off `$PATH` or another binding reuses `$mod+x`, the picker stops working. |

### polybar is run by `monitor-init-layout`, not i3

| Where | What | Why | Breaks if |
| ----- | ---- | --- | --------- |
| `x11/.config/i3/config:354` (comment) and `~/.config/i3/config`, `scripts/bin/sh/monitor-init-layout` | i3 does not run polybar. `monitor-init-layout` runs it on every layout load. | The bar must re-place itself for the current output geometry. | If `exec polybar-launcher` is added to i3, polybar runs before the layout applies and can land on the wrong output. |
