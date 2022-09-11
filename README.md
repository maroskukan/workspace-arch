# Arch Development Machine Workspace

This repository contains notes for a fresh Arch Linux installation.

## Host Hypervisor settings

Download the latest ISO from [Arch website](https://archlinux.org/download/).

### Hyper-V

In order to boot the Arch ISO you need to disable Secure Boot in VM settings. Create a generic Generation v2 VM with 2vCPU, 2048 Mb RAM, and 20GB HDD abd connect to `Default Switch`. 

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

Once you are dropped in the live CD shell, set installator `root` password with `passwd` this gives you remote access the installation via SSH as oppose to using Virtual Console.


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

### Disk settings

List existing disks:

```bash
# Using lsblk filter by type
lsblk -I 8 -d

# Using fdisk
fdisk -l
```
