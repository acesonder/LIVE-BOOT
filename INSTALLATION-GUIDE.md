# Step-by-Step Installation Guide for HP Laptop

## How to Run This on Your HP Laptop

This guide provides **direct step-by-step instructions** for using the Live Boot OS Installer on your HP laptop.

---

## Method 1: Create Bootable USB (Recommended - Easiest)

### What You Need
- A USB drive (8GB or larger)
- Another computer with Linux (or boot from a live Linux USB)
- Internet connection (to download this tool and an OS)

### Step-by-Step Instructions

#### Step 1: Get the Tool on Another Computer

On any Linux computer (or boot from a live Linux USB):

```bash
# Open Terminal (Ctrl+Alt+T)

# Download the tool
git clone https://github.com/acesonder/LIVE-BOOT.git

# Go into the directory
cd LIVE-BOOT
```

#### Step 2: Download an Operating System

```bash
# Run the installer
sudo ./live-boot-installer.sh

# When menu appears, press: 4
# (This opens Download OS option)

# Select option 1 or 3 to download
# Choose Ubuntu or Linux Mint (recommended for beginners)

# Wait for download to complete (5-15 minutes)
```

#### Step 3: Create Bootable USB

```bash
# Still in the installer menu, press: 1
# (Create Bootable USB/SD Card)

# Insert your USB drive

# The script will show available devices
# Find your USB (usually /dev/sdb or /dev/sdc)
# ⚠️ MAKE SURE IT'S YOUR USB, NOT YOUR HARD DRIVE!

# Enter the device path: /dev/sdb
# (Replace sdb with your actual device)

# Select where your downloaded ISO is
# Usually in ~/Downloads/LiveBoot/

# Type: yes (to confirm erasing USB)

# Wait 5-10 minutes for creation
```

#### Step 4: Boot Your HP Laptop from USB

```bash
# 1. Safely remove USB from the computer
# 2. Insert USB into your HP laptop
# 3. Turn on HP laptop
# 4. IMMEDIATELY press F9 repeatedly
#    (Keep pressing until boot menu appears)
# 5. Select your USB drive from the menu
# 6. Press Enter
```

#### Step 5: Install OS on HP Laptop

Once booted from USB:

```bash
# Open Terminal on the live system

# Go to where the installer is (if on USB)
cd /media/*/LIVEBOOT  # or wherever USB is mounted

# Run installer
sudo ./live-boot-installer.sh

# Select option 2: Install OS from Storage Device
# Select option 1: Auto-detect ISO from mounted devices
# Choose your HP laptop's hard drive (usually /dev/sda)
# ⚠️ THIS WILL ERASE YOUR HP LAPTOP'S HARD DRIVE!
# Type: yes (to confirm)

# Wait 15-30 minutes for installation

# When done, remove USB and reboot
```

---

## Method 2: Network Boot (Advanced)

### What You Need
- Your HP laptop
- Another computer (Windows/Mac/Linux) on same network
- Network cable (recommended) or WiFi

### Step-by-Step Instructions

#### Step 1: Setup PXE Server on Another Computer

On the server computer (Windows/Mac/Linux with Linux VM):

```bash
# Download and enter directory
git clone https://github.com/acesonder/LIVE-BOOT.git
cd LIVE-BOOT

# Run installer
sudo ./live-boot-installer.sh

# Select option 5: Setup Network Boot (PXE Server)

# Follow the wizard:
# - Select network interface (e.g., eth0)
# - Enter server IP (e.g., 192.168.1.10)
# - Enter DHCP range start (e.g., 192.168.1.100)
# - Enter DHCP range end (e.g., 192.168.1.200)

# Wait for setup to complete
```

#### Step 2: Add OS Image to Server

```bash
# Download an OS ISO first
wget https://releases.ubuntu.com/22.04/ubuntu-22.04.3-desktop-amd64.iso

# Mount it
sudo mkdir /mnt/iso
sudo mount -o loop ubuntu-22.04.3-desktop-amd64.iso /mnt/iso

# Copy files to PXE server
sudo mkdir -p /srv/tftp/ubuntu /srv/nfs/ubuntu
sudo cp /mnt/iso/casper/vmlinuz /srv/tftp/ubuntu/
sudo cp /mnt/iso/casper/initrd /srv/tftp/ubuntu/
sudo unsquashfs -f -d /srv/nfs/ubuntu /mnt/iso/casper/filesystem.squashfs

# Unmount
sudo umount /mnt/iso
```

#### Step 3: Configure HP Laptop for Network Boot

```bash
# 1. Turn on HP laptop
# 2. IMMEDIATELY press F10 repeatedly
# 3. Go to: System Configuration → Boot Options
# 4. Enable: Network (PXE) Boot
# 5. Set Boot Order: Network first
# 6. Press F10 to save and exit
```

#### Step 4: Boot from Network

```bash
# 1. Connect HP laptop to same network as server
#    (Use network cable for best results)
# 2. Turn on HP laptop
# 3. Press F9 for boot menu
# 4. Select: Network Adapter / PXE Boot
# 5. HP laptop will boot from network
# 6. Select OS from PXE menu
```

---

## Method 3: Direct Installation (If You Can Boot into Linux)

