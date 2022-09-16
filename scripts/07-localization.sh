#!/usr/bin/bash
set -e

# Description: Arch Linux Initial Installation Script
# Author: Maros Kukan
# Usage: curl -s https://raw.githubusercontent.com/maroskukan/workspace-arch/main/scripts/07-localization.sh | bash


echo "Backing up /etc/locale.gen on target..."
arch-chroot /mnt cp /etc/locale.gen /etc/locale.gen.bak &>>/tmp/install.log \
  && echo -e "\e[32m[OK]\e[0m  Backup created." \
  || echo -e "\e[31m[NOK]\e[0m Failed to create backup."


echo "Selecting en_US.UTF-8..."
arch-chroot /mnt  sed -i 's/^#en_US.UTF-8.*/en_US.UTF-8 UTF-8/' /etc/locale.gen &>>/tmp/install.log \
  && echo -e "\e[32m[OK]\e[0m  Local selected." \
  || echo -e "\e[31m[NOK]\e[0m Failed to select locale."


echo "Generating locale..."
arch-chroot /mnt locale-gen &>>/tmp/install.log \
  && echo -e "\e[32m[OK]\e[0m  Local generated." \
  || echo -e "\e[31m[NOK]\e[0m Failed to generate locale."


echo "Creatint /etc/locale.conf on target..."
arch-chroot /mnt sh -c 'echo "LANG=en_US.UTF-8" > /etc/locale.conf' &>>/tmp/install.log \
  && echo -e "\e[32m[OK]\e[0m  File generated." \
  || echo -e "\e[31m[NOK]\e[0m Failed to generate file."
