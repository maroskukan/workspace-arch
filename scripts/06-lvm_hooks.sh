#!/usr/bin/bash

arch-chroot /mnt cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.bak
arch-chroot /mnt sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect modconf block lvm2 filesystems keyboard fsck)/' /etc/mkinitcpio.conf

arch-chroot /mnt mkinitcpio -p linux
