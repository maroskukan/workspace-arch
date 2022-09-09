# Arch Development Machine Workspace

This repository contains notes for a fresh Arch Linux installation.

## Installation

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


Once you are dropped in the live CD shell, retrieve the IP address with `ip add show` and set installator `root` password with `passwd` so you can access the installation remotely via SSH.

Retrieve the current IP address from host using powershell:

```powershell
# Retrieve the Guest IP Address
$GuestIP = (Get-VM -VMName $VMName | Get-VMNetworkAdapter).IpAddresses[0]
```

Retrieve the current IP address from guest using bash:

```bash
ip a s eth0 | egrep -o 'inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d' ' -f2
```

List exising disks:

```bash
fdisk -l
```