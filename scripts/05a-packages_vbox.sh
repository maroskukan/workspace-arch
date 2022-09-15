#!/usr/bin/bash

arch-chroot /mnt sed -i 's/^#ParallelDownloads =.*/ParallelDownloads = 5/' /etc/pacman.conf

arch-chroot /mnt pacman -S --noconfirm virtualbox-guest-utils
