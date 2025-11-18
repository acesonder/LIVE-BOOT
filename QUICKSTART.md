# Quick Start Guide

## For Users in a Hurry

### I want to create a bootable USB drive

```bash
sudo ./live-boot-installer.sh
# Select: 1 (Create Bootable USB/SD Card)
# Insert USB drive (8GB+)
# Follow prompts
# Boot HP laptop with F9, select USB
```

### I want to download and install Linux

```bash
sudo ./live-boot-installer.sh
# Select: 4 (Download OS)
# Choose Ubuntu or Linux Mint
# Download completes
# Select: 1 (Create Bootable USB)
# Or: 2 (Install directly)
```

### I want to use network boot (PXE)

**On another computer (server):**
```bash
sudo ./live-boot-installer.sh
# Select: 5 (Setup Network Boot)
# Follow setup wizard
# Add OS images as instructed
```

**On HP laptop:**
```bash
# Press F10 during startup → BIOS
# Enable: Network Boot (PXE)
# Save and Exit
# Press F9 → Select Network Adapter
```

## Common Commands

### Create bootable USB (manual)
```bash
sudo bash scripts/create-bootable-usb.sh /dev/sdb
```

### Download OS
```bash
sudo bash scripts/download-os.sh
```

### Install from ISO
```bash
sudo bash scripts/install-from-storage.sh
```

## HP Laptop Keys

- **F9** = Boot menu
- **F10** = BIOS setup
- **ESC** = Startup menu

## Need Help?

- Full docs: [docs/README.md](docs/README.md)
- HP guide: [docs/HP-LAPTOP-GUIDE.md](docs/HP-LAPTOP-GUIDE.md)

## Recommended Downloads

- Ubuntu: https://ubuntu.com/download
- Linux Mint: https://linuxmint.com/download.php
- Fedora: https://getfedora.org/
- Pop!_OS: https://pop.system76.com/

## Minimum Requirements

- USB/SD: 8GB
- Disk space: 25GB
- RAM: 2GB (4GB recommended)
- Internet: Optional (for downloads)

That's it! 🚀
