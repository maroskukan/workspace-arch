#!/usr/bin/bash
set -e

# Description: Arch Linux Initial Installation Script
# Author: Maros Kukan
# Usage: curl -s https://raw.githubusercontent.com/maroskukan/workspace-arch/main/scripts/06-lvm-hooks.sh | bash


echo "Backing up /etc/mkinitcpio.conf on target..."
arch-chroot /mnt cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.bak &>>/tmp/install.log \
  && echo -e "\e[32m[OK]\e[0m  Backup created." \
  || echo -e "\e[31m[NOK]\e[0m Failed to create backup."

echo "Adding lvm2 to initramfs HOOKS..."
arch-chroot /mnt sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect modconf block lvm2 filesystems keyboard fsck)/' /etc/mkinitcpio.conf &>>/tmp/install.log \
  && echo -e "\e[32m[OK]\e[0m  lvm2 added to HOOKS list." \
  || echo -e "\e[31m[NOK]\e[0m Failed to add lvm2 to HOOKS list."

echo "Creating initial ramdisk for linux kernel..."
arch-chroot /mnt mkinitcpio -p linux &>>/tmp/install.log \
  && echo -e "\e[32m[OK]\e[0m  Ramdisk created." \
  || echo -e "\e[31m[NOK]\e[0m Failed to ramdisk."
