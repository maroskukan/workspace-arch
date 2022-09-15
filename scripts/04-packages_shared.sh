#!/usr/bin/bash

# Update mirror list
reflector > /etc/pacman.d/mirrorlist

# Kernel and headers
pacstrap /mnt base linux linux-headers 

arch-chroot /mnt pacman -S --noconfirm vim git base-devel openssh networkmanager dialog lvm2
arch-chroot /mnt systemctl enable {sshd,NetworkManager}