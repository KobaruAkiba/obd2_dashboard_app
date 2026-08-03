# 🔄 Migrate from Mock to Real ODB Data

## Current Status: Mock Mode (Default on Windows)

By default, when running on Windows without a physical CAN adapter, the app uses **mock data** to demonstrate the UI and functionality. This is perfect for development and testing!

## Ready for Real Hardware! 🚀

The app has been updated with full support for real ODBII connections:

✅ **Windows PCAN/Kvaser CAN Bus** - Direct ISO-TP communication  
✅ **Android/iOS Bluetooth BLE UART** - Connect to OBD dongles  
✅ **Virtual CAN tools** - Use cantool.exe for development  
✅ **Auto-detection** - Automatically chooses the right service  

---

## Switching to Real Hardware Mode

### Option 1: Install Physical CAN Adapter (Windows)

```bash
# Step 1: Get PCAN-USB adapter
https://pcan.com/en/products/pcan_usb.html

# Step 2: Install drivers from official site
https://pcan.com/en/downloads.html

# Step 3: Connect adapter and verify in Device Manager

# Step 4: Run app - it will auto-detect!
flutter run
```

### Option 2: Use Virtual CAN Tools (Windows)

```bash
# Install cantool.exe virtual CAN bus
https://github.com/electrum/can-utils/releases/download/v0.6/cantool.exe

# Copy to your system path or specify in environment variable
Set-EnvironmentVariable VIRTUAL_CAN_TOOL "C:/Program Files/can-utils/cantool.exe"

# Run app with virtual CAN mode
flutter run --dart-define=OBD_SERVICE_TYPE=windows-can-bus
```

### Option 3: Connect Bluetooth OBD Dongle (Mobile)

```bash
# Pair your Soleilx or other BLE dongle first
# Settings → Bluetooth → Pair device

# Run app - it will auto-detect your dongle!
flutter run
```

---

## Configuration Options

### Force Real Hardware Mode

```bash
# Windows with physical CAN adapter
flutter run --dart-define=OBD_SERVICE_TYPE=windows-can-bus

# Mobile with Bluetooth OBD dongle  
flutter run --dart-define=OBD_SERVICE_TYPE=ble-uart

# Auto-detect (default)
flutter run  # Uses real hardware if available, mock if not
```

### Force Mock Data Mode (Development)

```bash
# Keep using mock data for testing
flutter run --dart-define=OBD_SERVICE_TYPE=mock-windows
```

---

## What You'll See in the App UI

| Status | Description | When It Appears |
|--------|-------------|-----------------|
| **🟢 Real Hardware Connected** | Actual ODBII data from your vehicle | Physical adapter or dongle connected |
| **🟡 Mock Data Mode** | Simulated data for testing | No hardware available (Windows default) |
| **🔴 Connection Failed** | Could not connect to hardware | Drivers missing, Bluetooth not paired, etc. |

---

## Real vs Mock Comparison

### Real CAN Bus Data
- ✅ Actual vehicle sensor readings
- ✅ Accurate RPM, speed, voltage from ECU
- ✅ Real OBDII DTC codes (if any)
- ✅ Live freeze frame data
- ⚠️ May show 0s during cold start

### Mock Data Mode
- ✅ Perfectly stable for UI testing  
- ✅ Never shows connection errors
- ✅ Consistent RPM/speed values
- ⚠️ Not representative of real vehicle data
- ⚠️ Good for demos but not diagnostics

---

## Quick Test: Check Your Hardware Status

Run this in the app console to see what hardware is detected:

```bash
flutter run --verbose 2>&1 | grep -E "SERVICE|CAN-BUS|BLE-ODB"
```

Expected output examples:

**Real CAN Bus Detected:**
```
[SERVICE] Using REAL CAN Bus - Physical adapter detected
[CAN-BUS] Connected to PCAN interface: PCAN-USB
```

**Virtual CAN Mode:**
```
[SERVICE] No physical CAN adapter - falling back to virtual CAN  
[CAN-BUS] Connected to virtual CAN interface: \Device\CAN0
```

**Bluetooth OBD Dongle:**
```
[BLE-ODB] Connecting to: XX:XX:XX:XX:XX:XX (Baud: 115200)
[SERVICE] Successfully connected with real hardware
```

**Fallback to Mock:**
```
[SERVICE] Using mock data for development
[WINDOWS] Injecting mock ODB data for Windows desktop...
```

---

## Troubleshooting Real Hardware Mode

### "No physical CAN adapter found" (Windows)

1. Check Device Manager for PCAN/Kvaser entry
2. Install drivers from https://pcan.com/en/downloads.html
3. Restart computer after driver installation
4. Try virtual CAN tools as alternative

### "Bluetooth connection failed" (Mobile)

1. Forget device in Bluetooth settings and re-pair
2. Enable location permissions (Android 13+)
3. Verify dongle is in OBDII mode, not "Scan" mode
4. Check app has Bluetooth permission granted

### Data shows unrealistic values

1. Wait for vehicle warmup period (~10 seconds)
2. Clear any DTC codes if ECU enters fail-safe mode
3. Check baud rate matches device settings (115200 default)
4. Verify correct service UUID for your dongle

---

## Next Steps After Setup

1. **Explore PID Parser**: Add custom OBDII parameters in `lib/obdii/pid_parser.dart`
2. **Check DTCs**: View Diagnostic Trouble Codes panel for vehicle health alerts  
3. **Data Logging**: Enable history/logging to track sensor trends over time
4. **Export to CSV**: Save session data for offline analysis (future feature)

---

## For Technical Support

- **PCAN Official Support**: support@pcan.com
- **Kvaser Support**: support@kvaser.com  
- **Flutter Bluetooth Issues**: https://github.com/shaunhalliday/flutter_blue_plus/issues
- **OBDII Protocol Questions**: Consult vehicle service manual or OBDII standard SAE J1979

---

## Summary

The app now supports **both real and mock data**!

- 🎯 **Development**: Use mock data automatically on Windows (no hardware needed)
- 🚀 **Production**: Install PCAN/Kvaser adapter for real vehicle diagnostics  
- 📱 **Mobile**: Pair Bluetooth OBD dongle for cross-platform OBD monitoring
- ⚙️ **Virtual CAN**: Use cantool.exe for testing without physical hardware

Choose the mode that best fits your current development stage!
