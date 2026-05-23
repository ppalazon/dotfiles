#!/bin/bash
set -x
CHROOT_DIR="$HOME/centos"

umount ${CHROOT_DIR}/dev/pts
umount ${CHROOT_DIR}/dev/shm
umount ${CHROOT_DIR}/dev
umount ${CHROOT_DIR}/proc
umount ${CHROOT_DIR}/sys
umount ${CHROOT_DIR}/run
umount ${CHROOT_DIR}/tmp/.X11-unix


