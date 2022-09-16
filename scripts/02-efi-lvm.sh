#!/usr/bin/bash
set -e

# Description: Arch Linux Initial Installation Script
# Author: Maros Kukan
# Usage: curl -s https://raw.githubusercontent.com/maroskukan/workspace-arch/main/scripts/02-efi-lvm.sh | bash



# Verify if EUFI is supported
ls /sys/firmware/efi/efivars &>/dev/null \
   && echo '\e[32m[OK]\e[0m Target has EUFI enabled.' \
   || echo '\e[31m[NOK]\e[0m Target has BIOS enabled.'


# Create new empty GPT partition table
echo "Creating GPT label at /dev/sda..."
parted -s /dev/sda mklabel gpt &>>/tmp/install.log \
  && echo -e "\e[32m[OK]\e[0m  GPT label added." \
  || echo -e "\e[31m[NOK]\e[0m Failed to add GPT label."


# Create new primary partition
echo "Creating EFI partition..."
parted -a optimal /dev/sda --script mkpart primary fat32 1MiB 501MiB &>>/tmp/install.log \
  && echo -e "\e[32m[OK]\e[0m  EFI partition created." \
  || echo -e "\e[31m[NOK]\e[0m Failed to create EFI partition."


echo "Creating root partition..."
parted -a optimal /dev/sda --script mkpart primary ext4 501MiB 100% &>>/tmp/install.log \
  && echo -e "\e[32m[OK]\e[0m  Root partition created." \
  || echo -e "\e[31m[NOK]\e[0m Failed to create Root partition."


# Update partition type
echo "Setting EFI partition type to EFI..."
parted -a optimal /dev/sda --script set 1 esp on &>>/tmp/install.log \
  && echo -e "\e[32m[OK]\e[0m  EFI partition type updated." \
  || echo -e "\e[31m[NOK]\e[0m Failed to set EFI partition type."


echo "Setting root partition type to LVM..."
parted -a optimal /dev/sda --script set 2 lvm on &>>/tmp/install.log \
  && echo -e "\e[32m[OK]\e[0m  LVM partition type updated." \
  || echo -e "\e[31m[NOK]\e[0m Failed to set LVM partition type."


# Create new physical volume
echo "Creating LVM physical volume..."
pvcreate --dataalignment 1m /dev/sda2 &>>/tmp/install.log \
  && echo -e "\e[32m[OK]\e[0m  LVM physical volume created." \
  || echo -e "\e[31m[NOK]\e[0m Failed to create LVM physical volume."

# Create a new volume group
echo "Creating LVM volume group..."
vgcreate volgroup0 /dev/sda2 &>>/tmp/install.log \
  && echo -e "\e[32m[OK]\e[0m  LVM volume group created." \
  || echo -e "\e[31m[NOK]\e[0m Failed to create LVM volume group."

# Create logical volume for root
echo "Creating logical volume for root..."
lvcreate -L 16G volgroup0 -n lv_root &>>/tmp/install.log \
  && echo -e "\e[32m[OK]\e[0m  LVM logical volume created." \
  || echo -e "\e[31m[NOK]\e[0m Failed to create LVM logical volume."

# Create logical volume for home
echo "Creating logical volume for home..."
lvcreate -l 100%FREE volgroup0 -n lv_home &>>/tmp/install.log \
  && echo -e "\e[32m[OK]\e[0m  LVM logical volume created." \
  || echo -e "\e[31m[NOK]\e[0m Failed to create LVM logical volume."

# Load kernel module
echo "Loading device mapper kernel module..."
modprobe dm_mod &>>/tmp/install.log \
  && echo -e "\e[32m[OK]\e[0m  Kernel module loaded." \
  || echo -e "\e[31m[NOK]\e[0m Failed to load kernel module."

# Scan for volume groups
echo "Scaning for logical volumes..."
vgscan &>>/tmp/install.log \
  && echo -e "\e[32m[OK]\e[0m  Volume scan successfull." \
  || echo -e "\e[31m[NOK]\e[0m Failed scan new volumes."

# Activate
echo "Activating new volume group..."
vgchange -ay &>>/tmp/install.log \
  && echo -e "\e[32m[OK]\e[0m  Volume group activated." \
  || echo -e "\e[31m[NOK]\e[0m Failed to activate volume group."
