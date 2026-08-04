# Set up monitor layouts

Screen layouts are xrandr scripts saved in `~/.screenlayout`. You generate them once with `arandr`, then switch between them at runtime with `$mod+x`. The default one loads at login.

## Create a layout

1. Open `arandr` and arrange your monitors.
2. "Save As" and write the file to `~/.screenlayout/<name>.sh`.

The file is plain `xrandr` calls plus whatever else you need. Name the one used at login `default.sh`.

## Load the default at login

`monitor-init-layout` (`scripts/bin/sh/monitor-init-layout`) runs at session start from `x11/.xsession`. With no argument it executes `~/.screenlayout/default.sh`, then reloads the background from `~/.fehbg`, restarts the scratchpad (`hud-scratchpad -r`), and relaunches polybar.

## Switch at runtime

`$mod+x` is bound in `x11/.config/i3/config` to `monitor-selection`:

```sh
bindsym $mod+x exec monitor-selection
```

`monitor-selection` (`scripts/bin/sh/monitor-selection`) lists every `*.sh` in `~/.screenlayout` in rofi and calls `monitor-init-layout` with the selection. It sends a notification when the layout loads.

## Example layouts

Dual monitor, scaled HDMI

```sh
xrandr --output HDMI-1 --scale 1.33x1.33
xrandr --output DP-1 --primary --mode 2560x2880 --pos 2554x0 --rotate normal
xrandr --output HDMI-1 --mode 1920x1080 --pos 0x740 --rotate normal
```

Dual monitor, native

```sh
xrandr --output HDMI-1 --scale 1x1 --mode 1920x1080 --pos 0x791 --rotate normal \
--output DP-1 --primary --mode 2560x2880 --pos 1920x0 --rotate normal \
--output DP-2 --off
```

Laptop, docked or bare

```sh
xrandr --output eDP-1 --scale 1.33x1.33
DP1_STATUS=$(xrandr --query | grep "^DP-1 " | awk '{print $2}')
if [[ $DP1_STATUS == "connected" ]]; then
  xrandr --output DP-1 --primary --mode 2560x2880 --pos 2554x0 --rotate normal
  xrandr --output eDP-1 --mode 1920x1080 --pos 0x1440 --rotate normal
else
  xrandr --output DP-1 --off
  xrandr --output eDP-1 --primary --mode 1920x1080 --rotate normal
fi
```

Auto-detection from udev

```sh
#!/usr/bin/env bash

# udev waits for the script to finish before the monitor is usable,
# so re-run asynchronously with `at`.
if [ "$1" != "forked" ]; then
    echo "$(dirname "$0")/$(basename "$0") forked" | at now
    exit
fi

# udev runs as root, so point it at the X server:
export DISPLAY=:0
export XAUTHORITY=$HOME/.Xauthority

# Device path for the graphics card:
cardPath=/sys/$(udevadm info -q path -n /dev/dri/card0)

# Detect the monitor and, if connected, its EDID id:
conHdmi=$(xrandr | sed -n '/HDMI-1 connected/p')
shaHdmi=$(sha1sum "$cardPath/card0-HDMI-A-1/edid" | cut -f1 -d " ")

if [ -n "$conHdmi" ]; then
    if [ "$shaHdmi" = "784c277b180d701f8118ff993ac5dbd1b83d4ea1" ]; then
        # Office PC
        "$HOME/.screenlayout/hdmi-up.sh"
    else
        # Probably a projector
        xrandr --output eDP-1 --auto --output HDMI-1 --auto --same-as eDP-1
    fi
else
    xrandr --output eDP-1 --auto --output HDMI-1 --off
fi
```

## Why this way

| Where | What | Why | Breaks if |
| ----- | ---- | --- | --------- |
| `~/.screenlayout/*.sh` (generated with `arandr`) | xrandr shell scripts, one per monitor arrangement | `arandr` writes exact `xrandr` commands, so the layout is reproducible instead of hand-tuned per session | You lose per-monitor geometry and fall back to whatever the display server guesses |
| `monitor-init-layout` calls `~/.fehbg`, `hud-scratchpad -r`, `polybar-launcher` | Re-applies background, scratchpad, and status bar after every layout switch | Output geometry changes per layout, so a monitor-dependent bar and background must be re-applied after switching | Wallpaper and polybar stay on a disconnected output after switching |
| udev hook re-runs itself with `at now` | Forks the script out of udev | udev blocks until the script returns and runs as root, so `DISPLAY`/`XAUTHORITY` must be re-exported and the work moved out of udev's context | udev hangs on hotplug events and the script runs without access to the X server |
| udev hook compares the HDMI EDID sha1 | Distinguishes the office monitor from a generic projector | Plugging the same connector into two different displays needs different layout logic | The projector branch runs for the office monitor (or nothing runs) |
