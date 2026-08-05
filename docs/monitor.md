# Set up monitor layouts

Screen layouts are xrandr scripts in `~/.screenlayout`. `arandr` generates them once, and `$mod+x` switches them at runtime. The default layout loads at login.

## Create a layout

1. Open `arandr`.
2. Arrange the monitors.
3. Save the file as `~/.screenlayout/<name>.sh` with `"Save As"`.

The file is plain `xrandr` calls plus anything else that the layout needs. Name the layout that loads at login `default.sh`.

## Load the default at login

`monitor-init-layout` (`scripts/bin/sh/monitor-init-layout`) runs at session start from `x11/.xsession`. With no argument it runs `~/.screenlayout/default.sh`. Then it runs `~/.fehbg`, restarts the scratchpad with `hud-scratchpad -r`, and runs polybar again with `polybar-launcher`.

## Switch at runtime

`$mod+x` is bound in `x11/.config/i3/config` to `monitor-selection`:

```sh
bindsym $mod+x exec monitor-selection
```

`monitor-selection` (`scripts/bin/sh/monitor-selection`) lists every `*.sh` in `~/.screenlayout` in rofi and calls `monitor-init-layout` with the selection. When the layout loads, it sends a notification.

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
| `~/.screenlayout/*.sh` (generated with `arandr`) | Each layout is one xrandr shell script. | `arandr` writes exact `xrandr` commands, so the layout is reproducible instead of hand-tuned per session. | Without the exact `xrandr` commands, the display server guesses the per-monitor geometry. |
| `monitor-init-layout` calls `~/.fehbg`, `hud-scratchpad -r`, `polybar-launcher` | It re-applies the background, scratchpad, and status bar after every layout switch. | Output geometry changes per layout, so a monitor-dependent bar and background must be re-applied after switching. | If the calls are dropped, wallpaper and polybar stay on a disconnected output after switching. |
| udev hook (inline script above) | When the first argument is not `forked`, the script re-runs itself with `at now`. Then it sets `DISPLAY=:0` and `XAUTHORITY=$HOME/.Xauthority`. | udev waits for the script to return and runs as root, so the X server access must move outside udev. | If the fork is removed, udev hangs on hotplug events. If `DISPLAY` or `XAUTHORITY` is missing, the script has no access to the X server. |
| `sha1sum "$cardPath/card0-HDMI-A-1/edid"` | The script compares the HDMI EDID sha1 to `784c277b180d701f8118ff993ac5dbd1b83d4ea1`. | Plugging the same connector into two different displays needs different layout logic. | If the hash changes, the projector branch runs for the office monitor, or nothing runs. |
