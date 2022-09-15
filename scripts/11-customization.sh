#!/usr/bin/bash

dd if=/dev/zero of=/swapfile bs=1M count=2048

chmod 600 /swapfile
mkswap /swapfile

cp /etc/fstab /etc/fstab.bak
echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab

mount -a
swapon -a

timedatectl set-timezone Europe/Bratislava
timedatectl set-ntp true
systemctl enable systemd-timesyncd

hwclock --systohc

hostnamectl set-hostname dojo.localdomain
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 dojo dojo.localdomain" >> /etc/hosts
