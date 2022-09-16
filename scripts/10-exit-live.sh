#!/usr/bin/bash
set -e

# Description: Arch Linux Initial Installation Script
# Author: Maros Kukan
# Usage: curl -s https://raw.githubusercontent.com/maroskukan/workspace-arch/main/scripts/10-exit-live.sh | bash


# Set Initial password
echo "Setting the root initial password to 'changeme'"
arch-chroot /mnt sh -c 'echo "root:changeme"|chpasswd' &>>/tmp/install.log \
  && echo -e "\e[32m[OK]\e[0m  Root password set." \
  || echo -e "\e[31m[NOK]\e[0m Failed to set root password."


# Force root to change after initial login
echo "Forcing password change after first login..."
arch-chroot /mnt chage -d 0 root &>>/tmp/install.log \
  && echo -e "\e[32m[OK]\e[0m  Root password set to expire." \
  || echo -e "\e[31m[NOK]\e[0m Failed to set root password exiration."


echo "Saving installation log to target..."
cp /tmp/install.log /mnt/tmp/install.log &>/dev/null \
  && echo -e "\e[32m[OK]\e[0m  Installation log exported." \
  || echo -e "\e[31m[NOK]\e[0m Failed to export installation log."


# Umount /mnt
echo "Umounting target /mnt..."
umount -R /mnt &>/dev/null \
  && echo -e "\e[32m[OK]\e[0m  Target umounted." \
  || echo -e "\e[31m[NOK]\e[0m Failed to umount target."


# Reboot
echo "\e[33m[INFO]\e[0m The base installation is completed. Type 'reboot' to boot to target."
echo "\e[33m[INFO]\e[0m Login on TTY or SSH with user 'maros' with password of 'changeme'"
