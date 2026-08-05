# Dotfiles

These dotfiles belong to an Arch Linux workstation and are managed as a [GNU stow](https://www.gnu.org/software/stow/) tree. Each top-level folder mirrors `$HOME`. The symlinks in `$HOME` point into this repo at `~/dotfiles`. Some config files and scripts reference `~/dotfiles` absolutely, so that path is expected.

Environment:

- Arch Linux
- Bash shell
- X11 / i3
- Kitty terminal
- Tomorrow Night colorscheme
- systemd (user services)

## Initialize

Install `stow` first, then:

```bash
git clone git@github.com:ppalazon/dotfiles.git ~/dotfiles
cd ~/dotfiles
./scripts/bin/sh/dotfiles-stow
```

`dotfiles-stow` links `base`, `editors`, `tui`, `x11`, `systemd`, `autokey` and `_private` with `stow -Sv --no-folding`, and `scripts` as a whole directory so `~/bin` keeps real files.

## Layout

| Folder | Contents |
| ------ | -------- |
| `base` | Bash config (`.bashrc`, `.bash.d/`, `.profile`, gpg-agent, ssh) |
| `editors` | `.vimrc`, `.nanorc`, git config, lazygit, `.pandoc/` filters + templates |
| `tui` | ranger, kitty, taskwarrior, mpd, moc |
| `systemd` | User systemd services (`.config/systemd/user/`) |
| `x11` | i3, i3blocks, dunst, polybar, picom, rofi, wal |
| `autokey` | Autokey automation |
| `scripts` | `bin/sh` (bash) and `bin/py` (python) executables |
| `_private` | Host-private config. Never committed or synced. |

## Disclaimer

These dotfiles are tailored to one workstation workflow. They can fail on another machine without changes. Review the scripts before running them.

## License

Released under the MIT License. See [LICENSE](./LICENSE).
