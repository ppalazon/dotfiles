# AGENTS.md

Conventions for the `dotfiles` repository. Every agent working in this repo must follow these rules.

## Repository layout (stow-based)

This repo is a [GNU stow](https://www.gnu.org/software/stow/) tree. Each top-level directory is a stow package that mirrors `$HOME` (e.g. `base/.bashrc` symlinks to `~/.bashrc`).

| Directory | Contents |
| --------- | -------- |
| `base` | Bash configuration (`.bashrc`, `.bash.d/`, `.profile`, gpg-agent, ssh config) |
| `editors` | Editor tooling: `.vimrc`, `.nanorc`, git config, lazygit, pandoc (`.pandoc/` filters + templates) |
| `tui` | Text-based programs: ranger, kitty, taskwarrior, mpd, moc |
| `systemd` | User systemd services (`.config/systemd/user/`) |
| `x11` | X11 / i3 environment: i3, i3blocks, dunst, polybar, picom, rofi, wal, etc. |
| `autokey` | Autokey automation configuration |
| `scripts` | Executable scripts in `scripts/bin/sh` (bash) and `scripts/bin/py` (python) |
| `_private` | Host-private config. **Never** commit, sync, or reference in configs. Ignored via `.gitignore` |

## Stow workflow

- New config files always go in the correct top-level package folder, mirroring the `$HOME` path.
- Apply changes with the repo's own script, never raw `stow`:
  ```bash
  ./scripts/bin/sh/dotfiles-stow
  ```
  It uses `stow -Sv --no-folding <pkg>` for `base`, `editors`, `tui`, `x11`, `systemd`, `autokey`, `_private` and plain `stow -Sv scripts`.
- `scripts` stows whole directories (binaries stay as real files under `~/bin`), not individual symlinks.
- After creating/renaming a file, verify the `$HOME` symlink resolves correctly.
- `_private` is excluded from git and syncthing (`.stignore`). Do not store anything there unless explicitly asked.

## Scripts (`scripts/bin/sh`, `scripts/bin/py`)

- Use `#!/usr/bin/env bash` as the shebang (repo convention is being normalized to this from `#!/bin/bash`).
- Always start bash scripts with `set -euo pipefail` on the first line after the shebang.
- Two-space indentation, no tabs.
- Keep scripts POSIX-portable where reasonable; prefer `[[ ... ]]` for tests.
- Use emoji status markers in `echo` output (e.g. `✅`, `⚠️`, `🏠`) for user-facing progress.
- Every script must pass `shellcheck` (installed). Verify new/edited scripts with `shellcheck <file>`.
- New scripts must be executable (`chmod +x`).
- Completions live in `scripts/.bash_completions.d/`.
- Python scripts use `#!/usr/bin/env python3` and `argparse` for CLI parsing.

## Documentation (mkdocs)

- Docs live in `docs/`, built with `mkdocs material` to `site/` (gitignored build output).
- When adding or renaming a doc page, update the `nav:` section in `mkdocs.yml` in the same change.
- Use mermaid diagrams via `pymdownx.superfences` with the `mermaid` fence.
- Verify doc changes with `mkdocs build` before finishing.
- Docs are personal memory aids written by the `docs-writer` subagent. Two document types per Diataxis: **how-to guides** (task-oriented, real commands/keybindings, one scenario per page) and **reference** (per-config "why" entries: where, what, why, breaks-if). No tutorials or standalone explanation.
- Voice is first-person and direct. Banned: AI-tells such as "In today's ...", "Moreover", "It's important to note", hedging ("probably", "might"), superlatives ("seamless", "robust"), closing summary paragraphs, and placeholder content.
- Ground every doc in the actual config/script it describes; if the "why" is not visible in the repo, ask the user instead of inventing one.

## Verification

- Config files are YAML/JSON/toml — keep them syntactically valid and alphabetized where the tooling expects it (e.g. mkdocs nav).
- After any repo change, run `./scripts/bin/sh/dotfiles-stow` if it affects `$HOME` symlinks.
