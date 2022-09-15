#!/usr/bin/bash

# Verify if EUFI is supported
ls /sys/firmware/efi/efivars && echo 'EUFI Install' || echo 'BIOS Install'

# Create new empty GPT partition table
parted -s /dev/sda mklabel gpt

# Create new primary partition
parted -a optimal /dev/sda --script mkpart primary fat32 1MiB 501MiB
parted -a optimal /dev/sda --script mkpart primary ext4 501MiB 100%

# Update partition type
parted -a optimal /dev/sda --script set 1 esp on
parted -a optimal /dev/sda --script set 2 lvm on

# Create new physical volume
pvcreate --dataalignment 1m /dev/sda2

# Create a new volume group
vgcreate volgroup0 /dev/sda2

# Create logical volume for root
lvcreate -L 16G volgroup0 -n lv_root

# Create logical volume for home
lvcreate -l 100%FREE volgroup0 -n lv_home

# Load kernel module
modprobe dm_mod

# Scan for volume groups
vgscan

# Activate
vgchange -ay