If your HP laptop can already boot into a Linux live environment:

### Step-by-Step Instructions

```bash
# Boot into any Linux live environment
# (From another USB or existing installation)

# Open Terminal

# Download the tool
git clone https://github.com/acesonder/LIVE-BOOT.git
cd LIVE-BOOT

# Run installer
sudo ./live-boot-installer.sh

# Choose option 4 to download an OS
# OR have an ISO ready

# Then choose option 2 to install from storage
# Select your hard drive
# Type: yes to confirm

# Wait for installation
# Reboot when done
```

---

## Automatic Running (Auto-start on Boot)

To make this run automatically when booting from USB:

### Create Auto-start Script

```bash
# After creating bootable USB, before removing it:

# Mount the USB
sudo mount /dev/sdb1 /mnt

# Create autorun script
sudo tee /mnt/autorun.sh > /dev/null <<'EOF'
#!/bin/bash
# Wait for system to fully boot
sleep 10

# Check if running from live USB
if [ -f /etc/live-boot.conf ] || [ -f /etc/casper.conf ]; then
    # Open terminal and run installer
    if command -v gnome-terminal &> /dev/null; then
        gnome-terminal -- bash -c "cd /media/*/LIVEBOOT && sudo ./live-boot-installer.sh; exec bash"
    elif command -v xterm &> /dev/null; then
        xterm -e "cd /media/*/LIVEBOOT && sudo ./live-boot-installer.sh; exec bash"
    fi
fi
EOF

# Make executable
sudo chmod +x /mnt/autorun.sh

# Add to startup (for Ubuntu-based systems)
sudo mkdir -p /mnt/etc/xdg/autostart
sudo tee /mnt/etc/xdg/autostart/liveboot-installer.desktop > /dev/null <<'EOF'
[Desktop Entry]
Type=Application
Name=Live Boot Installer
Exec=/media/*/LIVEBOOT/autorun.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF

# Unmount
sudo umount /mnt
```

Now when you boot from this USB, the installer will automatically open!

---

## Quick Reference Card

Print or save this for quick access:

```
┌─────────────────────────────────────────────┐
│     HP LAPTOP LIVE BOOT QUICK GUIDE         │
├─────────────────────────────────────────────┤
│                                             │
│  BOOT MENU KEYS:                            │
│  • F9  = Boot device selection              │
│  • F10 = BIOS setup                         │
│  • ESC = Startup menu                       │
│                                             │
│  TO BOOT FROM USB:                          │
│  1. Insert USB                              │
│  2. Power on and press F9                   │
│  3. Select USB drive                        │
│  4. Press Enter                             │
│                                             │
│  INSTALLER COMMANDS:                        │
│  cd /media/*/LIVEBOOT                       │
│  sudo ./live-boot-installer.sh              │
│                                             │
│  MAIN OPTIONS:                              │
│  1 = Create bootable USB                    │
│  2 = Install OS from storage                │
│  3 = Install OS from network                │
│  4 = Download OS                            │
│  5 = Setup PXE server                       │
│  6 = Disk management                        │
│                                             │
│  RECOMMENDED FOR BEGINNERS:                 │
│  Option 4 → Download Ubuntu                 │
│  Option 1 → Create bootable USB            │
│  Boot from USB                              │
│  Option 2 → Install to hard drive          │
│                                             │
└─────────────────────────────────────────────┘
```

---

## Troubleshooting

### Problem: F9 doesn't show boot menu
**Solution**: Try ESC, then F9, or hold F9 while powering on

### Problem: USB doesn't appear in boot menu
**Solution**: 
1. Go to BIOS (F10)
2. Enable USB Boot
3. Disable Secure Boot
4. Save and exit

### Problem: Black screen after booting USB
**Solution**: Wait 2-3 minutes, or recreate USB with different ISO

### Problem: "Permission denied" errors
**Solution**: Make sure you use `sudo` before commands

### Problem: Can't find installer on USB
**Solution**: 
```bash
# Find it manually
find /media -name "live-boot-installer.sh"
cd /path/to/found/directory
sudo ./live-boot-installer.sh
```

---

## Video Tutorial Outline

If you need a visual guide, follow these steps:

1. **Preparation** (5 min)
   - Get USB drive
   - Download tool on working computer
   - Download Linux ISO

2. **Create Bootable USB** (10 min)
   - Run installer
   - Choose option 4 (Download) or use existing ISO
   - Choose option 1 (Create USB)
   - Select USB device
   - Confirm and wait

3. **Boot HP Laptop** (2 min)
   - Insert USB
   - Power on
   - Press F9
   - Select USB
   - Boot

4. **Install Operating System** (30 min)
   - Open terminal
   - Run installer from USB
   - Choose option 2 (Install)
   - Select hard drive
   - Confirm and wait
   - Reboot

**Total Time: ~47 minutes** (most is waiting for downloads/installation)

---

## Support

If you get stuck:
1. Check the troubleshooting section above
2. Read the full documentation: `docs/README.md`
3. Check HP-specific guide: `docs/HP-LAPTOP-GUIDE.md`
4. Open an issue on GitHub with your error message

---

**Remember**: Always backup important data before installing a new operating system!
