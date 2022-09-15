#!/usr/bin/bash

# Expire root password
arch-chroot /mnt chage -d 0 root

# Umount /mnt
umount -R /mnt

# Reboot
reboot
