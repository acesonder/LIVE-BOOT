#!/bin/bash
# Download OS with Built-in Browser Script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOWNLOAD_DIR="$HOME/Downloads/LiveBoot"

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
echo "  Download OS - Browser Mode"
echo "========================================="
echo ""

# Create download directory
mkdir -p "$DOWNLOAD_DIR"

# Check available browsers
BROWSER=""
if command -v firefox &> /dev/null; then
    BROWSER="firefox"
elif command -v chromium &> /dev/null; then
    BROWSER="chromium"
elif command -v google-chrome &> /dev/null; then
    BROWSER="google-chrome"
elif command -v links &> /dev/null; then
    BROWSER="links"
elif command -v w3m &> /dev/null; then
    BROWSER="w3m"
elif command -v lynx &> /dev/null; then
    BROWSER="lynx"
else
    error "No web browser found!"
    echo ""
    info "Please install a browser first:"
    echo "  sudo apt install firefox    # For Debian/Ubuntu"
    echo "  sudo dnf install firefox    # For Fedora"
    echo "  sudo pacman -S firefox      # For Arch"
    exit 1
fi

log "Using browser: $BROWSER"
echo ""

# Display download recommendations
info "Recommended Linux Distributions for HP Laptops:"
echo ""
echo "  1. Ubuntu 22.04 LTS"
echo "     - User-friendly, great hardware support"
echo "     - Download: https://ubuntu.com/download/desktop"
echo ""
echo "  2. Linux Mint 21"
echo "     - Easy to use, Windows-like interface"
echo "     - Download: https://linuxmint.com/download.php"
echo ""
echo "  3. Fedora Workstation"
echo "     - Latest software, GNOME desktop"
echo "     - Download: https://getfedora.org/workstation/"
echo ""
echo "  4. Debian 12"
echo "     - Stable, reliable"
echo "     - Download: https://www.debian.org/distrib/"
echo ""
echo "  5. Pop!_OS"
echo "     - Great for productivity and gaming"
echo "     - Download: https://pop.system76.com/"
echo ""

echo "Download Options:"
echo "  1) Open browser to recommended sites"
echo "  2) Enter custom URL"
echo "  3) Use command-line downloader (wget/curl)"
echo ""
read -p "Select option [1-3]: " dl_option

case $dl_option in
    1)
        info "Opening browser..."
        info "Downloads will be saved to: $DOWNLOAD_DIR"
        echo ""
        echo "Quick links will be opened in new tabs:"
        echo "  - Ubuntu"
        echo "  - Linux Mint"
        echo "  - Fedora"
        echo ""
        
        # Open browser with multiple tabs
        if [[ "$BROWSER" == "firefox" ]] || [[ "$BROWSER" == "chromium" ]] || [[ "$BROWSER" == "google-chrome" ]]; then
            $BROWSER \
                "https://ubuntu.com/download/desktop" \
                "https://linuxmint.com/download.php" \
                "https://getfedora.org/workstation/" &
        else
            # Text browser
            info "Using text-based browser. Navigate with arrow keys, Enter to follow links, 'q' to quit."
            read -p "Press Enter to continue..."
            $BROWSER "https://ubuntu.com/download/desktop"
        fi
        
        info "Browser launched. Download your preferred ISO file."
        echo ""
        read -p "Press Enter when download is complete..."
        ;;
        
    2)
        read -p "Enter download URL: " custom_url
        info "Opening browser to: $custom_url"
        
        if [[ "$BROWSER" == "firefox" ]] || [[ "$BROWSER" == "chromium" ]] || [[ "$BROWSER" == "google-chrome" ]]; then
            $BROWSER "$custom_url" &
        else
            $BROWSER "$custom_url"
        fi
        
        read -p "Press Enter when download is complete..."
        ;;
        
    3)
        info "Command-line download"
        echo ""
        echo "Example URLs:"
        echo "  Ubuntu: https://releases.ubuntu.com/22.04/ubuntu-22.04.3-desktop-amd64.iso"
        echo "  Fedora: https://download.fedoraproject.org/pub/fedora/linux/releases/38/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-38-1.6.iso"
        echo ""
        read -p "Enter ISO URL: " iso_url
        
        ISO_FILE="$DOWNLOAD_DIR/$(basename "$iso_url")"
        
        log "Downloading to: $ISO_FILE"
        log "This may take several minutes..."
        
        if command -v wget &> /dev/null; then
            wget -c -O "$ISO_FILE" "$iso_url" --progress=bar:force 2>&1
        elif command -v curl &> /dev/null; then
            curl -C - -L -o "$ISO_FILE" "$iso_url" --progress-bar
        else
            error "Neither wget nor curl found"
            exit 1
        fi
        
        if [[ -f "$ISO_FILE" ]]; then
            log "✓ Download complete: $ISO_FILE"
            log "  Size: $(du -h "$ISO_FILE" | cut -f1)"
        else
            error "Download failed"
            exit 1
        fi
        ;;
        
    *)
        error "Invalid option"
        exit 1
        ;;
esac

echo ""
info "Looking for downloaded ISO files in $DOWNLOAD_DIR..."
find "$DOWNLOAD_DIR" -name "*.iso" -type f 2>/dev/null || echo "No ISO files found yet"
echo ""

# Ask what to do next
echo "What would you like to do next?"
echo "  1) Create bootable USB/SD with downloaded ISO"
echo "  2) Install OS directly from downloaded ISO"
echo "  3) Return to main menu"
echo ""
read -p "Select option [1-3]: " next_action

case $next_action in
    1)
        info "Starting bootable media creation..."
        bash "${SCRIPT_DIR}/create-bootable-usb.sh"
        ;;
    2)
        info "Starting OS installation..."
        bash "${SCRIPT_DIR}/install-from-storage.sh"
        ;;
    3)
        info "Returning to main menu..."
        ;;
esac

exit 0
