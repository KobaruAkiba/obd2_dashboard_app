# 📶 Windows Bluetooth Serial OBD Setup Guide

This guide explains how to connect the app to **Bluetooth Classic** OBD dongles on **Windows**, not BLE (Bluetooth Low Energy).

## 🎯 What This Feature Does

The app now supports connecting to **classic Bluetooth OBD dongles** using Windows' **Bluetooth Serial Port API**. This is different from mobile BLE support - it uses the same virtual serial port technology that Android/iOS use for Bluetooth dongles, but on Windows.

### Compatible Devices (Windows)
- ✅ **Vgate v3.0** / **VLink MKII** - Most popular Windows OBD dongle
- ✅ **ODBLINK Pro** - Dual interface (USB + Bluetooth)
- ✅ **ELM327 Bluetooth adapters** - SPS-enabled models
- ✅ **AutoCom Bluetooth** scanners
- ✅ **ThinkDiag BT** adapters
- ✅ Any Bluetooth dongle with **Serial Port Profile (SPS)** support

### NOT Compatible (Windows)
- ❌ Pure BLE-only dongles (like Soleilx on mobile)
- ❌ HID-mode OBD dongles (keyboard-emulation)
- ❌ Android/iOS-exclusive dongles

---

## 📦 Installation Steps

### Step 1: Get a Bluetooth OBD Dongle

**Recommended:** Vgate v3.0 or VLink MKII
- Price: $35-$60 USD
- Website: https://www.vgate.co.uk/
- Features: Bluetooth + USB dual interface, SPS support

**Alternative:** Any ELM327 Bluetooth adapter with SPS protocol

### Step 2: Pair the Dongle with Windows

1. **Turn on your dongle** (usually a power button)
2. **Windows Bluetooth Settings**:
   - Open **Settings** → **Devices** → **Bluetooth & other devices**
   - Toggle Bluetooth **ON**
3. **Add Device**:
   - Click **"Add Bluetooth or other device"**
   - Select **"Bluetooth"**
   - Your dongle should appear in the list (e.g., "Vgate", "ELM327 BT")
4. **Pair**:
   - Click on the device name
   - Windows will ask for pairing code (usually `0000` or `1234`)
   - Confirm the pairing

### Step 3: Verify Bluetooth Serial Port is Available

Open **Device Manager**:
- Press `Win + X` → Select **Device Manager**
- Look under **"Ports (COM & LPT)"** section
- You should see entries like:
  ```
  Vgate v3.0 - HS
  ELM327 Bluetooth Adapter
  OBDLink EX Serial Port
  ```

If you don't see it, the dongle is not properly paired or doesn't support SPS protocol.

### Step 4: Run the App with Bluetooth Mode

**Option A: Automatic Detection (Recommended)**
```bash
flutter run
```
The app will automatically detect your Bluetooth OBD dongle and connect!

**Option B: Force Bluetooth Serial Mode**
```bash
flutter run --dart-define=OBD_SERVICE_TYPE=windows-bluetooth-serial
```

---

## 🚀 Quick Start Commands

### Auto-Detect Mode (Default)
```bash
# App will auto-detect hardware and use appropriate service
flutter run
```

On Windows:
- Has PCAN/Kvaser adapter? → Use CAN bus
- Has Bluetooth OBD dongle? → Use Bluetooth Serial Port
- Neither? → Use mock data for development

### Force Bluetooth Mode
```bash
# Explicitly force Bluetooth Serial Port mode
flutter run --dart-define=OBD_SERVICE_TYPE=windows-bluetooth-serial

# Or set environment variable
$env:OBD_SERVICE_TYPE='windows-bluetooth-serial'
flutter run
```

### Mock Data Mode (No Hardware)
```bash
# Keep using mock data for development
flutter run --dart-define=OBD_SERVICE_TYPE=mock-windows
```

---

## 📱 Cross-Platform Behavior

| Platform | Has CAN Adapter? | Has BT OBD Dongle? | Default Mode |
|----------|------------------|--------------------|--------------|
| **Windows** | ✅ Yes | ❌ No | Real CAN bus |
| **Windows** | ❌ No | ✅ Yes | Bluetooth Serial Port ✅ |
| **Windows** | ❌ No | ❌ No | Mock data (development) |
| **Android** | N/A | ✅ Paired dongle | Real BLE UART |
| **iOS** | N/A | ✅ Paired dongle | Real BLE UART |

### The App Is Smart! 🧠

On Windows, the app will:
1. Check for physical CAN adapter → Use real CAN bus
2. If no CAN adapter, check for Bluetooth OBD dongle → Use Serial Port API
3. If neither → Use mock data automatically (for development!)

