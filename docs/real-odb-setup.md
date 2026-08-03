# Real ODB Connection Setup Guide 🚗

This guide explains how to configure the app to connect to real OBDII hardware instead of using mock data.

## 📋 Quick Reference Table

| Platform | Hardware Type | Adapter Required | Setup Difficulty |
|----------|---------------|------------------|------------------|
| **Windows** | PCAN-USB | ✅ Required | ⭐⭐⭐ Easy |
| **Windows** | Kvaser USB | ✅ Required | ⭐⭐ Easy |
| **Windows** | Virtual CAN (cantool) | ❌ Optional | ⭐ Very Easy |
| **Android** | Bluetooth OBD dongle | ✅ Required | ⭐ Very Easy |
| **iOS** | Bluetooth OBD dongle | ✅ Required | ⭐⭐ Easy |

---

## 🖥️ Windows PCAN/Kvaser Setup

### Prerequisites

1. **PCAN-USB Adapter** (recommended): https://pcan.com/en/products/pcan_usb.html
2. **Kvaser USB-CAN Adapter**: https://www.kvaser.com/products/usb-can-bus-adapter/

### Installation Steps

#### Step 1: Install Drivers

**For PCAN:**
```powershell
# Download from official site
https://pcan.com/en/downloads.html

# Run installer (requires admin privileges)
Install-PcanDrivers.ps1
Restart-Computer
```

**For Kvaser:**
```powershell
# Download from official site  
https://www.kvaser.com/support/downloads/drivers/

# Install and restart
Install-KvaserDrivers.ps1
Restart-Computer
```

#### Step 2: Connect Adapter

Plug your USB-CAN adapter into the PC. Windows will auto-detect and install drivers.

Verify installation:
```powershell
Get-PnpDevice | Where-Object {$_.Class -eq "CAN-Bus"}
```

Expected output:
```
Compatible : True
DeviceID   : PCI\VEN_8087&DEV...
DisplayName : PCAN-USB v4.3
FriendlyName : PCAN USB v4.3
HardwareID : ...
Status : Code 0 (No error)
```

#### Step 3: Verify CAN Bus Interface

Open Windows Device Manager → System Devices → Look for "PCAN" or "Kvaser" entries.

---

## 🔌 Virtual CAN Tools (Windows Development)

If you want to test with real CAN protocol but no physical hardware, use virtual CAN tools:

### Install cantool.exe

```powershell
# Download from official GitHub
https://github.com/electrum/can-utils/releases/download/v0.6/cantool.exe

# Copy to your system path (or specify full path in app)
Copy-Item -Path "C:\Downloads\cantool.exe" -Destination "C:\Program Files\can-utils\"
```

### Configure Virtual CAN Mode

Add to environment variables:
```powershell
[System.Environment]::SetEnvironmentVariable(
    'VIRTUAL_CAN_TOOL',
    'C:/Program Files/can-utils/cantool.exe'
)
```

---

## 📱 Android/iOS Bluetooth OBD Setup

### Hardware Requirements

- **Soleilx Bluetooth OBDII Scanner** (recommended)
- Any BLE-enabled OBD dongle with UART support

### Pairing the Dongle

#### On Android:
```
Settings → Bluetooth → "Pair device" → Select your dongle
→ Accept pairing request
→ Set to "Never disconnect" if option available
```

#### On iOS:
```
Settings → Bluetooth → Tap dongle name → Connect
→ Enable "Keep connected" in settings
```

### Connection Details

| Parameter | Value | Notes |
|-----------|-------|-------|
| Service UUID | `0xFFF0` (Soleilx) or `0000110a` | Check dongle docs |
| Baud Rate | `115200` bps | Standard for BLE UART |
| Protocol | BLE + UART | GATT profile over Bluetooth LE |

---

## 🚀 Configuration Options

### Environment Variables

Set these to configure behavior:

| Variable | Default | Description |
|----------|---------|-------------|
| `OBD_SERVICE_TYPE` | auto | Force service: `windows-can-bus`, `ble-uart`, `mock-windows`, `mock-mobile` |
| `VIRTUAL_CAN_TOOL` | auto | Full path to cantool.exe for virtual CAN testing |
| `DEBUG` | false | Enable debug logging |

### Command Line Flags

```bash
# Force mock mode (for development)
flutter run --dart-define=OBD_SERVICE_TYPE=mock-windows

# Force real CAN bus on Windows
flutter run --dart-define=OBD_SERVICE_TYPE=windows-can-bus

# Force BLE UART on mobile
flutter run --dart-define=OBD_SERVICE_TYPE=ble-uart
```

---

## 🔧 Troubleshooting

### "No physical CAN adapter found" (Windows)

1. **Check Device Manager**: Ensure PCAN/Kvaser appears in System Devices
2. **Restart Drivers**: Run `Get-PnpDevice -Class "CAN-Bus" | Refresh-Instance`
3. **Install Latest Drivers**: Visit https://pcan.com/en/downloads.html

### "Bluetooth connection timed out" (Mobile)

1. **Forget device** in Bluetooth settings and re-pair
2. **Check permissions**: Settings → App → Permissions → Location/Bluetooth
3. **Android 13+**: Grant location permission for BLE scanning
4. **Verify dongle is in OBDII mode**, not "Scan" mode

### Data not updating after connection

1. **Close and reopen app** to reinitialize stream
2. **Check baud rate** matches device settings (default: 115200 bps)
3. **Wait for warmup**: Some vehicles need ~10 seconds initialization
4. **Try different PIDs**: Start with PID 1 (RPM) and PID 2 (Speed)

---

## 📊 Hardware Detection Flow

The app automatically detects hardware in this order:

1. **Check environment variable** `OBD_SERVICE_TYPE`
2. **Windows PCAN/Kvaser adapter** detected? → Use real CAN bus
3. **Virtual CAN tool** available? → Use virtual CAN mode  
4. **Mobile Bluetooth** available? → Use real BLE service
5. **Fallback to mock data** for development/testing

---

## 🎯 Testing Without Hardware

### Windows Development Mode

The app will automatically inject realistic mock ODB data on Windows when no physical adapter is detected. This allows:

- ✅ UI testing without hardware
- ✅ Rapid development iteration  
- ✅ Feature validation before hardware purchase

### Enable Mock Data Manually

```bash
# Force mock data mode
flutter run --dart-define=OBD_SERVICE_TYPE=mock-windows
```

---

## 📞 Support Resources

- **PCAN Official**: https://pcan.com/support/
- **Kvaser Official**: https://www.kvaser.com/support/
- **Flutter Bluetooth**: https://github.com/shaunhalliday/flutter_blue_plus
- **BLE UART Protocol**: https://www.bluetooth.com/specifications/assigned-numbers/gatt-defined-characteristics/

---

## 🔄 Version History

| Version | Feature | Notes |
|---------|---------|-------|
| 1.0.0+1 | Mock data only | Development version |
| 1.1.0+2 | Real CAN bus support | PCAN/Kvaser ready! |
| 1.1.0+3 | Virtual CAN tools | cantool.exe integration |

---

**Last Updated**: 2024-07-20  
**Author**: OBDII Monitor Team
