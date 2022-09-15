#!/usr/bin/bas

arch-chroot /mnt cp /etc/locale.gen /etc/locale.gen.bak
arch-chroot /mnt  sed -i 's/^#en_US.UTF-8.*/en_US.UTF-8 UTF-8/' /etc/locale.gen

arch-chroot /mnt locale-gen

arch-chroot /mnt sh -c 'echo "LANG=en_US.UTF-8" > /etc/locale.conf'
