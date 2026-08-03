# 🚀 Quick Reference Card - OBDII Monitor

## Current App Status

```
✅ Real CAN Bus Support: PCAN/Kvaser adapters (Windows)
✅ Real BLE UART Support: Bluetooth OBD dongles (Android/iOS)
✅ Virtual CAN Tools: cantool.exe integration (Windows testing)
✅ Auto-Detection: Smart hardware discovery
✅ Mock Data Fallback: Development without hardware
```

---

## 📋 Quick Command Reference

### Run App - Default Behavior (Auto-Detect)

```bash
flutter run  # Uses real hardware if available, mock otherwise
```

### Force Real CAN Bus (Windows + Physical Adapter Required)

```bash
flutter run --dart-define=OBD_SERVICE_TYPE=windows-can-bus
```

### Force Real BLE UART (Mobile Bluetooth Dongle)

```bash  
flutter run --dart-define=OBD_SERVICE_TYPE=ble-uart
```

### Force Mock Data Mode (Windows Development)

```bash
flutter run --dart-define=OBD_SERVICE_TYPE=mock-windows
```

---

## 🛠️ Hardware Setup Quick Guide

| Platform | Adapter | Setup Command |
|----------|---------|---------------|
| Windows + PCAN | `pcan_usb` driver installed | `flutter run` (auto-detect) |
| Windows + Kvaser | `kvaser` driver installed | `flutter run` (auto-detect) |
| Android/iOS + Dongle | Bluetooth paired | `flutter run` (auto-detect) |
| Windows Virtual CAN | `cantool.exe` configured | `flutter run --dart-define=VIRTUAL_CAN_TOOL="C:\...\cantool.exe"` |

---

## 🔍 What You'll See in the App

### Real Hardware Connected ✅

```
🟢 Real Hardware Connected
📡 Service Information: Real CAN Bus / BLE UART
[CAN-BUS] Connected to PCAN interface: PCAN-USB v4.3
[SERVICE] Successfully connected with real hardware
```

### Mock Data Mode 🟡

```
🟡 Mock Data Mode  
💻 Windows Development Mode - No hardware detected
[WINDOWS] Injecting mock ODB data for Windows desktop...
```

### Connection Failed 🔴

```
🔴 Connection Failed
Please install PCAN drivers or pair Bluetooth dongle
```

---

## 🎯 Hardware Detection Flow (Auto-Select)

```
Step 1: Check OBD_SERVICE_TYPE environment variable
    └─> If set → Use that service type
    
Step 2: Windows platform?
    └─> Has physical PCAN/Kvaser adapter?
        ├─> YES → Use REAL CAN bus service
        └─> NO → Fall back to mock data
        
Step 3: Mobile platform?  
    └─> Has paired Bluetooth dongle?
        ├─> YES → Use REAL BLE UART service
        └─> NO → Use mock data for development

Result: App always shows some data! Never crashes.
```

---

## 📊 Real vs Mock Data Comparison

| Feature | Real Hardware | Mock Data |
|---------|---------------|-----------|
| RPM Values | ✅ Actual vehicle data | ✅ Simulated values |
| Speed Reading | ✅ Real-time ECU data | ✅ Simulated driving |
| DTC Codes | ✅ Real vehicle errors | ⚠️ Randomly generated occasionally |
| Fuel Level | ✅ Actual fuel rail reading | ✅ Fixed at 100% (simulated) |
| Battery Voltage | ✅ Real system voltage | ✅ Realistic range (12-14V) |
| Use Case | Production diagnostics | UI testing, demos, development |

---

## 🐛 Common Issues & Quick Fixes

### "No physical CAN adapter found" (Windows)

**Quick Fix**: Install PCAN drivers first
```bash
# Get drivers from: https://pcan.com/en/downloads.html
# Install and restart computer, then run app again
```

### "Bluetooth connection timed out" (Mobile)

**Quick Fix**: Re-pair the dongle
```bash
# Settings → Bluetooth → Forget device → Pair again
# Then run: flutter run
```

### Data not updating after connection

**Quick Fix**: Close and reopen app
```bash
# App needs to reinitialize stream
flutter run  # Relaunches with fresh connection
```

---

## 📱 Platform Support Table

| Platform | Real CAN Bus | Real BLE UART | Mock Data | Auto-Detect |
|----------|--------------|----------------|-----------|-------------|
| Windows | ✅ PCAN/Kvaser | ❌ N/A | ✅ Default | ✅ YES |
| Android | ❌ N/A | ✅ Bluetooth dongles | ⚠️ Optional | ✅ YES |
| iOS | ❌ N/A | ✅ Bluetooth dongles | ⚠️ Optional | ✅ YES |

---

## 🎓 Key Documentation Files

| File | Purpose | When to Read |
|------|---------|--------------|
| `docs/real-odb-setup.md` | Detailed hardware setup guide | Setting up first time |
| `docs/migration-real-odb.md` | Mock → Real migration guide | Understanding modes |
| `docs/CHANGES.md` | Implementation summary | Technical deep dive |
| `docs/QUICK_REFERENCE.md` | This file! | Daily reference |

---

## 🚀 Quick Start Checklist

### First Time Setup (Windows + PCAN)

- [ ] Install Flutter SDK
- [ ] Install PCAN drivers from official site
- [ ] Connect PCAN-USB adapter to PC
- [ ] Run `flutter pub get`
- [ ] Run `flutter run`
- [ ] App should auto-detect and show real data! ✅

### Development Testing (No Hardware)

- [ ] Run `flutter run --dart-define=OBD_SERVICE_TYPE=mock-windows`
- [ ] App shows mock data immediately
- [ ] Perfect for UI testing and development!

---

## 📞 Support Links

- **PCAN Official**: https://pcan.com/
- **Kvaser Official**: https://www.kvaser.com/
- **Flutter Docs**: https://flutter.dev/docs
- **BLE UART Protocol**: https://www.bluetooth.com/specifications/gatt-defined-characteristics/

---

**Tip**: The app is designed to **never crash** - it will always fall back to mock data on Windows if no hardware is found, allowing you to develop and test the UI immediately without waiting for physical hardware!
