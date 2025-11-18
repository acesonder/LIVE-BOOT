#!/bin/bash
# Setup PXE Server for Network Boot

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
echo "  PXE Server Setup"
echo "========================================="
echo ""

info "This will set up a PXE server to enable network booting"
info "You'll need:"
echo "  - Another computer (PC/Mac) on the same network"
echo "  - Root/administrator access on that computer"
echo "  - DHCP and TFTP server software"
echo ""

warning "Note: This should be run on the SERVER computer, not the HP laptop"
read -p "Continue? (yes/no): " continue_setup

if [[ "$continue_setup" != "yes" ]]; then
    exit 0
fi

# Detect OS
if [[ -f /etc/debian_version ]]; then
    OS="debian"
    PKG_MANAGER="apt"
elif [[ -f /etc/redhat-release ]]; then
    OS="redhat"
    PKG_MANAGER="dnf"
elif [[ "$(uname)" == "Darwin" ]]; then
    OS="macos"
    PKG_MANAGER="brew"
else
    OS="unknown"
fi

log "Detected OS: $OS"
echo ""

# Install required packages
info "Installing required packages..."

case $OS in
    debian)
        apt update
        apt install -y dnsmasq pxelinux syslinux-common nfs-kernel-server
        ;;
    redhat)
        dnf install -y dnsmasq syslinux tftp-server nfs-utils
        ;;
    macos)
        if ! command -v brew &> /dev/null; then
            error "Homebrew not found. Please install from https://brew.sh"
            exit 1
        fi
        brew install dnsmasq
        ;;
    *)
        error "Unsupported OS. Please install manually:"
        echo "  - dnsmasq (DHCP/TFTP server)"
        echo "  - pxelinux/syslinux"
        echo "  - NFS server (optional)"
        exit 1
        ;;
esac

log "✓ Packages installed"
echo ""

# Configure network
info "Network configuration:"
ip -br addr | grep -v "lo"
echo ""
read -p "Enter network interface to use (e.g., eth0, enp0s3): " net_interface
read -p "Enter IP address for this server (e.g., 192.168.1.10): " server_ip
read -p "Enter DHCP range start (e.g., 192.168.1.100): " dhcp_start
read -p "Enter DHCP range end (e.g., 192.168.1.200): " dhcp_end

# Setup directories
TFTP_ROOT="/srv/tftp"
NFS_ROOT="/srv/nfs"
PXE_BOOT="$TFTP_ROOT/pxelinux.cfg"

log "Creating directories..."
mkdir -p "$TFTP_ROOT"
mkdir -p "$PXE_BOOT"
mkdir -p "$NFS_ROOT"

# Copy PXE files
log "Copying PXE boot files..."
if [[ -f /usr/lib/PXELINUX/pxelinux.0 ]]; then
    cp /usr/lib/PXELINUX/pxelinux.0 "$TFTP_ROOT/"
elif [[ -f /usr/share/syslinux/pxelinux.0 ]]; then
    cp /usr/share/syslinux/pxelinux.0 "$TFTP_ROOT/"
fi

if [[ -d /usr/lib/syslinux/modules/bios/ ]]; then
    cp /usr/lib/syslinux/modules/bios/*.c32 "$TFTP_ROOT/"
elif [[ -d /usr/share/syslinux/ ]]; then
    cp /usr/share/syslinux/*.c32 "$TFTP_ROOT/" 2>/dev/null || true
fi

# Configure dnsmasq
log "Configuring dnsmasq..."
cat > /etc/dnsmasq.d/pxe.conf <<EOF
# PXE Server Configuration
interface=$net_interface
bind-interfaces

# DHCP range
dhcp-range=$dhcp_start,$dhcp_end,12h

# PXE boot options
dhcp-boot=pxelinux.0

# TFTP settings
enable-tftp
tftp-root=$TFTP_ROOT

# Logging
log-dhcp
log-queries
EOF

# Create PXE menu
log "Creating PXE boot menu..."
cat > "$PXE_BOOT/default" <<'EOF'
DEFAULT menu.c32
PROMPT 0
TIMEOUT 300
ONTIMEOUT local

MENU TITLE Live Boot PXE Server

LABEL local
    MENU LABEL ^Boot from Local Drive
    MENU DEFAULT
    LOCALBOOT 0

LABEL ubuntu
    MENU LABEL Install ^Ubuntu
    KERNEL ubuntu/vmlinuz
    APPEND initrd=ubuntu/initrd boot=casper netboot=nfs nfsroot=SERVER_IP:/srv/nfs/ubuntu

LABEL fedora
    MENU LABEL Install ^Fedora
    KERNEL fedora/vmlinuz
    APPEND initrd=fedora/initrd.img root=live:nfs://SERVER_IP/srv/nfs/fedora

LABEL memtest
    MENU LABEL ^Memory Test
    KERNEL memtest86+.bin

LABEL rescue
    MENU LABEL ^Rescue Mode
    KERNEL rescue/vmlinuz
    APPEND initrd=rescue/initrd.img

EOF

# Replace SERVER_IP placeholder
sed -i "s/SERVER_IP/$server_ip/g" "$PXE_BOOT/default"

# Setup NFS exports
log "Configuring NFS..."
cat >> /etc/exports <<EOF

# PXE Boot exports
$NFS_ROOT *(ro,sync,no_root_squash,no_subtree_check)
EOF

# Set permissions
chmod -R 755 "$TFTP_ROOT"
chmod -R 755 "$NFS_ROOT"

# Enable and start services
log "Starting services..."
systemctl enable dnsmasq 2>/dev/null || true
systemctl restart dnsmasq

if [[ "$OS" == "debian" ]]; then
    systemctl enable nfs-kernel-server 2>/dev/null || true
    systemctl restart nfs-kernel-server
elif [[ "$OS" == "redhat" ]]; then
    systemctl enable nfs-server 2>/dev/null || true
    systemctl restart nfs-server
fi

exportfs -ra 2>/dev/null || true

log "✓ PXE server setup complete!"
echo ""
info "Server Configuration:"
echo "  Server IP: $server_ip"
echo "  TFTP Root: $TFTP_ROOT"
echo "  NFS Root: $NFS_ROOT"
echo "  Interface: $net_interface"
echo ""

info "Next steps:"
echo "  1. Add OS images to the appropriate directories:"
echo "     - $TFTP_ROOT/ubuntu/ (for Ubuntu kernel and initrd)"
echo "     - $NFS_ROOT/ubuntu/ (for Ubuntu filesystem)"
echo ""
echo "  2. To add Ubuntu:"
echo "     mkdir -p $TFTP_ROOT/ubuntu $NFS_ROOT/ubuntu"
echo "     mount -o loop ubuntu.iso /mnt"
echo "     cp /mnt/casper/vmlinuz $TFTP_ROOT/ubuntu/"
echo "     cp /mnt/casper/initrd $TFTP_ROOT/ubuntu/"
echo "     unsquashfs -d $NFS_ROOT/ubuntu /mnt/casper/filesystem.squashfs"
echo ""
echo "  3. Configure HP laptop BIOS:"
echo "     - Enable Network Boot (PXE)"
echo "     - Set boot order to Network first"
echo ""
echo "  4. Connect HP laptop to same network and boot"
echo ""

info "Configuration files:"
echo "  - /etc/dnsmasq.d/pxe.conf"
echo "  - $PXE_BOOT/default"
echo "  - /etc/exports"
echo ""

exit 0
