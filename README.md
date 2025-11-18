# LIVE-BOOT

A comprehensive Live Boot OS installer for HP laptops without internet recovery capabilities.

## 🚀 Quick Start

**New User?** 👉 See the [**STEP-BY-STEP INSTALLATION GUIDE**](INSTALLATION-GUIDE.md) for direct instructions on how to run this on your HP laptop.

```bash
# Clone the repository
git clone https://github.com/acesonder/LIVE-BOOT.git
cd LIVE-BOOT

# Make executable
chmod +x live-boot-installer.sh

# Run the installer (requires root)
sudo ./live-boot-installer.sh
```

## ✨ Features

### Multiple Boot Methods
- **USB Key Boot** - Create bootable USB drives (8GB+)
- **SD Card Boot** - Create bootable SD cards
- **Network Boot (PXE)** - Boot from another PC/Mac over network

### Flexible Installation Sources
- **Storage Device** - Install from ISO files on USB/SD/HDD
- **Network Share** - Install from NFS/SMB network shares
- **Direct Download** - Built-in browser for downloading OS images
- **PXE Server** - Network-based installation from another computer

### Additional Tools
- Disk and partition management
- Filesystem formatting (ext4, FAT32, NTFS, exFAT)
- SMART health monitoring
- System information viewer
- Interactive menu system

## 📋 Requirements

- HP Laptop (or compatible x86_64 system)
- Root/sudo access
- USB drive or SD card (8GB minimum for bootable media)
- Internet connection (for download option)

## 🎯 Use Cases

This tool is perfect for:
- HP laptops without built-in internet recovery
- Systems that need OS reinstallation
- Creating portable bootable media
- Network-based OS deployment
- Emergency system recovery

## 📖 Documentation

- **[INSTALLATION GUIDE](INSTALLATION-GUIDE.md)** - **START HERE!** Step-by-step instructions for HP laptops
- **[Complete Documentation](docs/README.md)** - Comprehensive guide with all features
- **[HP Laptop Guide](docs/HP-LAPTOP-GUIDE.md)** - HP-specific BIOS and boot instructions
- **[Quick Start](#quick-start)** - Get started immediately

## 🔧 Main Menu Options

1. **Create Bootable USB/SD Card** - Create bootable installation media
2. **Install OS from Storage Device** - Install from ISO on any storage device
3. **Install OS from Network** - Download and install from network location
4. **Download OS (Built-in Browser)** - Use browser to download OS images
5. **Setup Network Boot (PXE Server)** - Configure PXE server for network boot
6. **Disk/Partition Management** - Manage disks and partitions
7. **System Information** - View hardware and system details
8. **Help & Documentation** - Access help and guides

## 🚦 Usage Examples

### Create a Bootable USB

```bash
sudo ./live-boot-installer.sh
# Select option 1: Create Bootable USB/SD Card
# Follow the prompts to select device and ISO
```

### Download and Install OS

```bash
sudo ./live-boot-installer.sh
# Select option 4: Download OS (Built-in Browser)
# Download your preferred Linux distribution
# Then select option 2 to install
```

### Setup Network Boot Server

```bash
# On server computer (PC/Mac)
sudo ./live-boot-installer.sh
# Select option 5: Setup Network Boot (PXE Server)
# Follow setup wizard

# On HP laptop
# Enable PXE in BIOS (F10 → Boot Options → Network Boot)
# Boot from network (F9 → Network Adapter)
```

## 🎓 Recommended Linux Distributions

For HP laptops, we recommend:

- **Ubuntu 22.04 LTS** - Most user-friendly, great hardware support
- **Linux Mint 21** - Windows-like interface, easy to use
- **Pop!_OS** - Excellent for productivity and gaming
- **Fedora Workstation** - Latest software, modern GNOME desktop
- **Debian 12** - Stable and reliable

## 🔑 HP Laptop Boot Keys

| Key | Function |
|-----|----------|
| **F9** | Boot Device Options |
| **F10** | BIOS Setup |
| **F11** | System Recovery |
| **ESC** | Startup Menu |

Press during startup when HP logo appears.

## 🛠️ Scripts

All functionality is organized in the `scripts/` directory:

- `create-bootable-usb.sh` - Creates bootable USB/SD media
- `install-from-storage.sh` - Installs OS from storage device
- `install-from-network.sh` - Installs OS from network
- `download-os.sh` - Downloads OS with browser
- `setup-pxe-server.sh` - Sets up PXE server
- `disk-management.sh` - Disk and partition tools

## 📁 Project Structure

```
LIVE-BOOT/
├── live-boot-installer.sh    # Main installer script
├── scripts/                   # Feature scripts
│   ├── create-bootable-usb.sh
│   ├── install-from-storage.sh
│   ├── install-from-network.sh
│   ├── download-os.sh
│   ├── setup-pxe-server.sh
│   └── disk-management.sh
├── docs/                      # Documentation
│   ├── README.md              # Complete documentation
│   └── HP-LAPTOP-GUIDE.md     # HP-specific guide
├── config/                    # Configuration templates
│   ├── pxe-menu-template.cfg
│   └── grub-template.cfg
└── README.md                  # This file
```

## 🐛 Troubleshooting

### USB Boot Issues
- Enable USB Boot in BIOS (F10)
- Try different USB port
- Disable Secure Boot if needed
- Try Legacy boot mode

### Network Boot Issues
- Enable PXE in BIOS
- Check network cable connection
- Verify server configuration
- Check firewall settings

### Installation Issues
- Verify ISO integrity (checksum)
- Check available disk space
- Try different distribution
- Review installation logs

For more troubleshooting, see [Complete Documentation](docs/README.md).

## 🤝 Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.

## 📄 License

This project is provided as-is for educational and recovery purposes.

## 💡 Tips

- Always backup important data before installation
- Verify ISO checksums for integrity
- Use wired connection for network installations
- Keep bootable USB as recovery media
- Update BIOS to latest version for best compatibility

## 🆘 Support

- Check [Documentation](docs/README.md) first
- Review [HP Laptop Guide](docs/HP-LAPTOP-GUIDE.md) for HP-specific issues
- Search existing GitHub issues
- Open new issue with details if needed

## 🌟 Acknowledgments

This tool provides a solution for HP laptops lacking built-in internet recovery, enabling users to:
- Create bootable recovery media
- Install operating systems from multiple sources
- Recover systems without internet access
- Deploy OS over network when needed

Perfect for IT professionals, system administrators, and anyone needing a reliable OS installation solution.

---

**Version:** 1.0.0  
**Last Updated:** 2024  
**Status:** Active Development