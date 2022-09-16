#!/usr/bin/bash

# Kernel and headers
echo "Packstrapping base and kernel..."
pacstrap /mnt base linux linux-headers &>/dev/null \
  && echo "[OK]  Packstrap was completed." \
  || echo "[NOK] Failed to pacstrap the base."

# Update target mirror list
echo "Updating target mirror list..."
reflector > /mnt/etc/pacman.d/mirrorlist &>/dev/null \
  && echo "[OK]  Mirrors list updated." \
  || echo "[NOK] Failed to update mirror list."

# Sometimes pacman fails to unlock db in time
sleep 10

arch-chroot /mnt pacman -S --noconfirm \
  base-devel \
  dialog \
  git \
  networkmanager \
  lvm2 \
  openssh \
  vim

arch-chroot /mnt systemctl enable {sshd,NetworkManager}