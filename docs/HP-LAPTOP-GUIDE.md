# HP Laptop Specific Guide

## HP Laptop Boot Configuration

This guide provides specific instructions for HP laptops, including BIOS configuration, boot options, and troubleshooting common HP-specific issues.

## Accessing HP BIOS

### Boot Menu Keys

Different HP laptop models use different keys:

| Key | Function | When to Press |
|-----|----------|---------------|
| **F9** | Boot Device Options | During startup (HP logo) |
| **F10** | BIOS Setup | During startup (HP logo) |
| **F11** | System Recovery | During startup (HP logo) |
| **ESC** | Startup Menu | During startup (HP logo) |
| **F2** | System Diagnostics | During startup (HP logo) |

### Startup Sequence

1. **Power on** the laptop
2. **Immediately press** the desired key repeatedly
3. Watch for the **HP logo**
4. Keep pressing until menu appears

**Tip**: If you miss it, restart and try again. You have about 2-3 seconds.

## BIOS Configuration for Boot

### Enable USB Boot

1. Press **F10** during startup to enter BIOS
2. Navigate to **System Configuration** tab
3. Select **Boot Options**
4. Find **USB Boot** option
5. Set to **Enabled**
6. Press **F10** to save and exit

### Configure Boot Order

1. In BIOS, go to **System Configuration** → **Boot Options**
2. Adjust **Boot Order** or **Legacy Boot Order**:
   - For USB: Move **USB Hard Drive** to top
   - For Network: Move **Network Adapter** to top
3. Save and exit (**F10**)

### Disable Secure Boot (If Needed)

Some Linux distributions require Secure Boot to be disabled:

1. In BIOS, go to **Security** tab
2. Find **Secure Boot Configuration**
3. Select **Secure Boot**
4. Set to **Disabled**
5. Save and exit (**F10**)

**Note**: Only disable if you have boot issues. You can re-enable after installation.

### Enable Legacy Support

For older distributions or if UEFI boot fails:

1. In BIOS, go to **System Configuration** → **Boot Options**
2. Enable **Legacy Support**
3. Set **Boot Mode** to **Legacy** or **Both**
4. Save and exit

## HP Laptop Models

### HP EliteBook Series

**BIOS Access**: F10
**Boot Menu**: F9
**Features**:
- Full UEFI support
- Network boot capable
- Secure Boot available
- TPM module

**Recommended Settings**:
- Legacy Support: Disabled (use UEFI)
- Secure Boot: Enabled (disable only if needed)
- Network Boot: Enable for PXE

### HP ProBook Series

**BIOS Access**: F10
**Boot Menu**: F9
**Features**:
- UEFI and Legacy support
- Most have Network boot
- SD card slot (some models)

**Recommended Settings**:
- Legacy Support: Enabled
- Secure Boot: Disabled
- USB Boot: Enabled

### HP Pavilion Series

**BIOS Access**: F10 or ESC then F10
**Boot Menu**: F9 or ESC then F9
**Features**:
- Consumer-focused
- UEFI support (newer models)
- USB boot support

**Recommended Settings**:
- Legacy Support: Enabled
- Secure Boot: Disabled
- Fast Boot: Disabled

### HP Envy Series

**BIOS Access**: F10
**Boot Menu**: F9
**Features**:
- Modern UEFI
- Fast boot technology
- Limited Legacy support

**Recommended Settings**:
- UEFI Mode only
- Secure Boot: Disable for Linux
- Fast Boot: Disable for USB boot

### HP Stream Series

**BIOS Access**: F10
**Boot Menu**: F9
**Features**:
- Budget laptops
- Limited BIOS options
- 32GB storage (limited space)

**Special Notes**:
- May require external storage for OS
- Use lightweight distributions
- Network boot recommended

## Common HP-Specific Issues

### Issue 1: F9/F10 Not Working

**Symptoms**: Pressing F9 or F10 does nothing

**Solutions**:
1. Try holding **Fn + F9** or **Fn + F10**
2. Try **ESC** key instead, then select option
3. Disable **Fast Startup** in Windows (if dual-booting)
4. Try external USB keyboard
5. Update BIOS firmware

### Issue 2: USB Not Detected

**Symptoms**: USB drive doesn't appear in boot menu

**Solutions**:
1. Enable **USB Boot** in BIOS
2. Try different USB port (avoid USB 3.0 ports, use 2.0)
3. Format USB as **FAT32** instead of NTFS
4. Ensure USB is **bootable** (recreate if needed)
5. Try **Legacy Boot** mode
6. Check if USB works on another computer

### Issue 3: Secure Boot Violation

**Symptoms**: "Secure Boot Violation" error message

**Solutions**:
1. Enter BIOS (F10)
2. Go to **Security** → **Secure Boot Configuration**
3. Disable **Secure Boot**
4. Save and exit
5. Try booting again

### Issue 4: No Network Boot Option

**Symptoms**: PXE or Network boot not available

**Solutions**:
1. Check if model supports PXE (business models usually do)
2. Enable **Legacy Support** in BIOS
3. Enable **Network Boot** in BIOS
4. Try wired connection (WiFi PXE not common)
5. Update network card firmware
6. Use USB boot instead if not supported

### Issue 5: Black Screen After Boot

**Symptoms**: Screen goes black after selecting boot device

