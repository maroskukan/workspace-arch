# Arch Development Machine Workspace

- [Arch Development Machine Workspace](#arch-development-machine-workspace)
  - [Introduction](#introduction)
  - [Host Hypervisor settings](#host-hypervisor-settings)
    - [Hyper-V](#hyper-v)
  - [Bootable USB](#bootable-usb)
  - [Installation](#installation)
    - [Network settings](#network-settings)
      - [Wireless](#wireless)
    - [Basic settings](#basic-settings)
    - [Disk settings  - EFI and LVM](#disk-settings----efi-and-lvm)
      - [Creating Partitions - fdisk](#creating-partitions---fdisk)
      - [Creating Partitions - parted](#creating-partitions---parted)
      - [Configuring LVM](#configuring-lvm)
      - [Creating filesystems](#creating-filesystems)
    - [Installing Base](#installing-base)
    - [Installing Packages](#installing-packages)
    - [Updating Hooks](#updating-hooks)
    - [Localization](#localization)
    - [User Accounts](#user-accounts)
    - [Sudo](#sudo)
    - [Bootloader](#bootloader)
  - [Customization](#customization)
    - [SWAP](#swap)
    - [Localization](#localization-1)
    - [Microcode](#microcode)
  - [Graphical User Interface](#graphical-user-interface)
    - [XORG](#xorg)
    - [GPU Driver](#gpu-driver)
  - [Desktop Environment](#desktop-environment)
    - [Gnome](#gnome)
    - [Plasma](#plasma)
    - [Xfce](#xfce)
    - [Mate](#mate)
  - [Window Manager](#window-manager)
    - [Awesome WM with lightdm](#awesome-wm-with-lightdm)
      - [Configuration](#configuration)
    - [Awesome WM without login manager](#awesome-wm-without-login-manager)
  - [Tips](#tips)
    - [Arch User Repositories](#arch-user-repositories)
    - [Applications to consider](#applications-to-consider)
    - [Screen Selection](#screen-selection)



## Introduction 

This repository contains notes for a fresh Arch Linux installation.



## Host Hypervisor settings

Download the latest ISO from [Arch website](https://archlinux.org/download/).

### Hyper-V

In order to boot the Arch ISO you need to disable Secure Boot in VM settings. Create a generic Generation v2 VM with 2vCPU, 2048 Mb RAM, and 20GB HDD abd connect to `Default Switch`. 

> **Warning**: You are not using evalated privileges ensure that your user account is member of Hyper-V Administrators group.



```powershell
# Set VM Name, Switch Name, and Installation Media Path.
$VMName = 'arch_efi'
$Switch = 'Default Switch'
$InstallMedia = 'C:\iso\archlinux-x86_64.iso'

# Create New Virtual Machine
New-VM -Name $VMName `
       -Generation 2 `
       -MemoryStartupBytes 2GB `
       -NewVHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\$VMName\$VMName.vhdx" `
       -NewVHDSizeBytes 20GB `
       -Path "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\$VMName" `
       -Switch $Switch

# Set processor count and dynamic memory
Set-VM -VMName $VMName -ProcessorCount 2

# Disable Secure Boot
Set-VMFirmware -VMName $VMName -EnableSecureBoot Off

# Add DVD Drive to Virtual Machine
Add-VMScsiController -VMName $VMName
Add-VMDvdDrive -VMName $VMName -ControllerNumber 1 -ControllerLocation 0 -Path $InstallMedia

# Mount Installation Media
$DVDDrive = Get-VMDvdDrive -VMName $VMName

# Configure Virtual Machine to Boot from DVD
Set-VMFirmware -VMName $VMName -FirstBootDevice $DVDDrive

# Start Virtual Machine
Start-VM -Name $VMName
```

Once the VM boots into installation environment retrieve the current IP address from host using powershell:

```powershell
# Retrieve the Guest IP Address
$GuestIP = (Get-VM -VMName $VMName | Get-VMNetworkAdapter).IpAddresses[0]
```



## Bootable USB 

```bash
# Create new bootable USB stick
sudo dd bs=4M if=Downloads/arch/archlinux-2022.09.03-x86_64.iso of=/dev/sda
```

> **Warning**: Make sure the device name is correct, you can inspect this by using lsblk.



## Installation

Once you are dropped in the live CD shell, set installator `root` password with `passwd` or `chpasswd` this gives you remote access the installation via SSH as oppose to using Virtual Console.

```bash
echo "root:archrocks"|chpasswd
```

### Network settings

#### Wireless

```bash
# Retrieve the adapter name
ip a show

# Connect to wireless network
iwctl --passphrase=<YOUR_PSK> station wlan0 connect <YOUR_SSID>

# Verify
ping -c 3 1.1.1.1
```


### Basic settings

Ensure that time and package DBs are synchronized:

```bash
# Enable NTP
timedatectl set-ntp true

# Enable parallel downloads
sed -i 's/^#ParallelDownloads =.*/ParallelDownloads = 5/' /etc/pacman.conf

# Synchronize package databases
pacman -Sy
```


### Disk settings  - EFI and LVM

Verify if target device supports EUFI:

```bash
ls /sys/firmware/efi/efivars && echo 'EUFI Install' || echo 'BIOS Install'
```

List existing block devices:

```bash
# Using lsblk filter by type
lsblk -I 8 -d

# Using fdisk
fdisk -l
```


#### Creating Partitions - fdisk

Next, partition the disk as follows:

| Mount Point | Partition   | Partition type | Size                    |
| ----------- | ----------- | -------------- | ----------------------- |
| `/mnt/boot` | `/dev/sda1` | EFI System     | 500M                    |
| `/mnt`      | `/dev/sda2` | LVM            | Remainder of the device |


> **Note**: You may need to delete existing paritions with `d` command if installing on disk where previous installation existed.


```bash
# Select Device
fdisk /dev/sda

# Create new empty GPT partition table
Command (m for help): g

# Create new primary partition
Command (m for help): n
Partition number (1-128, default 1): <Hit Enter>
First sector (2048-41943006, default 2048): <Hit Enter>
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-41943006, default 41940991): +500M

# Update partition type
Command (m for help): t
Selected partition 1
Partition type or alias (type L to list all): 1
Changed type of partition 'Linux filesystem' to 'EFI System'.

# Create new primary partition
Command (m for help): n
Partition number (2-128, default 2):
First sector (1026048-41943006, default 1026048):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (1026048-41943006, default 41940991):

Created a new partition 2 of type 'Linux filesystem' and of size 19.5 GiB.

# Update partition type
Command (m for help): t
Partition number (1,2, default 2):
Partition type or alias (type L to list all): 43
Changed type of partition 'Linux root (MIPS-32 LE)' to 'Linux LVM'.

# Finally verify the partition layout
Command (m for help): p
Disk /dev/sda: 20 GiB, 21474836480 bytes, 41943040 sectors
Disk model: Virtual Disk
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disklabel type: gpt
Disk identifier: 17611239-DCD5-3A4A-A3C8-57112E24599E

Device       Start      End  Sectors  Size Type
/dev/sda1     2048  1026047  1024000  500M EFI System
/dev/sda2  1026048 41940991 40914944 19.5G Linux LVM

# When ready write changes
Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```


#### Creating Partitions - parted

Next, partition the disk as follows:

| Mount Point | Partition   | Partition type | Size                    |
| ----------- | ----------- | -------------- | ----------------------- |
| `/mnt/boot` | `/dev/sda1` | EFI System     | 500M                    |
| `/mnt`      | `/dev/sda2` | LVM            | Remainder of the device |


```bash
# Create new empty GPT partition table
parted -s /dev/sda mklabel gpt

# Create new primary partition
parted -a optimal /dev/sda --script mkpart primary fat32 1MiB 501MiB
parted -a optimal /dev/sda --script mkpart primary ext4 501MiB 100%

# Update partition type
parted -a optimal /dev/sda --script set 1 esp on
parted -a optimal /dev/sda --script set 2 lvm on
```

> **Warning**: If you made a mistake and want to wipe the entire disk you can use `dd if=/dev/zero of=/dev/sda bs=1M`. Make sure the device name is correct.


#### Configuring LVM

Create new physical volume:

```bash
pvcreate --dataalignment 1m /dev/sda2
```

Create a new volume group:

```bash
vgcreate volgroup0 /dev/sda2
```

Create logical volume for root:

```bash
lvcreate -L 16G volgroup0 -n lv_root
```

Create logical volume for home:

```bash
lvcreate -l 100%FREE volgroup0 -n lv_home
```

Activate LVM configuration.

```bash
# Load kernel module
modprobe dm_mod

# Scan for volume groups
vgscan

# Activate
vgchange -ay
```


#### Creating filesystems

```bash
# Create Fat32 for EFI parition
mkfs.fat -F32 /dev/sda1

# Create Ext4 for root
mkfs.ext4 /dev/volgroup0/lv_root

# Create Ext4 for home
mkfs.ext4 /dev/volgroup0/lv_home
```

Mount the filesystems:

```bash
# Mount root fs
mount /dev/volgroup0/lv_root /mnt

# Mount /home 
mount --mkdir /dev/volgroup0/lv_home /mnt/home
```

Next, create partition table:

```bash
mkdir /mnt/etc
genfstab -U -p /mnt >> /mnt/etc/fstab

# Verify the filesystem table
cat /mnt/etc/fstab
# /dev/mapper/volgroup0-lv_root
UUID=4897c60f-b163-4db9-a1df-80e751418ab6       /               ext4            rw,relatime     0 1

# /dev/mapper/volgroup0-lv_home
UUID=4ea19e22-f8e1-40c7-a7ca-e3e34580c9e6       /home           ext4            rw,relatime     0 2
```


### Installing Base

Install kernel and `base` package group:

> **Note**: In some weird situations you may noticed the download speeds are slow. In that case it is work inspecting the mirror list /etc/pacman.d/mirrorlist. And perhaps regenerate it using `reflector` utility.

```bash
reflector > /etc/pacman.d/mirrorlist
```

```bash
pacstrap /mnt base linux linux-headers linux-firmware
```

> **Note**: You have number of choices available when it comes to kernels, you can install latest as show above or the lts version `linux-lts`, `linux-lts-headers` or both.

> **Note**: When installing in guest virtual machine, you don't need to include `linux-firmware`



### Installing Packages

Recommended packages for guest VM in Hyper-V:

```bash
arch-chroot /mnt sed -i 's/^#ParallelDownloads =.*/ParallelDownloads = 5/' /etc/pacman.conf
arch-chroot /mnt pacman -S --noconfirm hyperv
arch-chroot /mnt systemctl enable {hv_fcopy_daemon,hv_kvp_daemon,hv_vss_daemon}
```

Recommended packages for guest VM in VirtualBox:

```bash
arch-chroot /mnt pacman -S --noconfirm virtualbox-guest-utils
```

Recommended utilities:

```bash
arch-chroot /mnt pacman -S --noconfirm vim git base-devel openssh networkmanager dialog lvm2
arch-chroot /mnt systemctl enable {sshd,NetworkManager}
```

> **Warning**: In some weird situations the initramfs rebuilding fails after installing lvm2 package. If using `--noconfirm` the process get killed but pacman locks the database. You can unlock it with `rm -rf /mnt/var/lib/pacman/db.lck` and then reinstalling the `lvm2` package.

Recommended packags for wireless networking:

```bash
arch-chroot /mnt pacman -S --noconfirm wpa_supplicant wireless_tools netctl
```


### Updating Hooks

Add LVM support to HOOKS:

```bash
arch-chroot /mnt cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.bak
arch-chroot /mnt sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect modconf block lvm2 filesystems keyboard fsck)/' /etc/mkinitcpio.conf
```

Apply the changes:

```bash
arch-chroot /mnt mkinitcpio -p linux
```


### Localization

```bash
arch-chroot /mnt cp /etc/locale.gen /etc/locale.gen.bak
arch-chroot /mnt  sed -i 's/^#en_US.UTF-8.*/en_US.UTF-8 UTF-8/' /etc/locale.gen
```

Apply the changes:

```bash
arch-chroot /mnt locale-gen
```

Create `locale.conf` and set `LANG` variable:

```bash
arch-chroot /mnt sh -c 'echo "LANG=en_US.UTF-8" > /etc/locale.conf'
```


### User Accounts

Set password for root user:

```bash
# Set root password
arch-chroot /mnt sh -c 'echo "root:changeme"|chpasswd'
```


Create normal user:

```bash
arch-chroot /mnt useradd -m -g users maros

# Set Initial password - this does not work
arch-chroot /mnt sh -c 'echo "maros:changeme"|chpasswd'

# Force user to change after initial login
arch-chroot /mnt chage -d 0 maros
```

### Sudo

Allow user to use sudo with password:

```bash
# This does work
arch-chroot /mnt sh -c 'echo "maros ALL=(ALL) ALL" | tee /etc/sudoers.d/maros'
```


### Bootloader

Install packages:

```bash
arch-chroot /mnt pacman -S --noconfirm grub efibootmgr dosfstools os-prober mtools
```

Install grub MBR:

```bash
arch-chroot /mnt mount --mkdir /dev/sda1 /boot/EFI

arch-chroot /mnt grub-install --target=x86_64-efi --bootloader-id=grub_eufi --recheck
```

Verify if `locale` folder exists in `/boot/grub`:

```bash
arch-chroot /mnt ls /boot/grub/locale
```
If not create the directory and generate locale:

```bash
arch-chroot /mnt mkdir /boot/grub/locale
arch-chroot /mnt cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
```

Generate grub configuration file:

```bash
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
```


Expire target `root` password, unmount and reboot, you will continue in target environment:

```bash
# Expire root password
arch-chroot /mnt chage -d 0 root

# Umount /mnt
umount -R /mnt

# Reboot
reboot
```


## Customization

These steps are performed from within the target environment as `root` user.

### SWAP

Create a SWAP file:

```bash
dd if=/dev/zero of=/swapfile bs=1M count=2048
```

Change permissions and format the file:

```bash
chmod 600 /swapfile
mkswap /swapfile
```

Update `fstab` and activate swap:

```bash
cp /etc/fstab /etc/fstab.bak
echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab

mount -a
swapon -a

# Verify
cat /proc/meminfo | grep Swap
```


### Localization

Time zone and synchronization:

```bash
timedatectl set-timezone Europe/Bratislava
timedatectl set-ntp true
systemctl enable systemd-timesyncd
```

Generate `/etc/adjtime`:

```bash
hwclock --systohc
```

Hostname and hosts file:

```bash
hostnamectl set-hostname dojo.localdomain
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 dojo dojo.localdomain" >> /etc/hosts
```


### Microcode

Intel CPU:

```bash
pacman -S intel-ucode 
```

AMD CPU:

```bash
pacman -S amd-ucode
```


## Graphical User Interface

### XORG

X-org is required in case you want to run a full desktop environment (Gnome, KDE Plasma, XFCE, Cinnamon, Mate, COSMIC) or just window manager (Awesome WM, DWM, i3, Xmonad, Fluxbox)

```bash
pacman -S --noconfirm xorg-server
```


### GPU Driver

Intel:

```bash
pacman -S --noconfirm mesa vulkan-intel intel-media-driver
```

Nvidia:

```bash
pacman -S --noconfirm nvidia nvidia-utils
```

> **Note**: You may want to install `optimus-manager` AUR package in case you want to switch between Intel and Nvidia GPU


HyperV:

```bash
pacman -S --noconfirm xf86-video-fbdev
```

VirtualBox:

```bash
pacman -S --noconfirm xf86-video-vmware
sustemctl enable vboxservice
```


## Desktop Environment

### Gnome

| Package Count | Packages Size | Memory Footprint (All) |
| ------------- | ------------- | ---------------------- |
| 546           | 457 Mib       | 880 MB                 |

Recommended packages for Gnome include:

```bash
pacman -S --noconfirm gnome gnome-tweaks
```

Enable default login manager:

```bash
systemctl enable gdm
```

Reboot to take effect:

```bash
reboot
```


### Plasma

| Package Count | Packages Size | Memory Footprint (All) |
| ------------- | ------------- | ---------------------- |
| 815           | 1380 Mib      | 1005 MB                |

Recommended packages for Plasma include:

```bash
pacman -S --noconfirm plasma-meta kde-applications
```

Enable default login manager:

```bash
systemctl enable sddm
```

Reboot to take effect:

```bash
reboot
```


### Xfce

| Package Count | Packages Size | Memory Footprint (All) |
| ------------- | ------------- | ---------------------- |
| 189           | 83 Mib        | 333 MB                 |

Recommended packages for Xfce include:

```bash
pacman -S --noconfirm xfce4 xfce4-goodies lightdm lightdm-gtk-greeter
```

> **Note**: Instead of default `lightdm-gtk-greeter` you can also use the `lightdm-webkit2-greeter` which supports large number of customized themes. Or you can go as minimal as `lightdm-mini-greeter`.


Enable default login manager:

```bash
systemctl enable lightdm
```

Reboot to take effect:

```bash
reboot
```


### Mate

| Package Count | Packages Size | Memory Footprint (All) |
| ------------- | ------------- | ---------------------- |
| 230           | 307 Mib       | 435 MB                 |

Recommended packages for Mate include:

```bash
pacman -S --noconfirm mate mate-extra lightdm lightdm-gtk-greeter
```

Enable default login manager:

```bash
systemctl enable lightdm
```

Reboot to take effect:

```bash
reboot
```


## Window Manager

Window Manager offers low footprint environment with high level of customizaion.

### Awesome WM with lightdm

| Package Count | Packages Size | Memory Footprint (All) |
| ------------- | ------------- | ---------------------- |
| 76            | 35 Mib        | 142 MB                 |

```bash
# Install base packages including default terminal emulator and Login manager
pacman -S --noconfirm awesome xterm lightdm lightdm-gtk-greeter

# Optionally install file manager and alternative terminal
pacman -S --noconfirm pcmanfm alacritty compton nitrogen archlinux-wallpaper dmenu
```

```bash
systemctl enable lightdm
```

Start the lighdm.

```bash
systemctl start lightdm
```

The login manager should now run at `tty7. If not already you can switch to it using `Ctrl + Alt + F7`.

Here are some shortcuts:

| Shortcut              | Description      |
| --------------------- | ---------------- |
| `Opt` + `Enter`       | Start terminal   |
| `Opt` + `Shift` + `c` | Close window     |
| `Opt` + `r`           | Run prompt       |
| `Opt` + `s`           | Show keybindings |
| `Ctrl` + `Opt` + `r`  | Reload awesome   |


> **Info**: It is also possible to run Window Manager directly, without the use of login manager. `Opt` is also referred to as `Super` key.


#### Configuration

Run the following commands as normal user.

```bash
mkdir -p ~/.config/awesome
sudo find / -name rc.lua
cp /etc/xdg/awesome/rc.lua ~/.config/awesome/rc.lua
```

Change default terminal:

```bash
cp ~/.config/awesome/rc.lua ~/.config/awesome/rc.lua.bak

# Update configuration
sed -i 's/^terminal =.*/terminal = "alacritty"/' ~/.config/awesome/rc.lua

echo -e '\n\n-- Autostart Applications' >> ~/.config/awesome/rc.lua
echo -e 'awful.spawn.with_shell("compton")' >> ~/.config/awesome/rc.lua
echo -e 'awful.spawn.with_shell("nitrogen --restore")' >> ~/.config/awesome/rc.lua


# Validate configuration
awesome -k
```


### Awesome WM without login manager

This assumes that you have `xorg-server` already installed. The following steps require root privileges.

```bash
pacman -S --noconfirm awesome xterm xorg-xinit
```

Start awesome without display manager:

```bash
echo “exec awesome” > ~/.xinitrc
```


## Tips

### Arch User Repositories

In order to install packages located in Arch User Repositories (AUR) you need to make sure you have `git` and `base-devel` installed first. Then clone the desired repository, build and install the application.

```bash
git clone https://aur.archlinux.org/brave-bin.git && cd brave-bin
makepkg -si
```

The `paru` helper can be used to simplify installation of these packages.

```bash
# Clone the repository and build and install the package
git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si
```

Afterwards, use `paru` to install packages.

```bash
# Search for a package
paru -Ss brave-bin
aur/brave-bin 1:1.43.89-1 (+628 16.98) (Installed)
    Web browser that blocks ads and trackers by default (binary release)

# Display information about a package
paru -Si brave-bin

# Install a package
paru -S brave-bin

# Update packages (pacman & aur)
paru -Syu

# Update packages (aur)
paru -Sua

# Check for updates (aur)
paru -Qua
```


### Applications to consider

```bash
pacman -S bat
```


### Screen Selection

When using external monitor connected via Thunderbolt, it is possible to disable the built-in screen. The following is an example of disabling screen on Macbook Air.

```bash
xrandr --output eDP-1 --off --output DP-1 --auto
```