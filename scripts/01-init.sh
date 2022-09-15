#!/usr/bin/bash

timedatectl set-ntp true

# Enable parallel downloads
sed -i 's/^#ParallelDownloads =.*/ParallelDownloads = 5/' /etc/pacman.conf

# Synchronize package databases
pacman -Sy
