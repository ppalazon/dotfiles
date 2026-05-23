#!/bin/sh
# This file is used by display managers to start the session.

# Used by dunst
systemctl --user import-environment DISPLAY

#exec xss-lock -- i3lock -c 333333 &
#pgrep redshift &> /dev/null || redshift &> /dev/null &

# Add this to your .xinitrc or whatever file starts programs on startup.
# -R restores the last colorscheme that was in use.
# -n doesn't set wallpaper
# wal -R -n

# autocutsel -fork &
# autocutsel -selection PRIMARY -fork &

# Start keepassxc by default
# keepassxc &

# $(eval keychain id_rsa 37409E79 --agents gpg,ssh --gpg2)
# [ -f $HOME/.keychain/$HOSTNAME-sh ] && \
#   . $HOME/.keychain/$HOSTNAME-sh
# [ -f $HOME/.keychain/$HOSTNAME-sh-gpg ] && \
#   . $HOME/.keychain/$HOSTNAME-sh-gpg

# Autokey
autokey-qt &

# Udiskie
udiskie --tray &

# Host specific i3 config
# ln -sf ${HOME}/.config/i3/config-$(hostname) ${HOME}/.config/i3/config

# Start the compositor
# picom -b

# Configure screen scale on cyberdyne host
monitor-init-layout &

# Configure locker
xss-lock -- i3lock -c 333333 -i /usr/share/backgrounds/apod/apod &