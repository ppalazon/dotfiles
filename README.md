# Dotfiles

This project contains my basic dotfiles to configure in an Arch Linux workstation. This project is based on a stow configuration, so the original files are links to the this dotfiles folder. 

By default, I use this repository under `~/dotfiles`, and there are some absolute references in config files and scripts.

Environment:

- Arch Linux
- Bash shell
- X11 / i3 Environment
- Kitty terminal
- Based on Tomorrow night colorscheme
- SystemD

## Initialization

As this repository is based on `stow`, you should make sure that you've installed beforehand. To learn how to do that you can check out [Stow - GNU Project - Free Software Foundation](https://www.gnu.org/software/stow/). I think it's a pretty basic package and it's very probably that you can install it through your system package manager.

To have access to this repository, you can checkout this repository on `~/dotfiles` and initialize it

```bash
git clone http://github.org/ppalazon/dotfiles ~/dotfiles
cd ~/dotfiles
./stow-init.sh
```

## Structure

- `base`: Basic bash configuration
- `editors`: Configuration to work with editors
- `tui`: Text-Based User interface configuration programs
- `systemd`: User systemd services
- `x11`: Configuration for `x11` applications and graphical environment `i3`
- `_private`: Host private configuration files. No `git` or `synchthing` share

## Disclaimer

These dotfiles are tailored for my personal workflow and may not work correctly on every system without modification.

Always review install scripts before running them.

## License

Released under the MIT License.
See [LICENSE](./LICENSE).
