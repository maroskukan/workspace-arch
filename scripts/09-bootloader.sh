#!/usr/bin/bash
set -e

# Description: Arch Linux Initial Installation Script
# Author: Maros Kukan
# Usage: curl -s https://raw.githubusercontent.com/maroskukan/workspace-arch/main/scripts/09-bootloader.sh | bash


echo "Installing packages for bootloader..."
arch-chroot /mnt pacman -S --noconfirm \
    grub \
    efibootmgr \
    dosfstools \
    os-prober \
    mtools &>>/tmp/install.log \
  && echo -e "\e[32m[OK]\e[0m  Packages installed." \
  || echo -e "\e[31m[NOK]\e[0m Failed to install packages."


echo "Mounting EFI partition on target..."
arch-chroot /mnt mount --mkdir /dev/sda1 /boot/EFI &>>/tmp/install.log \
  && echo -e "\e[32m[OK]\e[0m  EFI partition mounted." \
  || echo -e "\e[31m[NOK]\e[0m Failed mount EFI partition."


echo "Installing GRUB bootloader..."
arch-chroot /mnt grub-install --target=x86_64-efi --bootloader-id=grub_eufi --recheck &>>/tmp/install.log \
  && echo -e "\e[32m[OK]\e[0m  Bootloader installed." \
  || echo -e "\e[31m[NOK]\e[0m Failed to install bootloader."


echo "Generating GRUB locale..."
arch-chroot /mnt cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo &>>/tmp/install.log \
  && echo -e "\e[32m[OK]\e[0m  Grub locale installed." \
  || echo -e "\e[31m[NOK]\e[0m Failed to install Grub locale."
 

 echo "Generating GRUB configuration..."
 arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg &>>/tmp/install.log \
  && echo -e "\e[32m[OK]\e[0m  Grub configuration generated." \
  || echo -e "\e[31m[NOK]\e[0m Failed to generate Grub configuration."
