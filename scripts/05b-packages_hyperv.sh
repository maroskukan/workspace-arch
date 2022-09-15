#!/usr/bin/bash

arch-chroot /mnt sed -i 's/^#ParallelDownloads =.*/ParallelDownloads = 5/' /etc/pacman.conf
arch-chroot /mnt pacman -S --noconfirm hyperv
arch-chroot /mnt systemctl enable {hv_fcopy_daemon,hv_kvp_daemon,hv_vss_daemon}
