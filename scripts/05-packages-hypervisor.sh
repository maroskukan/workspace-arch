#!/usr/bin/bash
set -e

# Description: Arch Linux Initial Installation Script
# Author: Maros Kukan
# Usage: curl -s https://raw.githubusercontent.com/maroskukan/workspace-arch/main/scripts/05-packages-hypervisor.sh | bash


# Retrieve Host Hypervisor
declare -xr HYPERVISOR=$(virt-what)

# Install Hypervisor specific packages
case $HYPERVISOR in
    hyperv)
        echo "Installing packages for Hyper-V support..."
        arch-chroot /mnt pacman -S --noconfirm hyperv &>>/tmp/install.log \
            && echo -e "\e[32m[OK]\e[0m  Packages installed." \
            || echo -e "\e[31m[NOK]\e[0m Failed to install packages."
        echo "Enabling services for Hyper-V support..."
        arch-chroot /mnt systemctl enable {hv_fcopy_daemon,hv_kvp_daemon,hv_vss_daemon} &>>/tmp/install.log \
            && echo -e "\e[32m[OK]\e[0m  Services enabled." \
            || echo -e "\e[31m[NOK]\e[0m Failed to enable services."
        ;;
    virtualbox)
        echo "Installing packages for Virtualbox support..."
        arch-chroot /mnt pacman -S --noconfirm virtualbox-guest-utils &>>/tmp/install.log \
            && echo -e "\e[32m[OK]\e[0m  Packages installed." \
            || echo -e "\e[31m[NOK]\e[0m Failed to install packages."
        ;;
    *)
        echo "\e[33m[INFO]\e[0m No hypervisor detected skipping, specific packages..."
        ;;
esac
