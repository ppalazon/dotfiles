#!/bin/bash

set -x

[[ -d ~/bin ]] || mkdir ~/bin

stow -Sv --no-folding base
stow -Sv --no-folding editors
stow -Sv --no-folding tui
stow -Sv --no-folding x11
stow -Sv --no-folding systemd
stow -Sv scripts
stow -Sv autokey

if [[ -d _private ]]; then
  stow -Sv --no-folding _private
fi

#mkdir -p ~/.local/share/applications
#ln -sf ~/.config/mimeapps.list ~/.local/share/applications/mimeapps.list