#!/bin/bash
# Disk and Partition Management Script

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

show_menu() {
    clear
    echo "========================================="
    echo "  Disk/Partition Management"
    echo "========================================="
    echo ""
    echo "  1) List all disks and partitions"
    echo "  2) Show disk details"
    echo "  3) Create partition"
    echo "  4) Format partition"
    echo "  5) Mount/Unmount partition"
    echo "  6) Check disk health (SMART)"
    echo "  7) Wipe disk (DANGEROUS)"
    echo "  8) Back to main menu"
    echo ""
}

list_disks() {
    info "All storage devices:"
    echo ""
    lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,MODEL
    echo ""
    
    info "Disk usage:"
    df -h | grep -v "tmpfs"
    echo ""
    
    read -p "Press Enter to continue..."
}

show_disk_details() {
    info "Available disks:"
    lsblk -d -o NAME,SIZE,TYPE,MODEL | grep disk
    echo ""
    
    read -p "Enter disk name (e.g., sda): " disk_name
    device="/dev/$disk_name"
    
    if [[ ! -b "$device" ]]; then
        error "Device not found: $device"
        return 1
    fi
    
    echo ""
    info "Detailed information for $device:"
    echo ""
    
    # Partition table
    echo "=== Partition Table ==="
    parted -s "$device" print 2>/dev/null || fdisk -l "$device"
    echo ""
    
    # Block device info
    echo "=== Block Device Info ==="
    lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT "$device"
    echo ""
    
    # SMART info if available
    if command -v smartctl &> /dev/null; then
        echo "=== SMART Health Status ==="
        smartctl -H "$device" 2>/dev/null || echo "SMART not available for this device"
        echo ""
    fi
    
    read -p "Press Enter to continue..."
}

create_partition() {
    info "Available disks:"
    lsblk -d -o NAME,SIZE,TYPE,MODEL | grep disk
    echo ""
    
    read -p "Enter disk name (e.g., sda): " disk_name
    device="/dev/$disk_name"
    
    if [[ ! -b "$device" ]]; then
        error "Device not found: $device"
        return 1
    fi
    
    echo ""
    info "Current partition table:"
    parted -s "$device" print 2>/dev/null || fdisk -l "$device"
    echo ""
    
    warning "This will modify partition table on $device"
    read -p "Continue? (yes/no): " confirm
    if [[ "$confirm" != "yes" ]]; then
        return 0
    fi
    
    echo ""
    echo "Partition scheme:"
    echo "  1) Single partition (entire disk)"
    echo "  2) Dual boot (half for each OS)"
    echo "  3) Manual partitioning"
    echo ""
    read -p "Select option [1-3]: " part_option
    
    case $part_option in
        1)
            log "Creating single partition..."
            parted -s "$device" mklabel gpt
            parted -s "$device" mkpart primary ext4 1MiB 100%
            ;;
        2)
            log "Creating dual boot partitions..."
            parted -s "$device" mklabel gpt
            parted -s "$device" mkpart primary ext4 1MiB 50%
            parted -s "$device" mkpart primary ext4 50% 100%
            ;;
        3)
            info "Starting interactive partitioning tool..."
            if command -v cfdisk &> /dev/null; then
                cfdisk "$device"
            elif command -v fdisk &> /dev/null; then
                fdisk "$device"
            else
                error "No partitioning tool found"
                return 1
            fi
            ;;
    esac
    
    log "✓ Partitioning complete"
    log "Updating kernel partition table..."
    partprobe "$device" 2>/dev/null || true
    
    echo ""
    info "New partition table:"
    lsblk "$device"
    echo ""
    
    read -p "Press Enter to continue..."
}

format_partition() {
    info "Available partitions:"
    lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT | grep part
    echo ""
    
    read -p "Enter partition (e.g., sda1): " part_name
    partition="/dev/$part_name"
    
    if [[ ! -b "$partition" ]]; then
        error "Partition not found: $partition"
        return 1
    fi
    
    # Check if mounted
    if mount | grep -q "$partition"; then
        warning "Partition is currently mounted"
        read -p "Unmount it? (yes/no): " unmount_confirm
        if [[ "$unmount_confirm" == "yes" ]]; then
            umount "$partition"
        else
            return 0
        fi
    fi
    
    echo ""
    echo "Filesystem type:"
    echo "  1) ext4 (Linux default)"
    echo "  2) FAT32 (Windows/Mac compatible)"
    echo "  3) NTFS (Windows)"
    echo "  4) exFAT (Cross-platform, large files)"
    echo ""
    read -p "Select filesystem [1-4]: " fs_choice
    
    warning "This will ERASE all data on $partition!"
    read -p "Are you sure? (yes/no): " confirm
    if [[ "$confirm" != "yes" ]]; then
        return 0
    fi
    
    case $fs_choice in
        1)
            log "Formatting as ext4..."
            mkfs.ext4 -F "$partition"
            ;;
        2)
            log "Formatting as FAT32..."
            mkfs.vfat -F 32 "$partition"
            ;;
        3)
            log "Formatting as NTFS..."
            if command -v mkfs.ntfs &> /dev/null; then
                mkfs.ntfs -f "$partition"
            else
                error "NTFS tools not installed. Install: ntfs-3g"
                return 1
            fi
            ;;
        4)
            log "Formatting as exFAT..."
            if command -v mkfs.exfat &> /dev/null; then
                mkfs.exfat "$partition"
            else
                error "exFAT tools not installed. Install: exfat-utils"
                return 1
            fi
            ;;
        *)
            error "Invalid choice"
            return 1
            ;;
    esac
    
    log "✓ Formatting complete"
    echo ""
    
    read -p "Press Enter to continue..."
}

