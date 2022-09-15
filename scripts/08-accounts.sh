#!/usr/bin/bash

# Set root password
arch-chroot /mnt sh -c 'echo "root:changeme"|chpasswd'

arch-chroot /mnt useradd -m -g users maros

# Set Initial password - this does not work
arch-chroot /mnt sh -c 'echo "maros:changeme"|chpasswd'

# Force user to change after initial login
arch-chroot /mnt chage -d 0 maros

# Allow user to use sudo
arch-chroot /mnt sh -c 'echo "maros ALL=(ALL) ALL" | tee /etc/sudoers.d/maros'
