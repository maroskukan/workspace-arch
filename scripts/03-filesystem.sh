#!/usr/bin/bash

# Create Fat32 for EFI parition
mkfs.fat -F32 /dev/sda1

# Create Ext4 for root
mkfs.ext4 /dev/volgroup0/lv_root

# Create Ext4 for home
mkfs.ext4 /dev/volgroup0/lv_home

# Mount root fs
mount /dev/volgroup0/lv_root /mnt

# Mount /home 
mount --mkdir /dev/volgroup0/lv_home /mnt/home

# Generate fstab
mkdir /mnt/etc
genfstab -U -p /mnt >> /mnt/etc/fstab
