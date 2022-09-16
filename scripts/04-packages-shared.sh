#!/usr/bin/bash
set -e

# Description: Arch Linux Initial Installation Script
# Author: Maros Kukan
# Usage: curl -s https://raw.githubusercontent.com/maroskukan/workspace-arch/main/scripts/04-packages-shared.sh | bash


# Kernel and headers
# Sometimes this step fails with following error messages
# ==> unshare: sigprocmask unblock failed: Invalid argument
# Remove the lock at /mnt/var/lib/pacman/db.lck and try again
echo "Packstrapping base and kernel..."
pacstrap /mnt base linux linux-headers &>>/tmp/install.log \
  && echo -e "\e[32m[OK]\e[0m  Packstrap was completed." \
  || echo -e "\e[31m[NOK]\e[0m Failed to pacstrap the base." \
  rm /mnt/var/lib/pacman/db.lck


# Update target mirror list
echo "Updating target mirror list..."
reflector > /mnt/etc/pacman.d/mirrorlist &>>/tmp/install.log \
  && echo -e "\e[32m[OK]\e[0m  Mirrors list updated." \
  || echo -e "\e[31m[NOK]\e[0m Failed to update mirror list."


# Sometimes pacman fails to unlock db in time
sleep 10


# Install common packages
echo "Installing common packages..."
arch-chroot /mnt pacman -S --noconfirm &>>/tmp/install.log \
  base-devel \
  dialog \
  git \
  networkmanager \
  lvm2 \
  openssh \
  vim \
  && echo -e "\e[32m[OK]\e[0m Common packages installed." \
  || echo -e "\e[31m[NOK]\e[0m Failed to install common packages." \
  rm /mnt/var/lib/pacman/db.lck


# Enable SSH server and Network Namanger at boot
echo "Enabling SSHD and Network Managet at boot"
arch-chroot /mnt systemctl enable {sshd,NetworkManager} &>>/tmp/install.log \
  && echo -e "\e[32m[OK]\e[0m SSH Server and Network Manager enabled." \
  || echo -e "\e[31m[NOK]\e[0m Failed to enable SSH Server and Network Manager."