mount_unmount() {
    info "Mounted partitions:"
    df -h | grep -v "tmpfs"
    echo ""
    
    echo "Options:"
    echo "  1) Mount partition"
    echo "  2) Unmount partition"
    echo ""
    read -p "Select [1-2]: " mount_choice
    
    case $mount_choice in
        1)
            info "Available unmounted partitions:"
            lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT -n | awk '$3 == "part" && $5 == ""'
            echo ""
            
            read -p "Enter partition to mount (e.g., sda1): " part_name
            partition="/dev/$part_name"
            
            if [[ ! -b "$partition" ]]; then
                error "Partition not found: $partition"
                return 1
            fi
            
            read -p "Enter mount point (e.g., /mnt/data): " mount_point
            
            mkdir -p "$mount_point"
            mount "$partition" "$mount_point"
            
            log "✓ Mounted $partition at $mount_point"
            ;;
        2)
            read -p "Enter partition to unmount (e.g., sda1) or mount point: " unmount_target
            
            if [[ "$unmount_target" == /dev/* ]]; then
                umount "$unmount_target"
            else
                umount "$unmount_target"
            fi
            
            log "✓ Unmounted $unmount_target"
            ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
}

check_disk_health() {
    if ! command -v smartctl &> /dev/null; then
        error "smartctl not found. Install smartmontools:"
        echo "  sudo apt install smartmontools  # Debian/Ubuntu"
        echo "  sudo dnf install smartmontools  # Fedora"
        read -p "Press Enter to continue..."
        return 1
    fi
    
    info "Available disks:"
    lsblk -d -o NAME,SIZE,TYPE,MODEL | grep disk
    echo ""
    
    read -p "Enter disk name (e.g., sda): " disk_name
    device="/dev/$disk_name"
    
    if [[ ! -b "$device" ]]; then
        error "Device not found: $device"
        return 1
    fi
    
    echo ""
    log "Running SMART health check on $device..."
    echo ""
    
    smartctl -H "$device"
    echo ""
    
    info "Full SMART data:"
    smartctl -a "$device" | less
    
    read -p "Press Enter to continue..."
}

wipe_disk() {
    info "Available disks:"
    lsblk -d -o NAME,SIZE,TYPE,MODEL | grep disk
    echo ""
    
    warning "DISK WIPE - THIS WILL PERMANENTLY ERASE ALL DATA!"
    echo ""
    
    read -p "Enter disk name to wipe (e.g., sda): " disk_name
    device="/dev/$disk_name"
    
    if [[ ! -b "$device" ]]; then
        error "Device not found: $device"
        return 1
    fi
    
    echo ""
    error "WARNING: This will PERMANENTLY ERASE $device!"
    error "All data will be UNRECOVERABLE!"
    echo ""
    read -p "Type 'ERASE ALL DATA' to confirm: " wipe_confirm
    
    if [[ "$wipe_confirm" != "ERASE ALL DATA" ]]; then
        info "Wipe cancelled"
        return 0
    fi
    
    log "Wiping disk $device..."
    log "This will take several minutes..."
    
    # Unmount all partitions
    for part in $(lsblk -ln -o NAME "$device" | grep -v "^$(basename "$device")$"); do
        umount "/dev/$part" 2>/dev/null || true
    done
    
    # Zero out first and last 10MB
    dd if=/dev/zero of="$device" bs=1M count=10 status=progress 2>/dev/null || true
    sync
    
    log "✓ Disk wiped successfully"
    echo ""
    
    read -p "Press Enter to continue..."
}

# Main loop
while true; do
    show_menu
    read -p "Select option [1-8]: " choice
    
    case $choice in
        1) list_disks ;;
        2) show_disk_details ;;
        3) create_partition ;;
        4) format_partition ;;
        5) mount_unmount ;;
        6) check_disk_health ;;
        7) wipe_disk ;;
        8) exit 0 ;;
        *) 
            error "Invalid option"
            sleep 2
            ;;
    esac
done
