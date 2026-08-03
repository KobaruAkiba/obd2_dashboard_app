# 🏎️ OBDII Car Monitor - Cross-Platform App

## Overview

Cross-platform application for monitoring vehicle OBDII diagnostic data from **Windows PC** and **Mobile devices**. Supports both:

- **Desktop (Windows)**: Direct CAN bus communication via USB-CAN adapters (PCAN/Kvaser)
- **Mobile**: Bluetooth serial to Soleilx OBDII scanner dongles

## 🎯 Features

### Core Functionality
- ✅ **Live Data Display** - Engine RPM, Vehicle Speed, Coolant Temp, Intake Air Temp
- ✅ **Battery Voltage Monitor** - Real-time system voltage display
- ✅ **Fuel Level Indicator** - Live fuel level tracking
- ✅ **Diagnostic Trouble Codes (DTC)** - Read and monitor OBDII error codes
- ✅ **Freeze Frame Data** - Capture vehicle state when DTCs are detected
- ✅ **Real CAN Bus Support** - PCAN/Kvaser USB-CAN adapters for Windows
- ✅ **Bluetooth Classic Serial Port** - Connect to Vgate/ELM327 OBD dongles on Windows ($35!)
- ✅ **Bluetooth BLE UART** - Connect to Soleilx and other Bluetooth OBD dongles on mobile
- ✅ **Virtual CAN Tools** - Use cantool.exe for testing without physical hardware
- ✅ **Windows Debug Mode Mocking** - Automatic mock data injection when no hardware available

### Platform Support
| Platform | Device Type | Communication | Baud Rate |
|----------|-------------|---------------|-----------|
| Windows | PCAN USB | CAN Bus (ISO-TP) | 500kbps / 1Mbps |
| Android | Bluetooth Dongle | Serial UART | 115200 |
| iOS | Bluetooth Dongle | Serial BLE | 115200 |

## 🛠️ Hardware Requirements

### For Desktop (Windows) - Multiple Options!

**Option 1: Professional CAN Bus**
- **PCAN-USB** adapter: https://pcan.com/en/products/pcan_usb.html (Recommended)
- **Kvaser USB-CAN** interface: https://www.kvaser.com/products/usb-can-bus-adapter/
- **Direct CAN transceiver** for vehicle ECU connection

