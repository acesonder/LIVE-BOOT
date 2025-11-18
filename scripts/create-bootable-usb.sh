#!/bin/bash
# Create Bootable USB/SD Card Script

set -e

DEVICE="$1"
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

if [[ -z "$DEVICE" ]]; then
    error "Device not specified"
    exit 1
fi

echo "========================================="
echo "  Bootable USB/SD Card Creator"
echo "========================================="
echo ""

# Check if device is mounted
mounted=$(mount | grep "$DEVICE" || true)
if [[ -n "$mounted" ]]; then
    warning "Device is currently mounted. Unmounting..."
    umount "${DEVICE}"* 2>/dev/null || true
fi

# Select ISO source
echo "Select ISO source:"
echo "  1) From local file"
echo "  2) From downloaded ISOs"
echo "  3) Enter custom path"
echo ""
read -p "Select option [1-3]: " iso_choice

ISO_FILE=""
case $iso_choice in
    1)
        info "Available ISO files in current directory:"
        find . -name "*.iso" -type f 2>/dev/null || echo "No ISO files found"
        echo ""
        read -p "Enter ISO filename: " ISO_FILE
        ;;
    2)
        ISO_DIR="$HOME/Downloads"
        info "Looking for ISO files in $ISO_DIR:"
        find "$ISO_DIR" -name "*.iso" -type f 2>/dev/null || echo "No ISO files found"
        echo ""
        read -p "Enter ISO filename: " ISO_FILE
        ;;
    3)
        read -p "Enter full path to ISO file: " ISO_FILE
        ;;
    *)
        error "Invalid option"
        exit 1
        ;;
esac

if [[ ! -f "$ISO_FILE" ]]; then
    error "ISO file not found: $ISO_FILE"
    exit 1
fi

info "ISO file: $ISO_FILE"
info "Target device: $DEVICE"
info "ISO size: $(du -h "$ISO_FILE" | cut -f1)"
echo ""

warning "This will ERASE all data on $DEVICE!"
read -p "Continue? (yes/no): " confirm
if [[ "$confirm" != "yes" ]]; then
    info "Operation cancelled"
    exit 0
fi

log "Creating bootable media..."

# Wipe the device
log "Wiping device partition table..."
dd if=/dev/zero of="$DEVICE" bs=1M count=10 status=progress || true
sync

# Create new partition table
log "Creating new partition table..."
parted -s "$DEVICE" mklabel msdos
parted -s "$DEVICE" mkpart primary fat32 1MiB 100%
parted -s "$DEVICE" set 1 boot on
sync

# Wait for partition to appear
sleep 2

# Format partition
PARTITION="${DEVICE}1"
if [[ ! -b "$PARTITION" ]]; then
    # Handle devices like /dev/mmcblk0 which use p1
    PARTITION="${DEVICE}p1"
fi

log "Formatting partition as FAT32..."
mkfs.vfat -F 32 -n "LIVEBOOT" "$PARTITION"
sync

# Mount partition
MOUNT_POINT="/tmp/liveboot-mount-$$"
mkdir -p "$MOUNT_POINT"
mount "$PARTITION" "$MOUNT_POINT"

# Extract ISO to USB
log "Extracting ISO to device (this may take several minutes)..."

# Method 1: Try using 7z if available
if command -v 7z &> /dev/null; then
    7z x "$ISO_FILE" -o"$MOUNT_POINT" -y
elif command -v bsdtar &> /dev/null; then
    # Method 2: Use bsdtar
    bsdtar -xf "$ISO_FILE" -C "$MOUNT_POINT"
else
    # Method 3: Mount and copy
    ISO_MOUNT="/tmp/iso-mount-$$"
    mkdir -p "$ISO_MOUNT"
    mount -o loop "$ISO_FILE" "$ISO_MOUNT"
    
    log "Copying files..."
    cp -rv "$ISO_MOUNT"/* "$MOUNT_POINT"/
    
    umount "$ISO_MOUNT"
    rmdir "$ISO_MOUNT"
fi

sync

# Install bootloader (if grub is available)
if command -v grub-install &> /dev/null; then
    log "Installing bootloader..."
    grub-install --target=i386-pc --boot-directory="$MOUNT_POINT/boot" "$DEVICE" 2>/dev/null || warning "Could not install GRUB (may not be needed)"
fi

# Make sure the device is bootable
sync

# Unmount
log "Unmounting device..."
umount "$MOUNT_POINT"
rmdir "$MOUNT_POINT"

log "✓ Bootable media created successfully!"
echo ""
info "You can now:"
echo "  1. Safely remove the device"
echo "  2. Insert it into your HP laptop"
echo "  3. Boot from USB/SD (usually F9 or ESC for boot menu)"
echo ""

exit 0
