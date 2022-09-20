#!/usr/bin/env bash
#
# Copyright (C):  2022 Maros Kukan <maros.kukan@me.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# A simple script to automate part of Arch Linux installation.


set -euo pipefail

create_log() {
    echo "Creating installation log file at /tmp/install.log..."
    touch /tmp/install.log &>/dev/null \
        && echo -e "\e[32m[ OK ]\e[0m  Installation log file created." \
        || echo -e "\e[31m[ NOK ]\e[0m Failed to create installation log."; exit 1
}

enable_ntp() {
    echo "Enabling NTP time synchronization..."
    timedatectl set-ntp true &>>/tmp/install.log \
        && echo -e "\e[32m[ OK ]\e[0m  NTP timesync was enabled." \
        || echo -e "\e[31m[ NOK ]\e[0m Failed to enable NTP timesync."; exit 1
}

update_mirrors() {
    echo "Updating pacman mirror list for live environment..."
    reflector > /etc/pacman.d/mirrorlist &>>/tmp/install.log \
        && echo -e "\e[32m[ OK ]\e[0m  Mirrors list updated." \
        || echo -e "\e[31m[ NOK ]\e[0m Failed to update mirror list."; exit 1
}

enable_parralels() {
    echo "Setting parallel downloads to 5..."
    sed -i 's/^#ParallelDownloads =.*/ParallelDownloads = 5/' /etc/pacman.conf &>>/tmp/install.log \
        && echo -e "\e[32m[ OK ]\e[0m  Parallel downloads count set to 5." \
        || echo -e "\e[31m[ NOK ]\e[0m Failed to update parallel downloads count."; exit 1
}

sync_packs() {
    echo "Synchronizing pacman database for live environment..."
    pacman -Sy &>>/tmp/install.log \
        && echo -e "\e[32m[ OK ]\e[0m  Pacman database updated." \
        || echo -e "\e[31m[ NOK ]\e[0m Failed to update pacman database."; exit 1
}

install_packs() {
    echo "Installing virt-what package for live environment..."
    pacman -S --noconfirm virt-what &>>/tmp/install.log \
        && echo -e "\e[32m[ OK ]\e[0m  Virt-what package installed." \
        || echo -e "\e[31m[ NOK ]\e[0m Failed to install virt-what package."; exit 1
}

create_log
enable_ntp
enable_parrallels
sync_packs
install_packs