**Option 2: Budget Bluetooth OBD Dongle**
- **Vgate v3.0/VLink MKII**: $35-$60 (https://www.vgate.co.uk/)
  - Dual interface: USB + Bluetooth Classic Serial Port
  - Works on Windows AND Android!
- **ELM327 Bluetooth adapter**: ~$40 with SPS support
- Connects via **Bluetooth Serial Port API** on Windows

**Option 3: Virtual CAN Tools (No Hardware)**
- **cantool.exe**: https://github.com/electrum/can-utils/releases/download/v0.6/cantool.exe
- Use for testing without physical hardware

### For Mobile (Android/iOS) - Bluetooth Mode
- **Soleilx Bluetooth OBDII Scanner**: Your specified dongle
  - Model: *Scanner Diagnostico Auto Multimarca*
  - Connection: Bluetooth Low Energy + UART
  - Compatible with most Android and iOS devices

## 📦 Installation & Setup

### 1. Prerequisites

```bash
# Install Flutter SDK
git clone https://github.com/flutter/flutter.git
export PATH="$PATH:$HOME/flutter/bin"

# Run in Windows PowerShell or Git Bash
flutter doctor

# Install project dependencies
cd obd_app
flutter pub get
```

### 2. Desktop (Windows) Setup

For **PCAN-USB** interface:

```bash
# Install PCAN drivers for Windows
# Download from https://pcan.com/en/downloads.html
# Then connect your USB-CAN adapter

# Add to AndroidManifest.xml if building APK with native libraries
<application>
  <meta-data android:name="pcan.path" android:value="/path/to/pcan/lib"/>
</application>
```

For **Kvaser** interface:

```bash
# Kvaser drivers are automatically detected on Windows
# Add to pubspec.yaml (optional)
dependencies:
  kvaser_wrapper: ^0.1.0
```

### 3. Mobile Setup

For your **Soleilx Bluetooth dongle**:

**Step 1: Pair the dongle with your device**

- Turn on your Android/iOS device's Bluetooth
- Enable "Developer Options" → "Always On Developer Mode" if needed
- Search for and pair with: `Scanner Diagnostico Auto Multimarca` or similar name
- Set connection preference to "Never Disconnect" if available

**Step 2: Connect via app**

```dart
// In the app, connect button will discover available Soleilx devices
// Default port: /dev/ttyS0 (Android) or Bluetooth COM (iOS)
// Default baud rate: 115200
```

### 4. Testing with Virtual CAN Bus

To test without physical hardware:

```bash
# Install virtual CAN bus software on Windows
# https://github.com/electrum/can-utils/releases/download/v0.6/cantool.exe
sudo apt install cantool # Linux

# Start virtual terminal
cantool -i can0 -b 500000 tx
```

## 🎨 Customization Options

### Changing Theme Colors

Edit `lib/main.dart`:

```dart
final themeColor = const Color(0xFF1A1A2E); // Deep dark blue
final accentColor = const Color(0xFF3A7BD5); // Primary accent
```

### Adding Additional PIDs

See `lib/obdii/pid_parser.dart` for available standard OBDII PIDs:

| PID | Data Description | Scale Factor |
|-----|------------------|---------------|
| 1 | Engine RPM | ×1 |
| 2 | Vehicle Speed | ÷3.6 (km/h) |
| 4 | Calculated Load | ÷256×2 (%) |
| 5 | Coolant Temperature | +40 (°C) |
| 6 | Intake Air Temperature | +40 (°C) |
| 7-8 | Short/Long Term Fuel Trim | ÷256×2 (%) |

## 🔧 Troubleshooting

### "Failed to connect" on Windows

1. **PCAN drivers not installed**: Download from PCAN website, install drivers first
2. **Interface name incorrect**: Check Device Manager → System Devices for PCAN/Kvaser
3. **Wrong baud rate**: Try 500000, 1000000, or 250000 for different vehicles
4. **No CAN adapter installed?**: The app automatically detects and provides a helpful message about installing one, or falls back to mock data for development!
5. **Use Virtual CAN Tools**: Install cantool.exe for testing without physical hardware

### "Device not found" on Mobile

1. **Bluetooth not pairing properly**: Try "Forget device" and pair again
2. **Wrong service UUID**: Some dongles use `0000110a` (Serial Port Service) or `0000ffe0` (Custom)
3. **Dongle in wrong mode**: Ensure it's set to OBDII diagnostic mode, not "Scan" mode

### Data stream not updating

- Check baud rate matches device settings (default: 115200 for Bluetooth)
- Verify CAN bus initialization: Some vehicles require 10-second warmup before querying
- Clear DTCs if vehicle enters fail-safe mode

#### Windows Debug Mode Mock Data

When running on Windows desktop in debug mode:
- The app automatically injects realistic mock ODB data (RPM, speed, temp, voltage)
- This allows UI testing without physical CAN adapter
- To use real CAN data: build for release or run with `--no-debug` flag

## 📱 Mobile Screenshots

![Main Screen](assets/screenshots/home.png)
*Live gauges with dark aesthetic theme*

![DTC Alert](assets/screenshots/dtc_alert.png)
*Diagnostic trouble code notifications*

## 🔐 Privacy & Data

- **No data is sent to servers** - All processing is local on your device
- **CAN bus traffic**: Only reads vehicle diagnostic data, no writes unless explicitly configured
- **Storage**: History/logs stored locally using SQLite (if enabled)

## 💻 VS Code Quick Tasks (Press `Ctrl+Shift+P` → "Tasks: Run Task")

**Current Setup**: Cross-Platform with Real Hardware Support! ✅

| Task | What It Does | Status |
|------|---------------|--------|
| **🖥️ Run Windows Desktop App** | Builds and runs on your PC with CAN/Bluetooth support | ✅ Ready to use! |
| **📱 Run Mobile App** | Builds and runs for Android/iOS with BLE OBD dongles | ✅ Ready when paired |
| **🧹 Clean & Rebuild** | Clears cache, rebuilds app | ✅ Useful after code changes |
| **📦 Install Dependencies** | Installs project packages | ✅ Run once per session |
| **🔌 Real CAN Bus Mode** | Force real PCAN/Kvaser (requires adapter) | ⚙️ Use with --dart-define flag |
| **📶 Bluetooth Serial Mode** | Force Vgate/ELM327 Bluetooth on Windows | ⚙️ Use `windows-bluetooth-serial` flag |
| **💻 Mock Data Mode** | Force mock data for development/testing | ⚙️ Default on Windows without hardware |

### Quick Command Examples:

```bash
# Auto-detect (default - tries CAN first, then Bluetooth, then mock)
flutter run

# Use Bluetooth Serial Port OBD dongle on Windows
flutter run --dart-define=OBD_SERVICE_TYPE=windows-bluetooth-serial

# Use real CAN bus with PCAN/Kvaser adapter
flutter run --dart-define=OBD_SERVICE_TYPE=windows-can-bus

# Mock data for development (no hardware needed)
flutter run --dart-define=OBD_SERVICE_TYPE=mock-windows
```

### Quick Start (Easiest Method):

1. Press `Ctrl+Shift+P` in VS Code
2. Type: "Tasks: Run Task"
3. Select: "🖥️ Run Windows Desktop App"
4. Done! - App will build and launch automatically ✅

### Alternative Command Line:
```bash
cd E:/HOME/Repos/obd_app
flutter run
```

### Real Hardware Mode (if you have CAN adapter):
```bash
flutter run --dart-define=OBD_SERVICE_TYPE=windows-can-bus
```

### Mock Data Mode (for testing without hardware):
```bash
flutter run --dart-define=OBD_SERVICE_TYPE=mock-windows
```

## 📄 License

MIT License - See LICENSE file for details.

## 🎯 Development Status

- ✅ Core OBDII data reading working
- ✅ Cross-platform UI implemented  
- ✅ Real CAN bus support (PCAN/Kvaser) - Ready for Windows!
- ✅ **Bluetooth Classic Serial Port** - Vgate/ELM327 dongles on Windows! 🆕
- ✅ Bluetooth BLE UART for mobile OBD dongles
- ✅ Virtual CAN tools integration (cantool.exe)
- ✅ Auto-detection of hardware and fallback to mock data
- ✅ Windows debug mode mock data injection (no CAN adapter required for testing!)
- ⏳ Data history/logging feature
- ⏳ CSV export for offline analysis

---

**For technical support**: Contact the project maintainer  
**Documentation**: See [docs/](../docs/) for detailed API reference
