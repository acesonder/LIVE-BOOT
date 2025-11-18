#!/bin/bash
# Install OS from Storage Device Script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
info() { echo -e "${CYAN}[INFO]${NC} $1"; }

echo "========================================="
echo "  Install OS from Storage Device"
echo "========================================="
echo ""

# Check if ISO_FILE is already provided (e.g., from network installer)
if [[ -z "$ISO_FILE" ]]; then
    # Detect available storage devices
    info "Scanning for storage devices with ISO files..."
    echo ""

    # List all block devices
    info "Available storage devices:"
    lsblk -d -o NAME,SIZE,TYPE,MODEL | grep -E "disk"
    echo ""

    # Search for ISO files on mounted devices
    info "Searching for ISO files on mounted devices..."
    ISO_FILES=$(find /media /mnt /run/media -name "*.iso" 2>/dev/null || true)

    if [[ -n "$ISO_FILES" ]]; then
        echo "Found ISO files:"
        echo "$ISO_FILES"
        echo ""
    fi

    # Manual selection
    echo "Options:"
    echo "  1) Auto-detect ISO from mounted devices"
    echo "  2) Mount device and search for ISO"
    echo "  3) Enter ISO path manually"
    echo ""
    read -p "Select option [1-3]: " option

    case $option in
        1)
            if [[ -z "$ISO_FILES" ]]; then
                error "No ISO files found on mounted devices"
                exit 1
            fi
            # Select first ISO found
            ISO_FILE=$(echo "$ISO_FILES" | head -n1)
            info "Using: $ISO_FILE"
            ;;
        2)
            read -p "Enter device to mount (e.g., /dev/sdb1): " mount_dev
            TEMP_MOUNT="/tmp/iso-search-$$"
            mkdir -p "$TEMP_MOUNT"
            mount "$mount_dev" "$TEMP_MOUNT" 2>/dev/null || {
                error "Failed to mount $mount_dev"
                rmdir "$TEMP_MOUNT"
                exit 1
            }
            
            info "Searching for ISO files..."
            find "$TEMP_MOUNT" -name "*.iso" -type f
            echo ""
            read -p "Enter ISO filename: " iso_name
            ISO_FILE="$TEMP_MOUNT/$iso_name"
            ;;
        3)
            read -p "Enter full path to ISO file: " ISO_FILE
            ;;
        *)
            error "Invalid option"
            exit 1
            ;;
    esac
else
    info "Using pre-selected ISO: $ISO_FILE"
fi

if [[ ! -f "$ISO_FILE" ]]; then
    error "ISO file not found: $ISO_FILE"
    exit 1
fi

info "ISO file: $ISO_FILE"
info "ISO size: $(du -h "$ISO_FILE" | cut -f1)"
echo ""

# Select target installation device
info "Select target device for OS installation:"
lsblk -d -o NAME,SIZE,TYPE,MODEL | grep -E "disk"
echo ""
read -p "Enter target device (e.g., /dev/sda): " target_device

if [[ ! -b "$target_device" ]]; then
    error "Invalid device: $target_device"
    exit 1
fi

warning "This will ERASE all data on $target_device and install the OS!"
read -p "Are you absolutely sure? (yes/no): " confirm
if [[ "$confirm" != "yes" ]]; then
    info "Operation cancelled"
    exit 0
fi

log "Starting OS installation..."

# Check if ISO has an installer script
ISO_MOUNT="/tmp/iso-install-$$"
mkdir -p "$ISO_MOUNT"
mount -o loop "$ISO_FILE" "$ISO_MOUNT"

if [[ -f "$ISO_MOUNT/install.sh" ]] || [[ -f "$ISO_MOUNT/setup.sh" ]]; then
    info "Found installer script in ISO, running it..."
    bash "$ISO_MOUNT/install.sh" "$target_device" 2>/dev/null || bash "$ISO_MOUNT/setup.sh" "$target_device"
else
    # Manual installation process
    log "Partitioning target device..."
    parted -s "$target_device" mklabel gpt
    parted -s "$target_device" mkpart primary fat32 1MiB 513MiB
    parted -s "$target_device" set 1 esp on
    parted -s "$target_device" mkpart primary ext4 513MiB 100%
    
    sleep 2
    
    # Format partitions
    TARGET_PART1="${target_device}1"
    TARGET_PART2="${target_device}2"
    
    # Handle devices like /dev/mmcblk0
    if [[ ! -b "$TARGET_PART1" ]]; then
        TARGET_PART1="${target_device}p1"
        TARGET_PART2="${target_device}p2"
    fi
    
    log "Formatting EFI partition..."
    mkfs.vfat -F 32 "$TARGET_PART1"
    
    log "Formatting root partition..."
    mkfs.ext4 -F "$TARGET_PART2"
    
    # Mount and copy system
    TARGET_MOUNT="/tmp/target-install-$$"
    mkdir -p "$TARGET_MOUNT"
    mount "$TARGET_PART2" "$TARGET_MOUNT"
    mkdir -p "$TARGET_MOUNT/boot/efi"
    mount "$TARGET_PART1" "$TARGET_MOUNT/boot/efi"
    
    log "Copying system files (this will take several minutes)..."
    
    # Copy files from ISO
    if [[ -d "$ISO_MOUNT/casper" ]]; then
        # Ubuntu-based
        TMP_UNSQUASH="/tmp/unsquashfs-$$"
        mkdir -p "$TMP_UNSQUASH"
        unsquashfs -f -d "$TMP_UNSQUASH" "$ISO_MOUNT/casper/filesystem.squashfs"
        cp -a "$TMP_UNSQUASH"/* "$TARGET_MOUNT"/
        rm -rf "$TMP_UNSQUASH"
    elif [[ -d "$ISO_MOUNT/LiveOS" ]]; then
        # Fedora-based
        TMP_UNSQUASH="/tmp/unsquashfs-$$"
        mkdir -p "$TMP_UNSQUASH"
        unsquashfs -f -d "$TMP_UNSQUASH" "$ISO_MOUNT/LiveOS/squashfs.img"
        cp -a "$TMP_UNSQUASH"/* "$TARGET_MOUNT"/
        rm -rf "$TMP_UNSQUASH"
    else
        # Generic copy
        cp -a "$ISO_MOUNT"/* "$TARGET_MOUNT"/
    fi
    
    sync
    
    # Install bootloader
    if command -v grub-install &> /dev/null; then
        log "Installing bootloader..."
        mount --bind /dev "$TARGET_MOUNT/dev"
        mount --bind /proc "$TARGET_MOUNT/proc"
        mount --bind /sys "$TARGET_MOUNT/sys"
        
        chroot "$TARGET_MOUNT" grub-install "$target_device"
        chroot "$TARGET_MOUNT" update-grub
        
        umount "$TARGET_MOUNT/sys"
        umount "$TARGET_MOUNT/proc"
        umount "$TARGET_MOUNT/dev"
    fi
    
    # Unmount
    umount "$TARGET_MOUNT/boot/efi"
    umount "$TARGET_MOUNT"
    rmdir "$TARGET_MOUNT"
fi

umount "$ISO_MOUNT"
rmdir "$ISO_MOUNT"

log "✓ OS installation completed successfully!"
echo ""
info "You can now reboot your system and boot from $target_device"
echo ""

read -p "Would you like to reboot now? (yes/no): " reboot_choice
if [[ "$reboot_choice" == "yes" ]]; then
    log "Rebooting system..."
    reboot
fi

exit 0