This means you can develop and test on Windows **without buying any hardware** first!

---

## 🔧 Troubleshooting

### "Bluetooth connection failed" 

1. **Check pairing**: Open Device Manager → Ports (COM & LPT)
   - If you don't see the dongle there, it's not properly paired
   
2. **Restart Bluetooth Stack**:
   ```powershell
   # Open PowerShell as Admin and run:
   Stop-BluetoothService
   Start-Sleep -Seconds 2
   Start-BluetoothService
   ```

3. **Remove and re-pair** the dongle in Windows Settings

### "Data shows all zeros"

1. **Wait for warmup**: Some vehicles need 5-10 seconds after connection
2. **Check baud rate**: Default is 115200 bps (standard)
3. **Try different PIDs**: Start with RPM (PID 1) and Speed (PID 2)

### Dongle doesn't appear in Bluetooth devices

1. **Power cycle**: Turn off dongle, wait 10 seconds, turn back on
2. **Check compatibility**: Make sure it supports Serial Port Profile (SPS), not just HID mode
3. **Try different dongle**: Vgate is most reliable on Windows

---

## 📊 Bluetooth vs BLE vs CAN Comparison

| Feature | CAN Bus | Bluetooth Serial | BLE UART |
|---------|---------|------------------|----------|
| **Windows** | ✅ PCAN/Kvaser | ✅ SPS API | ❌ Not supported |
| **Android** | N/A | ✅ Legacy | ✅ Modern (BLE) |
| **iOS** | N/A | ✅ Legacy | ✅ Modern (BLE) |
| **Dongle Type** | USB-CAN adapter | Classic Bluetooth | BLE-only dongle |
| **Best For** | Professional diagnostics | Budget-friendly testing | Mobile-first apps |
| **Price** | $80-$200 | $35-$60 | $25-$50 |

### When to Use Which:

- **CAN Bus**: Professional work, need precise timing, Linux/Windows cross-platform
- **Bluetooth Serial**: Windows + Android compatibility, budget-friendly dongles (Vgate)
- **BLE UART**: iOS only or mobile-first development (Soleilx dongle)

---

## 💻 Configuration Options

### Environment Variables

| Variable | Default | Description | Values |
|----------|---------|-------------|--------|
| `OBD_SERVICE_TYPE` | auto | Force specific service | `windows-can-bus`, `windows-bluetooth-serial`, `ble-uart`, `mock-windows` |
| `BT_DONGLE_TYPE` | auto | Specific dongle type | `SPS`, `OBDEX`, or empty for auto-detect |

### Command Line Examples

```bash
# Windows + Bluetooth OBD dongle (auto-detect)
flutter run

# Force Bluetooth Serial Port mode on Windows
flutter run --dart-define=OBD_SERVICE_TYPE=windows-bluetooth-serial

# Windows + Vgate v3.0 specifically  
flutter run --dart-define=BT_DONGLE_TYPE=SPS

# Mock data for development (no hardware needed)
flutter run --dart-define=OBD_SERVICE_TYPE=mock-windows

# Auto-detect with Bluetooth preference on Windows
flutter run --dart-define=USE_BLUETOOTH_OBD=true
```

---

## 📞 Support Resources

- **Vgate Official**: https://www.vgate.co.uk/support/
- **ELM327 Forum**: https://elm-chan.org/forum/
- **Bluetooth Serial Port API**: https://docs.microsoft.com/windows/win32/devguide/bthserial-port-profile
- **Windows Bluetooth Stack**: https://docs.microsoft.com/windows-hardware/drivers/bluetooth

---

## ✅ Summary: What You Can Do Now!

### On Windows, the app supports:
- ✅ Real CAN bus (PCAN/Kvaser) - Professional grade
- ✅ Bluetooth Serial Port (Vgate/ELM327) - Budget-friendly, $35-$60 dongles
- ✅ Virtual CAN tools (cantool.exe) - Testing without hardware
- ✅ Mock data - Development and demos

### Cross-platform compatibility:
- **Windows**: CAN bus OR Bluetooth Serial OR mock data
- **Android**: BLE UART (real) OR mock data  
- **iOS**: BLE UART (real) OR mock data

### The app is now truly universal! 🌍

You can:
1. Develop on Windows without hardware (mock data)
2. Test with budget Bluetooth dongle on Windows ($35 Vgate)
3. Use professional CAN adapter for production work
4. Deploy to mobile with BLE support
5. All in the same app, all platforms!

---

**Last Updated**: 2024-07-20  
**Author**: OBDII Monitor Team
