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

# Install common packages
echo "Installing common packages..."
arch-chroot /mnt pacman -S --noconfirm &>/dev/null \
  base-devel \
  dialog \
  git \
  networkmanager \
  lvm2 \
  openssh \
  vim \
  && echo "[OK] Common packages installed." \
  || echo "[NOK] Failed to install common packages."

# Enable SSH server and Network Namanger at boot
echo "Enabling SSHD and Network Managet at boot"
arch-chroot /mnt systemctl enable {sshd,NetworkManager} &>/dev/null \
  && echo "[OK] SSH Server and Network Manager enabled." \
  || echo "[NOK] Failed to enable SSH Server and Network Manager."
