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
      - [Creating Partitions](#creating-partitions)
      - [Configuring LVM](#configuring-lvm)
      - [Creating filesystems](#creating-filesystems)
    - [Installing Base](#installing-base)
    - [Installing Packages](#installing-packages)
    - [Updating Hooks](#updating-hooks)
    - [Localization](#localization)
    - [User Accounts](#user-accounts)
    - [Sudo](#sudo)
    - [Bootloader](#bootloader)
  - [Tips](#tips)
    - [Arch User Repositories](#arch-user-repositories)



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

# Synchronize package databases
pacman -Sy
```


### Disk settings  - EFI and LVM

Start by list existing block devices:

```bash
# Using lsblk filter by type
lsblk -I 8 -d

# Using fdisk
fdisk -l
```


#### Creating Partitions

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

# Mount /boot and /home /boot
mkdir /mnt/home
mount /dev/volgroup0/lv_home /mnt/home
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
pacstrap -i /mnt base linux linux-headers linux-firmware
```

Enter the target environment:

```bash
arch-chroot /mnt
```


### Installing Packages

Recommended packages for guest VM in Hyper-V:

```bash
pacman -S hyperv
systemctl enable hv_fcopy_daemon.service
systemctl enable hv_kvp_daemon.service
systemctl enable hv_vss_daemon.service
```

Recommended utilities:

```bash
pacman -S vi git base-devel openssh networkmanager dialog lvm2
systemctl enable sshd
systemctl enable NetworkManager
```

Recommended packags for wireless networking:

```bash
pacman -S wpa_supplicant wireless_tools netctl
```


### Updating Hooks

Add LVM support to HOOKS:

```bash
cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.bak
sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect modconf block lvm2 filesystems keyboard fsck)/' /etc/mkinitcpio.conf
```

Apply the changes:

```bash
mkinitcpio -p linux
```


### Localization

```bash
cp /etc/locale.gen /etc/locale.gen.bak
sed -i 's/^#en_US.UTF-8.*/en_US.UTF-8 UTF-8/' /etc/locale.gen
```

Apply the chages:

```bash
locale-gen
```

### User Accounts

Set password for root user:

```bash
# Set root password
echo "root:changeme"|chpasswd
```


Create normal user:

```bash
useradd -m -g users maros

# Set Initial password
echo "maros:changeme"|chpasswd

# Force user to change after initial login
chage -d 0 maros
```

### Sudo

Allow user to use sudo with password:

```bash
echo "maros ALL=(ALL) ALL" | sudo tee /etc/sudoers.d/maros
```


### Bootloader

Install packages:

```bash
pacman -S grub efibootmgr dosfstools os-prober mtools
```

Install grub MBR:

```bash
mkdir /boot/EFI
mount /dev/sda1 /boot/EFI

grub-install --target=x86_64-efi --bootloader-id=grub_eufi --recheck
```

Verify if `locale` folder exists in `/boot/grub`:

```bash
ls /boot/grub/locale
```

```bash
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
```

Generate grub configuration file:

```bash
grub-mkconfig -o /boot/grub/grub.cfg
```


Exit chroot, unmount and reboot, you will continue in target environment:

```
exit
umount -a
reboot
```


## Tips

### Arch User Repositories

In order to install packages located in Arch User Repositories (AUR) you need to make sure you have `git` and `base-devel` installed first. Then clone the desired repository, build and install the application.

```bash
git clone https://aur.archlinux.org/brave-bin.git && cd brave-bin
makepkg -si
```

The `yay` helper can be used to simplify installation of these packages.

```bash
# Clone the repository
git clone https://aur.archlinux.org/yay.git && cd yay

# Build and Install the package
makepkg -si
```

Afterwards, use `yay` to install packages.

```bash
# Search for a package
yay -Ss brave-bin
aur/brave-bin 1:1.43.89-1 (+628 16.98) (Installed)
    Web browser that blocks ads and trackers by default (binary release)

# Display information about a package
yay -Si brave-bin

# Install a package
yay -S brave-bin

# Update packages (pacman & aur)
yay -Syu
```