# Live Boot OS Installer - Complete Documentation

## Overview

The Live Boot OS Installer is a comprehensive solution for HP laptops that lack built-in internet recovery. It provides multiple methods to create bootable media, download operating systems, and install them on your hardware.

## Table of Contents

1. [Features](#features)
2. [Requirements](#requirements)
3. [Quick Start Guide](#quick-start-guide)
4. [Boot Methods](#boot-methods)
5. [Installation Methods](#installation-methods)
6. [Detailed Instructions](#detailed-instructions)
7. [Troubleshooting](#troubleshooting)
8. [FAQ](#faq)

## Features

### Boot Options
- **USB Key Boot**: Create bootable USB drives (8GB+ recommended)
- **SD Card Boot**: Create bootable SD cards
- **Network Boot (PXE)**: Boot from another PC/Mac over the network

### Installation Sources
- **Storage Device**: Install from ISO files on USB/SD/HDD
- **Network Share**: Install from NFS/SMB network shares
- **Direct Download**: Built-in browser for downloading OS images
- **PXE Server**: Network-based installation from another computer

### Additional Features
- Disk and partition management
- Filesystem formatting (ext4, FAT32, NTFS, exFAT)
- SMART health monitoring
- System information viewer
- Interactive menu system

## Requirements

### For Bootable USB/SD Creation
- Root/sudo access
- USB drive or SD card (8GB minimum, 16GB recommended)
- ISO file of your chosen operating system
- Basic Linux tools (included in most distributions)

### For Network Boot (PXE)
- Another computer (PC/Mac) on the same network
- Root/administrator access on the server computer
- Network connection between server and HP laptop
- DHCP and TFTP server software (installed automatically)

### For OS Download
- Internet connection
- Web browser (Firefox, Chrome, or text-based alternatives)
- Sufficient storage space for ISO file (4-8GB typically)

## Quick Start Guide

### Method 1: Create Bootable USB (Easiest)

1. **Download this repository**:
   ```bash
   git clone https://github.com/acesonder/LIVE-BOOT.git
   cd LIVE-BOOT
   ```

2. **Run the installer**:
   ```bash
   sudo bash live-boot-installer.sh
   ```

3. **Select Option 4** to download an OS using the built-in browser

4. **Select Option 1** to create a bootable USB drive

5. **Boot your HP laptop from USB**:
   - Insert the USB drive
   - Power on and press **F9** (or **ESC**) for boot menu
   - Select your USB drive

6. **Install the OS** using options 2 or 3

### Method 2: Network Boot (Advanced)

1. **On a server computer** (another PC/Mac):
   ```bash
   git clone https://github.com/acesonder/LIVE-BOOT.git
   cd LIVE-BOOT
   sudo bash live-boot-installer.sh
   ```

2. **Select Option 5** to setup PXE server

3. **Follow the setup wizard** to configure network boot

4. **On your HP laptop**:
   - Enter BIOS (F10 key during startup)
   - Enable Network Boot (PXE)
   - Save and exit
   - Boot from network

## Boot Methods

### USB Key Boot

**Advantages**:
- Most reliable method
- Works on all systems
- Portable and reusable

**Steps**:
1. Insert USB drive (8GB+)
2. Run: `sudo bash live-boot-installer.sh`
3. Choose option 1: "Create Bootable USB/SD Card"
4. Select your USB device (e.g., /dev/sdb)
5. Choose ISO file source
6. Confirm and wait for creation
7. Boot HP laptop from USB (F9 for boot menu)

**Supported on**:
- All HP laptops with USB ports
- UEFI and Legacy BIOS systems

### SD Card Boot

**Advantages**:
- Low-profile, stays in slot
- Same reliability as USB

**Steps**:
Same as USB boot, but use SD card reader
- Device typically shows as /dev/mmcblk0

### Network Boot (PXE)

**Advantages**:
- No physical media needed
- Can boot multiple machines
- Centralized OS management

**Steps**:
1. Setup PXE server on another computer
2. Enable PXE in HP laptop BIOS
3. Connect to same network
4. Boot from network

**Requirements**:
- Server computer on same network
- PXE-capable network card
- DHCP server access

## Installation Methods

### From Storage Device

Install OS from ISO file on any storage device:

1. **Insert device** with ISO file (USB/SD/HDD)
2. Run installer, choose option 2
3. **Auto-detect** or manually select ISO
4. **Select target device** for installation
5. Confirm and install

**Supported Sources**:
- USB drives
- SD cards
- External HDDs
- Mounted partitions

### From Network

Download and install from network location:

1. Ensure network connectivity
2. Choose option 3: "Install OS from Network"
3. Select method:
   - HTTP/FTP download
   - NFS share
   - SMB/CIFS share
   - PXE boot image
4. Provide connection details
5. Select target device
6. Install

### Direct Download

Use built-in browser to download OS:

1. Choose option 4: "Download OS"
2. Select browser method:
   - Graphical browser (Firefox/Chrome)
   - Text browser (links/w3m)
   - Command-line (wget/curl)
3. Navigate to download site
4. Download ISO file
5. Proceed with installation

**Recommended Download Sites**:
- Ubuntu: https://ubuntu.com/download
- Linux Mint: https://linuxmint.com/download.php
- Fedora: https://getfedora.org/
- Debian: https://www.debian.org/distrib/
- Pop!_OS: https://pop.system76.com/

## Detailed Instructions

### Creating Bootable Media

#### Preparing the USB/SD Card

1. **Backup data**: All data on the device will be erased
2. **Check device name**:
   ```bash
   lsblk
   ```
   Look for your USB/SD (e.g., /dev/sdb or /dev/mmcblk0)

3. **Unmount if mounted**:
   ```bash
   sudo umount /dev/sdb*
   ```

4. **Run the script**:
   ```bash
   sudo bash scripts/create-bootable-usb.sh /dev/sdb
   ```

#### Obtaining ISO Files

**Option 1: Download from Official Sites**
- Ubuntu: ~3.5 GB
- Linux Mint: ~2.5 GB
- Fedora: ~2 GB
- Debian: ~4 GB (full) or ~400 MB (netinst)

**Option 2: Use the Built-in Downloader**
```bash
sudo bash scripts/download-os.sh
```

**Option 3: Copy from Another Computer**
```bash
scp user@server:/path/to/ubuntu.iso ~/Downloads/
```

### HP Laptop Boot Configuration

#### Accessing Boot Menu
- **During startup**, press:
  - **F9**: One-time boot menu
  - **ESC**: Startup menu (then F9 for boot)
  - **F10**: BIOS setup

#### BIOS Settings for USB Boot
1. Press **F10** during startup
2. Go to **System Configuration** → **Boot Options**
3. Enable **USB Boot**
4. Set **Boot Order**: USB first
5. Disable **Secure Boot** (if issues occur)
6. Save and Exit (**F10**)

#### BIOS Settings for Network Boot
1. Press **F10** during startup
2. Go to **Advanced** → **Boot Options**
3. Enable **Network (PXE) Boot**
4. Enable **Legacy Support** (if required)
5. Set **Boot Order**: Network first
6. Save and Exit

### Setting Up PXE Server

#### On Ubuntu/Debian Server:

```bash
# Run setup script
sudo bash scripts/setup-pxe-server.sh

# Add OS images (example for Ubuntu)
sudo mkdir -p /srv/tftp/ubuntu /srv/nfs/ubuntu
sudo mount -o loop ubuntu-22.04.iso /mnt
sudo cp /mnt/casper/vmlinuz /srv/tftp/ubuntu/
sudo cp /mnt/casper/initrd /srv/tftp/ubuntu/
sudo unsquashfs -f -d /srv/nfs/ubuntu /mnt/casper/filesystem.squashfs
sudo umount /mnt
```

#### On macOS Server:

```bash
# Install Homebrew if not present
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Run setup script
sudo bash scripts/setup-pxe-server.sh
```

#### On Windows Server:

Use third-party tools:
- **Serva**: http://www.vercot.com/~serva/
- **TFTPD64**: https://pjo2.github.io/tftpd64/

### Installing Operating System

#### Pre-Installation Checklist

- [ ] Backup important data
- [ ] Verify ISO integrity (check SHA256)
- [ ] Ensure sufficient disk space (20GB minimum)
- [ ] Have installation media ready
- [ ] Know target device path
- [ ] Disable Secure Boot if necessary

#### Installation Process

1. **Boot from installation media**
2. **Run installer**:
   ```bash
   sudo bash live-boot-installer.sh
   ```
3. **Choose installation method** (option 2 or 3)
4. **Select ISO source**
5. **Select target device**
6. **Confirm installation** (type 'yes')
7. **Wait for completion** (10-30 minutes)
8. **Reboot** when prompted

#### Post-Installation

1. **Remove installation media**
2. **Boot into new OS**
3. **Complete setup wizard**
4. **Update system**:
   ```bash
   sudo apt update && sudo apt upgrade  # Debian/Ubuntu
   sudo dnf update                       # Fedora
   ```
5. **Install additional drivers** if needed

## Troubleshooting

### USB Boot Issues

**Problem**: USB doesn't appear in boot menu
- **Solution**: 
  - Enable USB Boot in BIOS
  - Try different USB port
  - Recreate bootable USB
  - Check if USB is properly formatted

**Problem**: "No bootable device" error
- **Solution**:
  - Verify bootloader installation
  - Check partition flags (boot flag set)
  - Try Legacy/UEFI boot mode switch
  - Recreate bootable media

**Problem**: Black screen after selecting USB
- **Solution**:
  - Wait 2-3 minutes (may be loading)
  - Try "nomodeset" boot parameter
  - Use different ISO/distribution
  - Check USB drive integrity

### Network Boot Issues

**Problem**: No PXE option in boot menu
- **Solution**:
  - Enable PXE in BIOS
  - Update BIOS firmware
  - Check network card compatibility
  - Use USB/SD boot instead

**Problem**: "PXE-E53: No boot filename received"
- **Solution**:
  - Check DHCP server configuration
  - Verify dnsmasq is running
  - Check network cable connection
  - Review server firewall settings

**Problem**: Slow network boot
- **Solution**:
  - Use wired connection (not WiFi)
  - Check network switch/router
  - Ensure 100Mbps+ connection
  - Consider USB boot instead

### Installation Issues

**Problem**: "No space left on device"
- **Solution**:
  - Free up space on target device
  - Choose smaller distribution
  - Manual partition management
  - Use external storage

**Problem**: Installation fails midway
- **Solution**:
  - Check disk health (SMART)
  - Verify ISO file integrity
  - Try different installation method
  - Check system logs

**Problem**: Can't find ISO file
- **Solution**:
  - Mount device manually
  - Check file permissions
  - Verify correct path
  - Use absolute paths

### General Issues

**Problem**: Permission denied errors
- **Solution**: Run with sudo:
  ```bash
  sudo bash live-boot-installer.sh
  ```

**Problem**: Missing dependencies
- **Solution**: Install required packages:
  ```bash
  # Debian/Ubuntu
  sudo apt install parted dosfstools squashfs-tools
  
  # Fedora
  sudo dnf install parted dosfstools squashfs-tools
  ```

**Problem**: Script not found
- **Solution**: Ensure you're in the correct directory:
  ```bash
  cd /path/to/LIVE-BOOT
  ls -l live-boot-installer.sh
  ```

## FAQ

### General Questions

**Q: Which Linux distribution should I choose?**
A: For beginners, we recommend:
- **Ubuntu 22.04 LTS**: Most user-friendly, extensive support
- **Linux Mint**: Similar to Windows interface
- **Pop!_OS**: Great for productivity and gaming
- **Fedora**: Latest software, modern interface

**Q: How much space do I need?**
A: Minimum requirements:
- USB/SD for bootable media: 8GB
- Target installation disk: 25GB minimum, 50GB recommended
- ISO download: 2-8GB depending on distribution

**Q: Will this work on my HP laptop?**
A: This solution works on most HP laptops that support:
- USB boot (nearly all models)
- Network boot / PXE (most business models)
- Standard x86_64 architecture

**Q: Can I keep Windows alongside Linux?**
A: Yes, dual-boot is possible, but:
- Requires manual partitioning (option 3)
- Backup Windows first
- Use the disk management tool carefully
- Consider separate drives if possible

### Technical Questions

**Q: What's the difference between UEFI and Legacy boot?**
A: 
- **UEFI**: Modern boot system, faster, supports GPT partitions, Secure Boot
- **Legacy/BIOS**: Older boot system, wider compatibility, uses MBR

Most new systems use UEFI. If boot fails, try switching modes.

**Q: Why is Secure Boot a problem?**
A: Secure Boot only allows signed bootloaders. Some Linux distributions aren't signed. Disable it if you have boot issues.

**Q: Can I use this from Windows?**
A: The scripts require Linux/Unix environment. Options:
- Boot from a Linux live USB first
- Use WSL (Windows Subsystem for Linux)
- Use a Virtual Machine with Linux

**Q: How do I verify ISO integrity?**
A:
```bash
# Compare SHA256 checksum
sha256sum downloaded.iso
# Compare with official checksum from download site
```

**Q: What if my network card doesn't support PXE?**
A: Use USB or SD boot instead. PXE is optional and mainly for advanced users.

### Troubleshooting Questions

**Q: What if installation fails?**
A:
1. Check disk health: `sudo smartctl -H /dev/sdX`
2. Try a different ISO/distribution
3. Verify ISO integrity (checksum)
4. Check available disk space
5. Review logs in /var/log/

**Q: How do I recover from a bad installation?**
A:
- Boot from USB again
- Use disk management tool (option 6)
- Reformat partitions
- Retry installation

**Q: The system boots but won't load the OS**
A:
- Bootloader may not be installed correctly
- Boot from USB and reinstall bootloader:
  ```bash
  sudo grub-install /dev/sda
  sudo update-grub
  ```

## Advanced Usage

### Custom ISO Integration

Add your own custom ISO to the PXE menu:

```bash
# Create directories
sudo mkdir -p /srv/tftp/custom /srv/nfs/custom

# Extract kernel and initrd
sudo mount -o loop custom.iso /mnt
sudo cp /mnt/isolinux/vmlinuz /srv/tftp/custom/
sudo cp /mnt/isolinux/initrd.img /srv/tftp/custom/

# Extract filesystem
sudo unsquashfs -f -d /srv/nfs/custom /mnt/path/to/filesystem.squashfs

# Add to PXE menu
sudo nano /srv/tftp/pxelinux.cfg/default
```

### Automated Installation

Create a preseed file for unattended installation:

```bash
# For Debian/Ubuntu
wget https://www.debian.org/releases/stable/example-preseed.txt
# Customize and use during installation
```

### Multiple OS Support

Configure PXE menu for multiple distributions:

```bash
# Edit /srv/tftp/pxelinux.cfg/default
# Add entries for each OS
# Point to respective kernel/initrd locations
```

## Support and Contributing

### Getting Help

- Check this documentation first
- Review troubleshooting section
- Search GitHub issues: https://github.com/acesonder/LIVE-BOOT/issues
- Open new issue with details

### Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create feature branch
3. Test thoroughly
4. Submit pull request

### License

This project is provided as-is for educational and recovery purposes.

## Appendix

### Useful Commands

```bash
# List all disks
lsblk

# Check disk space
df -h

# System information
uname -a
lscpu
free -h

# Network configuration
ip addr
nmcli device status

# Check running services
systemctl status dnsmasq
systemctl status nfs-server

# View logs
journalctl -xe
dmesg | tail
```

### Boot Key Reference

Common HP laptop boot keys:
- **F9**: Boot device menu
- **F10**: BIOS setup
- **F11**: System recovery
- **ESC**: Startup menu
- **F2**: System diagnostics

### Partition Scheme Examples

**Single OS Installation**:
```
/dev/sda1: 512MB  FAT32  EFI System Partition
/dev/sda2: Remaining  ext4  Root filesystem
```

**Dual Boot Configuration**:
```
/dev/sda1: 512MB  FAT32  EFI System Partition
/dev/sda2: 100GB  NTFS   Windows
/dev/sda3: 50GB   ext4   Linux Root
/dev/sda4: 8GB    swap   Linux Swap
```

### Resource Links

- [Ubuntu Download](https://ubuntu.com/download)
- [Linux Mint Download](https://linuxmint.com/download.php)
- [Fedora Download](https://getfedora.org/)
- [Debian Download](https://www.debian.org/distrib/)
- [Pop!_OS Download](https://pop.system76.com/)
- [HP Support](https://support.hp.com/)

---

*Last Updated: 2024*
*Version: 1.0.0*