**Solutions**:
1. Wait 2-3 minutes (may be loading)
2. Try **Safe Graphics** option in boot menu
3. Edit boot parameters:
   - Press 'e' at GRUB menu
   - Add `nomodeset` to kernel line
   - Press F10 to boot
4. Try different Linux distribution
5. Update HP graphics drivers after installation

### Issue 6: Touchpad Not Working

**Symptoms**: Touchpad doesn't work in live environment

**Solutions**:
1. Use external USB mouse during installation
2. Check HP Support for Linux drivers
3. Update kernel after installation
4. Use distribution with newer kernel (Ubuntu 22.04+)

### Issue 7: WiFi Not Working

**Symptoms**: No wireless networks detected

**Solutions**:
1. Use wired connection during installation
2. Install proprietary drivers after installation:
   ```bash
   sudo ubuntu-drivers autoinstall
   ```
3. Download drivers on another computer and transfer
4. Check HP Support for Linux-compatible WiFi cards

### Issue 8: BIOS Locked/Password Protected

**Symptoms**: Cannot access BIOS settings

**Solutions**:
1. Contact HP Support with proof of ownership
2. BIOS password reset (may require HP service)
3. Try default passwords (rarely works)
4. Professional service may be required

## HP BIOS Updates

### Checking BIOS Version

1. Press **F10** during startup
2. Look at **Main** tab for version
3. Or in Windows: Run `msinfo32` → check BIOS Version

### Updating BIOS

**From Windows**:
1. Visit [HP Support](https://support.hp.com/)
2. Enter your product number
3. Download BIOS update
4. Run the installer
5. Follow instructions (don't interrupt!)

**From USB** (recommended):
1. Download BIOS update from HP Support
2. Extract to USB drive formatted as FAT32
3. Boot with USB inserted
4. Access **F10** BIOS setup
5. Look for **Update System BIOS** option
6. Select USB file and update

**Warning**: Never interrupt a BIOS update. Ensure laptop is plugged in.

## HP Recovery Options

### HP Cloud Recovery (If Available)

Some HP laptops support cloud recovery:
1. Press **F11** during startup
2. Select **Cloud Recovery**
3. Connect to internet
4. Follow on-screen instructions

**Note**: This downloads Windows recovery, not Linux.

### HP System Recovery

For Windows recovery (not Linux):
1. Press **F11** during startup
2. Select **System Recovery**
3. Follow prompts

## Recommended Linux Distributions for HP Laptops

### Best Overall: Ubuntu 22.04 LTS
- Excellent HP hardware support
- Large community
- Regular updates for 5 years

### Best for Older HP: Linux Mint
- Lightweight
- Windows-like interface
- Good driver support

### Best for Performance: Pop!_OS
- Optimized for laptops
- Excellent graphics support
- Gaming-ready

### Best for Privacy: Fedora
- Secure by default
- Latest software
- Good HP support

## Post-Installation HP Tips

### Install HP Linux Imaging and Printing (HPLIP)

For HP printers and scanners:
```bash
sudo apt install hplip hplip-gui
hp-setup
```

### Install HP System Tools

```bash
# For fan control
sudo apt install tlp tlp-rdw

# For battery management
sudo apt install laptop-mode-tools

# For touchpad
sudo apt install xserver-xorg-input-synaptics
```

### Optimize for HP Hardware

```bash
# Update all drivers
sudo ubuntu-drivers autoinstall

# Install firmware
sudo apt install linux-firmware

# Update kernel (if needed)
sudo apt install linux-generic-hwe-22.04
```

### HP Specific Tweaks

**Function Keys**:
Edit `/etc/default/grub`:
```bash
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash hpfall=0"
```
Then: `sudo update-grub`

**Fan Control**:
```bash
sudo sensors-detect
sudo pwmconfig
```

**Battery Life**:
```bash
sudo tlp start
sudo tlp-stat -b  # Check battery status
```

## HP Model-Specific Notes

### HP Spectre x360
- Requires `i915.enable_psr=0` kernel parameter
- Touchscreen works out-of-box on Ubuntu 22.04+
- Stylus requires calibration

### HP Omen (Gaming Laptops)
- Install proprietary NVIDIA drivers
- Use Pop!_OS for best gaming support
- May need `acpi_osi=! acpi_osi="Windows 2009"` parameter

### HP ZBook (Workstations)
- Excellent Linux support
- NVIDIA Quadro needs proprietary drivers
- Most features work out-of-box

## Support Resources

### HP Support
- Website: https://support.hp.com/
- Phone: 1-800-HP-INVENT (1-800-474-6836)
- Chat: Available on website

### Linux on HP Resources
- HP Linux Portal: https://developers.hp.com/hp-linux-imaging-and-printing
- Ubuntu HP Wiki: https://help.ubuntu.com/community/HardwareSupportComponentsPrintersHp
- HP Developer Portal: https://developers.hp.com/

### Community Support
- HP Community Forums: https://h30434.www3.hp.com/
- Reddit: r/HP_Laptop, r/linux4noobs
- Ubuntu Forums: https://ubuntuforums.org/

## Warranty and Support

**Important**: Installing Linux may void warranty in some regions. Check HP warranty terms.

**Best Practice**: 
1. Create Windows recovery media before installing Linux
2. Keep Windows partition if dual-booting
3. Document any BIOS changes
4. Keep proof of purchase

---

*This guide is community-maintained. For official HP support, visit https://support.hp.com/*
