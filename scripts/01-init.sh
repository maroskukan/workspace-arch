#!/usr/bin/bash

timedatectl set-ntp true

# Enable parallel downloads
sed -i 's/^#ParallelDownloads =.*/ParallelDownloads = 5/' /etc/pacman.conf

# Synchronize package databases
pacman -Sy

# Install packages in live environment
pacman -S virt-what