#!/usr/bin/bash
set -e

# Description: Arch Linux Initial Installation Script
# Author: Maros Kukan
# Usage: curl -s https://raw.githubusercontent.com/maroskukan/workspace-arch/main/scripts/03-filesystem.sh | bash


# Create Fat32 for EFI parition
echo "Creating filesystem for EFI partition..."
mkfs.fat -F32 /dev/sda1 &>>/tmp/install.log \
    && echo -e "\e[32m[OK]\e[0m  Filesystem created." \
    || echo -e "\e[31m[NOK]\e[0m Failed to create filesystem."

# Create Ext4 for root
echo "Creating filesystem for root volume..."
mkfs.ext4 /dev/volgroup0/lv_root &>>/tmp/install.log \
    && echo -e "\e[32m[OK]\e[0m  Filesystem created." \
    || echo -e "\e[31m[NOK]\e[0m Failed to create filesystem."

# Create Ext4 for home
echo "Creating filesystem for home volume..."
mkfs.ext4 /dev/volgroup0/lv_home &>>/tmp/install.log \
    && echo -e "\e[32m[OK]\e[0m  Filesystem created." \
    || echo -e "\e[31m[NOK]\e[0m Failed to create filesystem."

# Mount root fs
echo "Mounting root volume..."
mount /dev/volgroup0/lv_root /mnt &>>/tmp/install.log \
    && echo -e "\e[32m[OK]\e[0m  Volume mounted." \
    || echo -e "\e[31m[NOK]\e[0m Failed to mount volume."

# Mount /home 
echo "Mounting home volume..."
mount --mkdir /dev/volgroup0/lv_home /mnt/home &>>/tmp/install.log \
    && echo -e "\e[32m[OK]\e[0m  Volume mounted." \
    || echo -e "\e[31m[NOK]\e[0m Failed to mount volume."

# Generate fstab
echo "Creating /etc on target..."
mkdir /mnt/etc &>>/tmp/install.log \
    && echo -e "\e[32m[OK]\e[0m  Folder created." \
    || echo -e "\e[31m[NOK]\e[0m Failed to create folder."

echo "Generating filelsystem table on target..."
genfstab -U -p /mnt | tee /mnt/etc/fstab &>>/tmp/install.log \
    && echo -e "\e[32m[OK]\e[0m  Filesystem table created." \
    || echo -e "\e[31m[NOK]\e[0m Failed to create filesystem table."
