#!/bin/bash
set -ex
CHROOT_DIR="$HOME/centos"

mkdir -p ${CHROOT_DIR}/{dev,proc,sys,run,tmp/.X11-unix}

mount --bind /dev ${CHROOT_DIR}/dev
mount --bind /dev/pts ${CHROOT_DIR}/dev/pts
mount --bind /proc ${CHROOT_DIR}/proc
mount --bind /sys ${CHROOT_DIR}/sys
mount --bind /run ${CHROOT_DIR}/run
mount --bind /dev/shm ${CHROOT_DIR}/dev/shm


# Mount X11 socket for X server access
mount --bind /tmp/.X11-unix ${CHROOT_DIR}/tmp/.X11-unix


# Copy the Xauthority file to allow X11 access
cp $HOME/.Xauthority ${CHROOT_DIR}/root/.Xauthority
cp $HOME/.Xauthority ${CHROOT_DIR}/home/user/.Xauthority


# Set the correct permissions on the .Xauthority file inside the chroot
chroot ${CHROOT_DIR} chown root:root /root/.Xauthority
chroot ${CHROOT_DIR} chown 1000:1000 /home/user/.Xauthority

# Export DISPLAY variable
export DISPLAY=:0
echo "Bind mounts completed and DISPLAY variable set to $DISPLAY."

# allow local connections to the X system
xhost +

# copy host resolv.conf file
cp /etc/resolv.conf ${CHROOT_DIR}/etc
