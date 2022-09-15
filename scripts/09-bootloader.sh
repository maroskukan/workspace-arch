#!/usr/bin/bash

arch-chroot /mnt pacman -S --noconfirm grub efibootmgr dosfstools os-prober mtools

arch-chroot /mnt mount --mkdir /dev/sda1 /boot/EFI

arch-chroot /mnt grub-install --target=x86_64-efi --bootloader-id=grub_eufi --recheck

