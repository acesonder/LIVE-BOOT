#!/bin/bash
# Install OS from Network Script

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
echo "  Install OS from Network"
echo "========================================="
echo ""

# Check network connectivity
info "Checking network connectivity..."
if ! ping -c 1 8.8.8.8 &> /dev/null; then
    error "No network connectivity detected"
    echo ""
    info "Please configure network first:"
    echo "  - For WiFi: nmcli device wifi list"
    echo "  - Connect: nmcli device wifi connect SSID password PASSWORD"
    echo "  - For Ethernet: Should work automatically"
    exit 1
fi

log "✓ Network connectivity confirmed"
echo ""

# Network installation options
echo "Network Installation Options:"
echo "  1) Download from HTTP/FTP server"
echo "  2) Mount network share (NFS/SMB)"
echo "  3) PXE boot image"
echo ""
read -p "Select option [1-3]: " net_option

case $net_option in
    1)
        # HTTP/FTP download
        info "Download OS from HTTP/FTP server"
        echo ""
        echo "Example URLs:"
        echo "  - https://releases.ubuntu.com/22.04/ubuntu-22.04.3-desktop-amd64.iso"
        echo "  - https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.0.0-amd64-netinst.iso"
        echo ""
        read -p "Enter ISO URL: " iso_url
        
        ISO_FILE="/tmp/downloaded-os.iso"
        
        log "Downloading ISO from $iso_url..."
        log "This may take several minutes depending on your connection..."
        
        if command -v wget &> /dev/null; then
            wget -O "$ISO_FILE" "$iso_url" --progress=bar:force 2>&1
        elif command -v curl &> /dev/null; then
            curl -L -o "$ISO_FILE" "$iso_url" --progress-bar
        else
            error "Neither wget nor curl found. Cannot download."
            exit 1
        fi
        
        if [[ ! -f "$ISO_FILE" ]]; then
            error "Download failed"
            exit 1
        fi
        
        log "✓ Download completed: $(du -h "$ISO_FILE" | cut -f1)"
        ;;
        
    2)
        # Network share
        info "Mount Network Share"
        echo ""
        echo "Share type:"
        echo "  1) NFS"
        echo "  2) SMB/CIFS"
        echo ""
        read -p "Select [1-2]: " share_type
        
        MOUNT_POINT="/tmp/network-share-$$"
        mkdir -p "$MOUNT_POINT"
        
        case $share_type in
            1)
                # NFS
                read -p "Enter NFS server and path (e.g., 192.168.1.100:/share): " nfs_path
                log "Mounting NFS share..."
                mount -t nfs "$nfs_path" "$MOUNT_POINT" || {
                    error "Failed to mount NFS share"
                    rmdir "$MOUNT_POINT"
                    exit 1
                }
                ;;
            2)
                # SMB/CIFS
                read -p "Enter SMB server (e.g., //192.168.1.100/share): " smb_path
                read -p "Enter username (or press Enter for guest): " smb_user
                
                if [[ -z "$smb_user" ]]; then
                    mount -t cifs "$smb_path" "$MOUNT_POINT" -o guest || {
                        error "Failed to mount SMB share"
                        rmdir "$MOUNT_POINT"
                        exit 1
                    }
                else
                    read -s -p "Enter password: " smb_pass
                    echo ""
                    mount -t cifs "$smb_path" "$MOUNT_POINT" -o username="$smb_user",password="$smb_pass" || {
                        error "Failed to mount SMB share"
                        rmdir "$MOUNT_POINT"
                        exit 1
                    }
                fi
                ;;
        esac
        
        log "✓ Network share mounted at $MOUNT_POINT"
        info "Looking for ISO files..."
        find "$MOUNT_POINT" -name "*.iso" -type f
        echo ""
        
        read -p "Enter ISO filename: " iso_name
        ISO_FILE="$MOUNT_POINT/$iso_name"
        
        if [[ ! -f "$ISO_FILE" ]]; then
            error "ISO file not found: $ISO_FILE"
            umount "$MOUNT_POINT"
            rmdir "$MOUNT_POINT"
            exit 1
        fi
        ;;
        
    3)
        # PXE boot image
        info "PXE Boot Image Installation"
        echo ""
        read -p "Enter PXE server IP: " pxe_server
        read -p "Enter image name: " pxe_image
        
        log "Fetching boot image from PXE server..."
        
        # Download kernel and initrd
        TFTP_DIR="/tmp/pxe-boot-$$"
        mkdir -p "$TFTP_DIR"
        
        if command -v tftp &> /dev/null; then
            cd "$TFTP_DIR"
            tftp "$pxe_server" <<EOF
get $pxe_image
quit
EOF
            ISO_FILE="$TFTP_DIR/$pxe_image"
        else
            error "TFTP client not found. Please install tftp."
            rmdir "$TFTP_DIR"
            exit 1
        fi
        ;;
        
    *)
        error "Invalid option"
        exit 1
        ;;
esac

if [[ ! -f "$ISO_FILE" ]]; then
    error "ISO file not available: $ISO_FILE"
    exit 1
fi

info "ISO file ready: $ISO_FILE"
info "Size: $(du -h "$ISO_FILE" | cut -f1)"
echo ""

# Now perform installation
info "Select target device for installation:"
lsblk -d -o NAME,SIZE,TYPE,MODEL | grep -E "disk"
echo ""
read -p "Enter target device (e.g., /dev/sda): " target_device

if [[ ! -b "$target_device" ]]; then
    error "Invalid device: $target_device"
    exit 1
fi

warning "This will ERASE all data on $target_device!"
read -p "Continue? (yes/no): " confirm
if [[ "$confirm" != "yes" ]]; then
    info "Installation cancelled"
    exit 0
fi

# Use the storage installation script
export ISO_FILE
bash "${SCRIPT_DIR}/install-from-storage.sh"

log "✓ Network installation completed!"

exit 0
