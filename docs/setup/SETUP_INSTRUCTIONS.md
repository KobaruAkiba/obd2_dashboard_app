# 🚀 OBDII Monitor - Quick Setup Guide

## ✅ Prerequisites Checklist

### For Windows PC (Desktop Mode)

1. **Install Flutter SDK**
   ```powershell
   # PowerShell
   git clone https://github.com/flutter/flutter.git
   $env:PATH = "$env:PATH;$env:USERPROFILE\flutter\bin"
   flutter doctor
   
   # OR using Git Bash
   git clone https://github.com/flutter/flutter.git
   export PATH="$PATH:$HOME/flutter/bin"
   flutter doctor
   ```

2. **Install PCAN Drivers (for CAN bus)**
   - Download from: https://pcan.com/en/downloads.html
   - Install drivers, restart PC after installation
   - Connect your USB-CAN adapter

3. **Get dependencies**
   ```powershell
   cd obd_app
   flutter pub get
   ```

### For Mobile (Android with Soleilx Bluetooth)

1. **Install Flutter SDK** (same as above)

2. **Get dependencies**
   ```bash
   cd obd_app
   flutter pub get
   flutter config --enable-linux-desktop  # Optional for testing on Linux too
   flutter config --enable-windows-desktop
   flutter config --enable-web
   ```

3. **Build for Android** (first time only)
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   flutter build apk --debug
   # or for release build
   flutter build apk --release
   ```

4. **Install on device via USB**
   ```bash
   flutter devices
   flutter run
   ```

---

## 📱 Soleilx Bluetooth Dongle Setup

### Step 1: Pair the dongle with your device

**On Android:**
```
Settings → Connect to a device or hotspot → Other devices
→ Scan for "Scanner Diagnostico Auto Multimarca"
→ Pair and accept connection request
```

**Important settings:**
- **Connection preference**: Select "Never Disconnect" if available
- **Keep screen on**: Recommended while monitoring
- **Bluetooth visibility**: Should be discoverable initially

### Step 2: Connect via app

1. Open the OBDII Monitor app
2. Click "Connect" button
3. App will auto-discover your paired Soleilx device
4. Connection uses:
   - MAC address from pairing
   - Bluetooth Serial Profile
   - Default baud rate: 115200 bps

---

## 🎮 First Run Test

### Quick test sequence

1. **Connect to OBDII source**
   ```
   Desktop: Click "Connect" → Select PCAN interface
   Mobile: Click "Connect" → App finds Soleilx device
   ```

2. **Wait for vehicle warmup (10 seconds minimum)**
   - Modern vehicles require 10-second initialization before queries

3. **Check data stream**
   - You should see RPM value updating in top-left gauge
   - Battery voltage around 13-14V at idle
   - Coolant temp below 90°C for normal engine

4. **Troubleshooting indicators**
   ```
   ✗ Shows "Connected" but no data: Check baud rate, restart app
   ✓ Green status bar + live RPM: Working correctly!
   ⚠️ Red DTC panel: Vehicle has stored error codes
   ```

---

## 📊 Viewing Different PIDs

The app shows these standard OBDII parameters:

| Display | PID Code | What it Shows |
|---------|----------|---------------|
| RPM Gauge | $01 01 | Engine revolutions per minute |
| Speed Gauge | $02 02 | Vehicle speed (km/h ÷3.6 = mph) |
| Coolant Temp | $05 05 | Engine coolant temperature +40 offset |
| Intake Air Temp | $06 06 | Throttle body air temp +40 offset |
| Battery Voltage | $2F | System voltage (13-14V normal) |

To add custom PIDs, edit `lib/obdii/pid_parser.dart`.

---

## 🔧 Troubleshooting Common Issues

### "Cannot find PCAN interface"

```powershell
# Check if PCAN driver installed
Get-PnpDevice | Where-Object {$_.FriendlyName -like "*PCAN*"}

# If not listed, install drivers from PCAN website
```

### "Bluetooth connection timed out"

1. Ensure Bluetooth is ON in device settings
2. Re-pair the Soleilx dongle
3. Check app has Bluetooth permissions (Settings → Apps → OBDII Monitor → Permissions)
4. On Android 13+: Grant location permission for BLE scanning

### "Data not updating after connection"

1. Close and reopen app to reinitialize stream
2. Verify baud rate: Open device settings, check COM port properties = 115200 bps
3. Check vehicle state: Some ECUs need mode $09 (tester ready) before responding

### "RPM shows 0" but other values present

- Vehicle may be in idle or stopped mode
- Engine needs to run above ~500 RPM for reliable reading
- Check for freeze frame data in DTC panel if codes detected

---

## 🎨 Customization Quick Reference

### Change App Theme Color

```dart
// In lib/main.dart, line 3
final themeColor = const Color(0xFF1A1A2E); // Deep blue
```

### Set Different Baud Rate for PCAN

```dart
// Windows wrapper, connectToPCan function:
connectToPcan(baudRate: 500000) // Change from default 1000000
```

---

## 📖 Next Steps After Setup

1. **Explore PID Parser**: Modify `lib/obdii/pid_parser.dart` to add custom formulas
2. **Check DTCs**: Look at Diagnostic Trouble Codes panel for vehicle health alerts
3. **Historical Data**: Enable data logging (coming in next release)
4. **Export to CSV**: Save session data for analysis (future feature)

---

## 🆘 Getting Help

- **Documentation**: See [README.md](README.md) for full API reference
- **Flutter issues**: Check Flutter documentation at https://flutter.dev/docs
- **PCAN/Kvaser drivers**: Visit vendor websites for latest releases

Happy monitoring! 🏎️
