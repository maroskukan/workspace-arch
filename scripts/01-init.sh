#!/usr/bin/bash

# Description: Arch Linux Initial Installation Script
# Author: Maros Kukan
# Usage: curl -s https://raw.githubusercontent.com/maroskukan/workspace-arch/main/scripts/01-init.sh | bash


# Create install log file
touch /tmp/install.log &>/dev/null \
  && echo -e "\e[32m[OK]\e[0m  Installation log file create at /tmp/install.log." \
  || echo -e "\e[31m[NOK]\e[0m Failed to create installation log."

# Enable NTP time synchronization
echo "Enabling NTP time synchronization..."
timedatectl set-ntp true &>>/tmp/install.log \
  && echo -e "\e[32m[OK]\e[0m  NTP timesync was enabled." \
  || echo -e "\e[31m[NOK]\e[0m Failed to enable NTP timesync."


# Update mirrors list
# echo "Updating pacman mirror list for live environment..."
# reflector > /etc/pacman.d/mirrorlist &>>/tmp/install.log \
#   && echo -e "\e[32m[OK]\e[0m  Mirrors list updated." \
#   || echo -e "\e[31m[NOK]\e[0m Failed to update mirror list."


# Enable parallel downloads
echo "Setting parallel downloads to 5..."
sed -i 's/^#ParallelDownloads =.*/ParallelDownloads = 5/' /etc/pacman.conf &>>/tmp/install.log \
  && echo -e "\e[32m[OK]\e[0m  Parallel downloads count set to 5." \
  || echo -e "\e[31m[NOK]\e[0m Failed to update parallel downloads count."


# Synchronize package databases
echo "Synchronizing pacman database for live environment..."
pacman -Sy &>>/tmp/install.log \
  && echo -e "\e[32m[OK]\e[0m  Pacman database updated." \
  || echo -e "\e[31m[NOK]\e[0m Failed to update pacman database."


# Install packages in live environment
echo "Installing virt-what package for live environment..."
pacman -S --noconfirm virt-what &>>/tmp/install.log \
  && echo -e "\e[32m[OK]\e[0m  Virt-what package installed." \
  || echo -e "\e[31m[NOK]\e[0m Failed to install virt-what package."
