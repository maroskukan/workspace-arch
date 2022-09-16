#!/usr/bin/bash
set -e

# Description: Arch Linux Initial Installation Script
# Author: Maros Kukan
# Usage: curl -s https://raw.githubusercontent.com/maroskukan/workspace-arch/main/scripts/08-accounts.sh | bash


echo "Creating new user account..."
arch-chroot /mnt useradd -m -g users maros &>>/tmp/install.log \
  && echo -e "\e[32m[OK]\e[0m  User account created." \
  || echo -e "\e[31m[NOK]\e[0m Failed to create user account."


# Set Initial password - this does not work
echo "Setting the initial password to 'changeme'"
arch-chroot /mnt sh -c 'echo "maros:changeme"|chpasswd' &>>/tmp/install.log \
  && echo -e "\e[32m[OK]\e[0m  User password set." \
  || echo -e "\e[31m[NOK]\e[0m Failed to set user password."


# Force user to change after initial login
echo "Forcing password change after first login..."
arch-chroot /mnt chage -d 0 maros &>>/tmp/install.log \
  && echo -e "\e[32m[OK]\e[0m  User password set to expire." \
  || echo -e "\e[31m[NOK]\e[0m Failed to set user password exiration."


# Allow user to use sudo
echo "Adding user account ..."
arch-chroot /mnt sh -c 'echo "maros ALL=(ALL) ALL" | tee /etc/sudoers.d/maros' &>>/tmp/install.log \
  && echo -e "\e[32m[OK]\e[0m  User added to sudoers." \
  || echo -e "\e[31m[NOK]\e[0m Failed to add user to sudoers."
