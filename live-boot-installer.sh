#!/bin/bash
# Live Boot OS Installer - Main Script
# For HP Laptops without internet recovery
# Supports boot from USB, SD Card, or Network (PXE)

VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Color codes for better UI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Log function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root"
        echo "Please run: sudo $0"
        exit 1
    fi
}

# Display banner
show_banner() {
    clear
    cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║         LIVE BOOT OS INSTALLER v1.0.0                    ║
║         For HP Laptops                                   ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
    echo ""
}

# Main menu
show_main_menu() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}Main Menu${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo ""
    echo "  1) Create Bootable USB/SD Card"
    echo "  2) Install OS from Storage Device"
    echo "  3) Install OS from Network"
    echo "  4) Download OS (Built-in Browser)"
    echo "  5) Setup Network Boot (PXE Server)"
    echo "  6) Disk/Partition Management"
    echo "  7) System Information"
    echo "  8) Help & Documentation"
    echo "  9) Exit"
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
}

# Create bootable USB/SD card
create_bootable_media() {
    show_banner
    echo -e "${CYAN}Create Bootable USB/SD Card${NC}"
    echo ""
    
    # List available devices
    info "Available storage devices:"
    lsblk -d -o NAME,SIZE,TYPE,MODEL | grep -E "disk|part"
    echo ""
    
    read -p "Enter device path (e.g., /dev/sdb): " device
    
    if [[ ! -b "$device" ]]; then
        error "Invalid device: $device"
        return 1
    fi
    
    warning "This will ERASE all data on $device"
    read -p "Are you sure? (yes/no): " confirm
    
    if [[ "$confirm" != "yes" ]]; then
        info "Operation cancelled"
        return 0
    fi
    
    # Call the bootable media creation script
    bash "${SCRIPT_DIR}/scripts/create-bootable-usb.sh" "$device"
}

# Install OS from storage device
install_from_storage() {
    show_banner
    echo -e "${CYAN}Install OS from Storage Device${NC}"
    echo ""
    
    bash "${SCRIPT_DIR}/scripts/install-from-storage.sh"
}

# Install OS from network
install_from_network() {
    show_banner
    echo -e "${CYAN}Install OS from Network${NC}"
    echo ""
    
    bash "${SCRIPT_DIR}/scripts/install-from-network.sh"
}

# Download OS using built-in browser
download_os() {
    show_banner
    echo -e "${CYAN}Download OS - Browser Mode${NC}"
    echo ""
    
    info "Opening web browser for OS download..."
    info "Common download locations:"
    echo "  - Ubuntu: https://ubuntu.com/download"
    echo "  - Linux Mint: https://linuxmint.com/download.php"
    echo "  - Debian: https://www.debian.org/distrib/"
    echo "  - Fedora: https://getfedora.org/"
    echo ""
    
    bash "${SCRIPT_DIR}/scripts/download-os.sh"
}

# Setup PXE server for network boot
setup_pxe_server() {
    show_banner
    echo -e "${CYAN}Setup Network Boot (PXE Server)${NC}"
    echo ""
    
    bash "${SCRIPT_DIR}/scripts/setup-pxe-server.sh"
}

# Disk and partition management
disk_management() {
    show_banner
    echo -e "${CYAN}Disk/Partition Management${NC}"
    echo ""
    
    bash "${SCRIPT_DIR}/scripts/disk-management.sh"
}

# Show system information
show_system_info() {
    show_banner
    echo -e "${CYAN}System Information${NC}"
    echo ""
    
    info "Hardware Information:"
    echo "Manufacturer: $(dmidecode -s system-manufacturer 2>/dev/null || echo 'N/A')"
    echo "Product: $(dmidecode -s system-product-name 2>/dev/null || echo 'N/A')"
    echo "Serial: $(dmidecode -s system-serial-number 2>/dev/null || echo 'N/A')"
    echo ""
    
    info "CPU Information:"
    lscpu | grep -E "Model name|Architecture|CPU\(s\):"
    echo ""
    
    info "Memory Information:"
    free -h
    echo ""
    
    info "Storage Devices:"
    lsblk -d -o NAME,SIZE,TYPE,MODEL
    echo ""
    
    info "Network Interfaces:"
    ip -br addr
    echo ""
    
    read -p "Press Enter to continue..."
}

# Show help and documentation
show_help() {
    show_banner
    echo -e "${CYAN}Help & Documentation${NC}"
    echo ""
    
    cat << EOF
This Live Boot OS Installer provides multiple methods to install an
operating system on your HP laptop:

${YELLOW}Boot Methods:${NC}
  - USB Key: Create a bootable USB drive
  - SD Card: Create a bootable SD card
  - Network Boot: Use PXE to boot from another computer

${YELLOW}Installation Sources:${NC}
  - Storage Device: Install from ISO on USB/SD/HDD
  - Network: Download and install from network share
  - Download: Use built-in browser to download OS

${YELLOW}Requirements:${NC}
  - Root/sudo access
  - At least 8GB USB drive or SD card for bootable media
  - Internet connection (for download option)
  - Another PC/Mac for network boot setup

${YELLOW}Quick Start:${NC}
  1. Create bootable USB using option 1
  2. Boot HP laptop from USB
  3. Use option 2 or 3 to install OS
  4. Follow on-screen instructions

For detailed documentation, see: ${SCRIPT_DIR}/docs/README.md

EOF
    
    read -p "Press Enter to continue..."
}

# Main program loop
main() {
    check_root
    
    while true; do
        show_banner
        show_main_menu
        
        read -p "Select option [1-9]: " choice
        
        case $choice in
            1)
                create_bootable_media
                ;;
            2)
                install_from_storage
                ;;
            3)
                install_from_network
                ;;
            4)
                download_os
                ;;
            5)
                setup_pxe_server
                ;;
            6)
                disk_management
                ;;
            7)
                show_system_info
                ;;
            8)
                show_help
                ;;
            9)
                log "Exiting Live Boot OS Installer"
                exit 0
                ;;
            *)
                error "Invalid option: $choice"
                sleep 2
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Run main program
main "$@"
