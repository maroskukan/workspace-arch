#!/usr/bin/bash

# Update mirror list
echo "Updating mirror list..."
reflector > /etc/pacman.d/mirrorlist &>/dev/null \
  && echo "[OK]  Mirrors list updated." \
  || echo "[NOK] Failed to update mirror list."

# Kernel and headers
echo "Packstrapping base and kernel..."
pacstrap /mnt base linux linux-headers &>/dev/null \
  && echo "[OK]  Packstrap was completed." \
  || echo "[NOK] Failed to pacstrap the base."

# Sometimes pacman fails to unlock db in time
sleep 10

arch-chroot /mnt pacman -S --noconfirm vim git base-devel openssh networkmanager dialog lvm2
arch-chroot /mnt systemctl enable {sshd,NetworkManager}