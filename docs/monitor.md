# Monitor configuration

## Screenlayouts

Generate screenlayout with `arandr`, and save them on `~/.screenlayout`

On startup -> execute default.sh

## Select monitor

Execute script `monitor-selection` or `Win+x` to open rofi selection. It would get the screenlayout on `~/.screenlayout`

## Avoid sharing

It depends of the machine

## Examples

One monitor with 1920x1080 and another one 

```sh
xrandr --output HDMI-1 --scale 1.33x1.33
xrandr --output DP-1 --primary --mode 2560x2880 --pos 2554x0 --rotate normal 
xrandr --output HDMI-1 --mode 1920x1080 --pos 0x740 --rotate normal
```

Native

```sh
xrandr --output HDMI-1 --scale 1x1 --mode 1920x1080 --pos 0x791 --rotate normal \
--output DP-1 --primary --mode 2560x2880 --pos 1920x0 --rotate normal \
--output DP-2 --off
```

Laptop

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

Auto disp

```sh
#!/usr/bin/bash

# udev will wait for our script to finish before the monitor is available
# for use, so we will use the `at` command to run our command again as
# another user:
if [ "$1" != "forked" ]; then
    echo "$(dirname $0)/$(basename $0) forked" | at now
    exit
fi

# udev runs as root, so we need to tell it how to connect to the X server:
export DISPLAY=:0
export XAUTHORITY=$HOME/.Xauthority

# Find out the device path to our graphics card:
cardPath=/sys/$(udevadm info -q path -n /dev/dri/card0)

# Detect if the monitor is connected and, if so, the monitor's ID:
conHdmi=$(xrandr | sed -n '/HDMI-1 connected/p')
shaHdmi=$(sha1sum $cardPath/card0-HDMI-A-1/edid | cut -f1 -d " ")

# The useful part: check what the connection status is, and run some other commands
if [ -n "$conHdmi" ]; then
    if [ "$shaHdmi" = "784c277b180d701f8118ff993ac5dbd1b83d4ea1" ]; then    
        # Office PC
        #xrandr --output eDP-1 --auto --output HDMI-1 --auto --up-of eDP-1
	    $HOME/.screenlayout/hdmi-up.sh
    else                                            
        # Probably a projector
        xrandr --output eDP-1 --auto --output HDMI-1 --auto --same-as eDP-1
    fi
else
    xrandr --output eDP-1 --auto --output HDMI-1 --off
fi
```