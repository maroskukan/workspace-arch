#!/usr/bin/bash

# Description: Arch Linux Initial Installation Script
# Author: Maros Kukan

# Enable NTP time synchronization
timedatectl set-ntp true

# Enable parallel downloads
sed -i 's/^#ParallelDownloads =.*/ParallelDownloads = 5/' /etc/pacman.conf

# Synchronize package databases
pacman -Sy

# Install packages in live environment
pacman -S --noconfirm virt-what