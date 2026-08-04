# Dotfiles

My dotfiles for an Arch Linux workstation, managed as a [GNU stow](https://www.gnu.org/software/stow/) tree. Each top-level folder mirrors `$HOME`; the real files are symlinks into this repo, which I keep at `~/dotfiles`. Some configs and scripts reference `~/dotfiles` absolutely, so that path is expected.

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

These dotfiles are tailored to my workflow. They may not work on another machine without changes. Review scripts before running them.

## License

Released under the MIT License. See [LICENSE](./LICENSE).
