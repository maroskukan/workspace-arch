#!/usr/bin/bash

# Update mirror list
echo "Updating mirror list."
reflector > /etc/pacman.d/mirrorlist \
  && echo "[OK]  Mirrors list updated." \
  || echo "[NOK] Failed to update mirror list."

# Kernel and headers
pacstrap /mnt base linux linux-headers 
  && echo "[OK]  Packstrap was completed." \
  || echo "[NOK] Failed to pacstrap the base."

arch-chroot /mnt pacman -S --noconfirm vim git base-devel openssh networkmanager dialog lvm2
arch-chroot /mnt systemctl enable {sshd,NetworkManager}