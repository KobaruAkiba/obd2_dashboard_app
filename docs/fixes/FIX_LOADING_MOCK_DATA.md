# 🔧 Fix "Loading Mock Data" Issue

## Problem

When running with `./run.bat --mobile-debug` or `flutter run -d "connected-mobile"`, the app appears stuck in loading mock data state.

## Root Cause

The `--mobile-debug` flag uses `flutter run -d "connected-mobile"` which:
- Targets Android/iOS devices connected via ADB
- If no device is detected, Flutter may show mock data or get stuck
- The command doesn't properly error when no mobile device is available

## ✅ Solution 1: Use VS Code Tasks (Recommended)

**Press `Ctrl+Shift+P` → Type "Tasks: Run Task"**:

| Task | When to Use |
|------|-------------|
| **Mobile Debug** | Quick run with connected device |
| **Mobile Debug + Device List** | First use - lists available devices first |

### Step-by-Step:

1. **Press `Ctrl+Shift+P`** in VS Code
2. Type **"Tasks: Run Task"**
3. Select **"Mobile Debug"** or **"Mobile Debug + Device List"**

The task will automatically:
- Check for connected mobile devices via ADB
- Show device list before running
- Provide better error messages if no device is found

## ✅ Solution 2: Manual Flutter Commands

```bash
# Step 1: List available devices first
flutter devices

# Then run on your specific device
# Example: Run on specific Android device
flutter run -d <device-id>

# Or connect via USB cable for ADB debugging
adb devices
flutter run -d emulator-5554  # Replace with your device ID
```

## ✅ Solution 3: Desktop Mode (Alternative)

If you're developing on Windows without mobile hardware:

```bash
./run.bat --windows-desktop
# or use VS Code task: "Windows Desktop Build"
```

This builds a desktop executable that can be used to test the UI.

## 🔍 Check Device Connection

Before running, verify your setup:

```bash
# List all connected devices
flutter devices

# Expected output for mobile debugging:
# Connected device: Android SDK built for x86 (emulator-5554) • emulator-5554 • android

# If empty or shows only Windows:
# No available devices
```

## ⚙️ Quick Fix Commands

```bash
# 1. Enable hot reload and restart
flutter config --enable-linux-desktop
flutter config --enable-windows-desktop

# 2. Install dependencies if needed
flutter pub get

# 3. Clear previous builds (helps with mock data)
rm -rf build/

# 4. Run fresh
./run.bat --mobile-debug
```

## 📱 Mobile Debugging Requirements

For `--mobile-debug` to work properly:

1. **Android Device/Emulator**: Must be connected via USB with ADB enabled
2. **Enable USB Debugging**: Settings → Developer Options → USB debugging
3. **Allow ADB Access**: First connection requires permission popup
4. **Device Detection**: Run `flutter devices` to verify detection

## 🎯 Complete Setup Script

Create this file as `.vscode/run-debug.sh`:

```bash
#!/usr/bin/env bash
echo "📱 OBDII Monitor - Mobile Debug"
flutter devices
echo ""
flutter run -d "connected-mobile"
```

Make executable: `chmod +x .vscode/run-debug.sh`

Then use VS Code tasks to run it.

---

## 🚀 Quick Reference

| Goal | Command / Task |
|------|----------------|
| Start debugging on mobile | VS Code: **"Mobile Debug"** |
| Check devices first | `flutter devices` |
| Run on specific device | `flutter run -d <device-id>` |
| Desktop build (no mobile) | `./run.bat --windows-desktop` |
| Release APK | `./run.bat --release` |

---

**Still seeing mock data?** Ensure:
- ADB is properly enabled on your device
- Device appears in `flutter devices` output
- No other Flutter process is holding a port (kill with `flutter clean && flutter pub get`)

---
*This fix is documented in:*  
- [docs/main/CLEANUP_SUMMARY.md](../../main/CLEANUP_SUMMARY.md) - Project cleanup overview  
- [docs/running/HOW_TO_RUN.md](../../running/HOW_TO_RUN.md) - How to run the app  
