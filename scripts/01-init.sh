#!/usr/bin/bash

# Description: Arch Linux Initial Installation Script
# Author: Maros Kukan


# Enable NTP time synchronization
echo "Enabling NTP time synchronization..."
timedatectl set-ntp true &>/dev/null \
  && echo -e "\e[32m[OK]\e[0m  NTP timesync was enabled." \
  || echo -e "\e[31m[NOK]\e[0m Failed enable NTP timesync."


# Update mirrors list
echo "Uptating pacman mirror list for live environment..."
reflector > /etc/pacman.d/mirrorlist &>/dev/null \
  && echo "\e[32m[OK]\e[0m  Mirrors list updated." \
  || echo "\e[31m[NOK]\e[0m Failed to update mirror list."


# Enable parallel downloads
echo "Setting parallel downloads to 5..."
sed -i 's/^#ParallelDownloads =.*/ParallelDownloads = 5/' /etc/pacman.conf \
  && echo "\e[32m[OK]\e[0m  Parallel downloads count set to 5." \
  || echo "\e[31m[NOK]\e[0m Failed to update parallel downloads count."


# Synchronize package databases
echo "Synchronizing pacman database for live environment..."
pacman -Sy &>/dev/null \
  && echo "\e[32m[OK]\e[0m  Pacman database updated." \
  || echo "\e[31m[NOK]\e[0m Failed to update pacman database."


# Install packages in live environment
echo "Installing virt-what package for live environment..."
pacman -S --noconfirm virt-what &>/dev/null \
  && echo "\e[32m[OK]\e[0m  Virt-what package installed." \
  || echo "\e[31m[NOK]\e[0m Failed to install virt-what package."
