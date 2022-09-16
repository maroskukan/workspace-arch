#!/usr/bin/bash

# Retrieve Host Hypervisor
declare -xr HYPERVISOR=$(virt-what)

# Install Hypervisor specific packages
case $HYPERVISOR in

  hyperv)
    echo -n "Installing packages for Hyper-V support..."
    arch-chroot /mnt pacman -S --noconfirm hyperv
    arch-chroot /mnt systemctl enable {hv_fcopy_daemon,hv_kvp_daemon,hv_vss_daemon}
    ;;
  virtualbox)
    echo -n "Installing packages for Virtualbox support..."
    arch-chroot /mnt pacman -S --noconfirm virtualbox-guest-utils
    ;;
  *)
    echo -n "Skipping installation hypervisor specific packages..."
  ;;
esac
