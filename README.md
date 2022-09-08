# Arch Development Machine Workspace

This repository contains notes for a fresh Arch Linux installation.

## Installation

Download the latest ISO from [Arch website](https://archlinux.org/download/).

### Hyper-V

In order to boot the Arch ISO you need to disable Secure Boot in VM settings. Create a generic Generation v2 VM with 2vCPU, 2048 Mb RAM, and 20GB HDD abd connect to `Default Switch`. Once you are dropped in the live CD shell, retrieve the IP address with `ip add show` and set installator `root` password with `passwd` so you can access the installation remotely via SSH.

Retrieve the current IP address:

```bash
ip a s eth0 | egrep -o 'inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d' ' -f2
```

List exising disks:

```bash
fdisk -l
```

