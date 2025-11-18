# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-11-18

### Added

#### Main Features
- Main installer script with interactive menu system (`live-boot-installer.sh`)
- Complete color-coded UI with status messages
- Multi-option boot and installation system

#### Boot Methods
- USB Key boot support with automatic bootable media creation
- SD Card boot support
- Network boot (PXE) server setup and configuration
- Support for UEFI and Legacy BIOS modes

#### Installation Methods
- Install OS from local storage devices (USB/SD/HDD)
- Install OS from network shares (NFS/SMB)
- Direct download with built-in browser support
- HTTP/FTP download capability
- PXE network installation

#### Utility Scripts
- `create-bootable-usb.sh` - Creates bootable USB/SD media
- `install-from-storage.sh` - Installs OS from storage devices
- `install-from-network.sh` - Handles network-based installations
- `download-os.sh` - Downloads OS images with browser integration
- `setup-pxe-server.sh` - Configures PXE server for network boot
- `disk-management.sh` - Comprehensive disk and partition management

#### Disk Management Features
- List all disks and partitions
- Show detailed disk information
- Create and modify partitions
- Format partitions (ext4, FAT32, NTFS, exFAT)
- Mount/unmount operations
- SMART health monitoring
- Secure disk wiping

#### Documentation
- Complete README with comprehensive instructions
- HP-specific laptop guide with BIOS instructions
- Quick start guide for rapid deployment
- Detailed troubleshooting section
- FAQ with common questions and solutions
- PXE menu configuration templates
- GRUB boot configuration templates

#### Configuration
- Default configuration file with customizable settings
- PXE server menu template
- GRUB bootloader template
- Network boot configuration examples

#### Safety Features
- Root access verification
- Confirmation prompts for destructive operations
- Device validation before operations
- Unmounting of busy devices
- Error handling and logging

#### Browser Support
- Firefox integration
- Chromium/Chrome support
- Text-based browsers (links, w3m, lynx)
- Command-line downloaders (wget, curl)

#### OS Distribution Support
- Ubuntu and derivatives
- Linux Mint
- Fedora
- Debian
- Pop!_OS
- Generic ISO support

#### HP Laptop Features
- HP-specific BIOS key reference
- Boot menu access instructions
- Secure Boot configuration guidance
- Model-specific notes and tips
- Common HP issue troubleshooting

#### Developer Features
- Modular script architecture
- Reusable functions
- Consistent error handling
- Logging system
- Configuration file support

### Documentation

#### Guides Created
- Main README with feature overview
- Complete documentation (docs/README.md)
- HP Laptop Guide (docs/HP-LAPTOP-GUIDE.md)
- Quick Start Guide (QUICKSTART.md)
- Changelog (this file)
- License (MIT)
- Contributing guidelines

#### Configuration Files
- installer-config.conf - Main configuration
- pxe-menu-template.cfg - PXE boot menu template
- grub-template.cfg - GRUB configuration template
- .gitignore - Git ignore patterns

### Technical Details

#### Requirements
- Root/sudo access required
- Bash shell environment
- Basic Linux utilities (parted, mkfs, mount, etc.)
- Optional: SMART tools, network tools

#### Supported Systems
- HP EliteBook, ProBook, Pavilion, Envy, Stream, ZBook series
- Other x86_64 compatible systems
- UEFI and Legacy BIOS

#### Supported Installation Sources
- Local ISO files
- Network shares (NFS, SMB/CIFS)
- HTTP/FTP downloads
- PXE network boot

#### Supported Target Devices
- Internal HDDs/SSDs
- External USB drives
- SD cards
- NVMe drives
- Any block device

### Project Structure

```
LIVE-BOOT/
├── live-boot-installer.sh     # Main installer
├── scripts/                    # Feature scripts
├── docs/                       # Documentation
├── config/                     # Configuration templates
├── README.md                   # Main documentation
├── QUICKSTART.md              # Quick reference
├── CHANGELOG.md               # This file
├── LICENSE                    # MIT License
└── .gitignore                 # Git ignore rules
```

### Notes

This is the initial release providing a complete solution for HP laptops
without internet recovery. The tool enables users to:

- Create bootable recovery media
- Install operating systems from multiple sources
- Deploy OS over network
- Manage disks and partitions
- Download OS images directly

Perfect for system administrators, IT professionals, and anyone needing
a reliable OS installation solution.

### Known Limitations

- Requires root/sudo access
- Some HP models may have limited PXE support
- Secure Boot may need to be disabled for some distributions
- Network boot requires server setup
- Text-based browsers have limited functionality

### Future Considerations

Potential enhancements for future releases:
- GUI interface option
- Automated ISO integrity verification
- Multi-disk RAID setup support
- Encrypted partition support
- Automated driver installation
- Remote deployment capabilities
- Cloud storage integration
- Docker container support

---

[1.0.0]: https://github.com/acesonder/LIVE-BOOT/releases/tag/v1.0.0
