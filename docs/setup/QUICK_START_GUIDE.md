# 🚀 Quick Start Guide - OBDII Monitor

## ✅ Prerequisites Checklist

Before running the setup script, ensure you have:

- [ ] **Windows 10/11** (or macOS/Linux)
- [ ] **Git Bash** installed on Windows (if using Git Bash)
- [ ] **Admin rights** for installing software
- [ ] **USB Bluetooth adapter** or built-in Bluetooth (for Soleilx dongle pairing)

---

## 🎯 Option 1: Automated Setup (Recommended)

### For PowerShell Users (Windows)

```powershell
# Run the complete automated setup
cd obd_app
.\setup_and_run.ps1
```

This script will:
- Install Flutter SDK if missing
- Get project dependencies
- Connect to your device
- Build and run the app

**Output:**
```
╔════════════════════════════════════════════════════╗
║  OBDII Monitor - Quick Setup Script               ║
╚════════════════════════════════════════════════════╝

Checking system prerequisites...
✓ Git installed: git version 2.45.0
✓ .NET runtime found
✓ Flutter already installed: 3.24.5

Getting project dependencies...
✓ Dependencies installed successfully

Running Flutter doctor...
[Output showing Flutter status]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ Running in release mode
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### For Git Bash Users (Windows/Linux/macOS)

```bash
# Navigate to project directory
cd obd_app

# Run quick setup script
./setup_quick.sh --build-release
```

**With Flutter upgrade:**
```bash
./setup_quick.sh --upgrade-flutter --build-release
```

---

## 🎯 Option 2: Manual Setup (If scripts don't work)

### Step 1: Install Flutter SDK

**Windows PowerShell:**
```powershell
# Download and install Flutter
Invoke-WebRequest -Uri "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip" -OutFile "C:\Users\$env:USERNAME\flutter_windows.zip"
Expand-Archive "C:\Users\$env:USERNAME\flutter_windows.zip" -DestinationPath "$env:USERPROFILE\"
[Environment]::SetEnvironmentVariable("PATH", "$env:USERPROFILE\flutter\bin;" + [System.Environment]::GetEnvironmentVariable("PATH"), "User")

# Verify installation
flutter doctor
```

**Git Bash (Linux/macOS too):**
```bash
# Download Flutter
cd /tmp/
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz

# Extract and move to system path
tar xf flutter*.tar.xz -C /usr/local/
sudo ln -s /usr/local/flutter/bin/flutter /usr/local/bin/flutter

# Verify installation
flutter doctor
```

### Step 2: Install Dependencies

```bash
cd obd_app
flutter pub get
```

### Step 3: Connect Your Soleilx Dongle

**Pairing (done once on Windows):**
1. Open **Settings → Bluetooth & devices → Add device**
2. Select **"Bluetooth"**
3. Search for your paired device or scan if not paired yet
4. If already paired, ensure "Never Disconnect" is enabled

### Step 4: Build and Run

```bash
# Debug build (fast iteration, no performance optimization)
flutter run

# Release build (optimized, better battery)
flutter run --release

# Windows desktop build (PCAN mode)
flutter config --enable-windows-desktop
flutter build windows
```

---

## 🎯 Option 3: Quick Commands Reference

After setup, use these common commands:

### For Mobile (Android with Soleilx dongle)

```bash
# List connected devices
flutter devices

# Run on first available Android device
flutter run --release -d "android-mobile-1"

# Run in debug mode
flutter run -d <device-id>

# Build APK for Android transfer
flutter build apk --release
```

### For Windows Desktop (PCAN/Kvaser)

```bash
# Enable Windows desktop target
flutter config --enable-windows-desktop

# Build Windows executable
flutter build windows

# Run on Windows
flutter run -d windows
```

---

## 📱 Soleilx Dongle Connection Flow

### 1. **Pair the dongle** (only once)

**Windows:**
- Open Settings → Bluetooth & devices → Add device
- Select your paired device from list
- Accept connection request

**Settings to verify:**
- Connection preference: "Never Disconnect"
- Visibility: Should remain discoverable if needed

### 2. **Connect via app**

The app auto-discovers paired devices using the MAC address from pairing.

### Default connection parameters for Soleilx:

| Parameter | Value | Notes |
|-----------|-------|-------|
| Baud Rate | 115200 | Standard UART speed |
| Protocol | Bluetooth Serial | RFCOMM + BLE profile |
| Service UUID | `0000110a` | Serial Port Service |

---

## 🐛 Troubleshooting Quick Fixes

### "Flutter not found" error:

```powershell
# Check Flutter is in PATH
flutter --version

# If missing, add to PATH (PowerShell)
$env:PATH = "$env:USERPROFILE\flutter\bin;" + $env:PATH
```

### "No connected device" on mobile:

```bash
# List all available devices
flutter devices

# Look for your Android device in output
# Example: "OnePlus 9T • emulator-5554 • android-arm64"
```

### "Connection refused" for Soleilx dongle:

1. Check Bluetooth is enabled in Windows settings
2. Verify device is paired: Settings → Bluetooth → Your device
3. Close and reopen the app
4. Try rebooting device (sometimes BLE stack needs restart)

### "Baud rate mismatch":

Some OBDII dongles use different baud rates:

```dart
// In main.dart, modify connect function:
_bluetooth.connect(baudRate: 9600); // Instead of 115200
```

---

## 📊 Expected Output When Working

### Successful connection (Android mobile):

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ Running in release mode on connected device
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Connected to: Android Device • A7B9:C3:D2:E1:F0 • android-arm64

╔════════════════════════════════════════════════════╗
║  OBDII Monitor - Running                           ║
╚════════════════════════════════════════════════════╝

[App starts...]

═══╦═══
║☰║12345
╠═╦═
║160°
║☺ 98%
╚═╩═
```

### Successful connection (Windows desktop):

```
Connecting to Windows...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ Connected via PCAN interface: COM3 (500kbps)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[App starts...]

═══╦═══
║☰║12345
╠═╦═
║8,200 RPM
║⚡ 13.7 V
║104° Coolant
╚═╩═
```

---

## 🎨 Customizing the Build

### Change app name/icon:

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<application
    android:label="My OBDII App"  <!-- Change name here -->
    ...>
```

### Change app theme color:

```dart
// lib/main.dart, line 3
final themeColor = const Color(0xFF1A1A2E); // Your color here
```

### Add additional gauges:

See `lib/widgets/gauge_widget.dart` for adding new gauge types.

---

## 📱 Build APK for Android Transfer

If you want to sideload the app on mobile devices:

```bash
# Build release APK (10-30MB)
flutter build apk --release

# Find output file
ls -lh ./build/app/outputs/apk/debug/*.apk

# Install via USB cable
adb install ./build/app/outputs/apk/debug/app-debug.apk
```

---

## 🚀 Deployment Checklist

Before releasing your app:

- [ ] Test with different vehicles (check PID support)
- [ ] Build release version (not debug)
- [ ] Verify Bluetooth permissions in Android manifest
- [ ] Add privacy policy URL if publishing to stores
- [ ] Test on multiple devices and OS versions

---

## 📞 Need Help?

If scripts fail or app doesn't connect:

1. **Check Flutter logs:**
   ```bash
   flutter run --verbose 2>&1 | findstr "ERROR"
   ```

2. **Check device compatibility:**
   - Soleilx dongle model number from packaging
   - Android/iOS version of target device

3. **Check CAN bus (Windows):**
   ```powershell
   # List available PCAN interfaces
   Get-PnpDevice | Where-Object {$_.FriendlyName -like "*PCAN*"}
   ```

---

**Happy OBDII monitoring! 🏎️**
