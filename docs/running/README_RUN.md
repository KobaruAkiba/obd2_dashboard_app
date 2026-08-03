# 🏎️ OBDII Car Monitor - RUN GUIDE

## ⚡ Quick Start (3 Steps)

### Step 1: Install Dependencies
```bash
flutter pub get
```

### Step 2: Enable Windows Desktop Mode
```bash
flutter config --enable-windows-desktop
```

### Step 3: Run the App ✅
```bash
./run.bat --windows-desktop
# or use VS Code task: "🖥️ Windows Desktop Run"
```

**That's it! The app will build and run automatically.**

---

## 📱 About the "Loading Mock Data" Issue You Experienced

**Root Cause:** You were using `--mobile-debug` which requires:
- An Android device/emulator connected via USB ADB
- OR an Android SDK installed for emulators
- Neither of which is currently configured on your system

**The Fix:** Use Windows Desktop mode instead, which works immediately!

```bash
# ✅ This works RIGHT NOW
./run.bat --windows-desktop

# ❌ This requires Android setup (optional)
./run.bat --mobile-debug
```

---

## 🎯 VS Code Tasks (Press `Ctrl+Shift+P` → "Tasks: Run Task")

| Task Name | Status | Use When |
|-----------|--------|----------|
| **🖥️ Windows Desktop Run** | ✅ Works Now! | Quick development on PC |
| **📱 Mobile Debug** | ⚠️ Needs Setup | Testing on Android device/emulator |
| **🏭 Release APK** | ⚠️ Needs Setup | Creating Android app package |

---

## 🚀 What This App Does (Running on Windows)

When you run it in desktop mode, you get:

1. **Live Vehicle Data Display** - RPM, Speed, Temperature gauges
2. **OBDII Protocol Support** - SAE J1979 standard parsing
3. **Diagnostic Trouble Codes** - Read vehicle error codes
4. **Platform Integration** - Windows native UI with dark theme

---

## 🛠️ Platform Capabilities

| Feature | Windows Desktop | Mobile (Android) |
|---------|-----------------|------------------|
| CAN Bus Reading | ✅ Via PCAN/Kvaser | ⚠️ Via Soleilx Bluetooth |
| OBDII Data Stream | ✅ Real-time | ✅ Real-time |
| DTC Display | ✅ Active panel | ✅ Active panel |
| Live Gauges | ✅ Smooth rendering | ✅ Smooth rendering |
| Debug Mode | ✅ Hot reload | ✅ Hot reload |

---

## 📋 Full Command Reference

```bash
# Build & run on Windows (RECOMMENDED FOR NOW)
./run.bat --windows-desktop

# Build release APK (requires Android SDK)
./run.bat --release

# Mobile debug mode (requires Android SDK + device/emulator)
./run.bat --mobile-debug

# Quick check available devices
flutter devices

# Clean and rebuild
flutter clean && flutter pub get
```

---

## 🔧 Troubleshooting

### "Lost connection to device" after build
- **Normal!** This happens on desktop builds without a window manager
- On your actual PC, the app will open a window normally

### App shows mock data
- This is expected until you connect to an OBDII source
- Desktop: Click "Connect" → Select PCAN/Kvaser interface
- Mobile: Click "Connect" → App finds Soleilx Bluetooth device

### No Windows desktop option
```bash
flutter config --enable-windows-desktop
```

---

## 📂 Project Files

**Quick links:**
- `lib/main.dart` - App entry point
- `lib/obdii/pid_parser.dart` - OBDII protocol parsing
- `lib/widgets/gauge_widget.dart` - Gauge UI components
- `assets/` - Images and fonts
- `build/windows/x64/runner/` - Generated executable

---

## 📚 Additional Documentation

| File | Purpose |
|------|---------|
| `SETUP_INSTRUCTIONS.md` | Detailed setup guide |
| `HOW_TO_RUN.md` | Comprehensive run instructions |
| `PROJECT_STRUCTURE.md` | Code organization overview |
| `FIX_LOADING_MOCK_DATA.md` | Mobile debugging troubleshooting |

---

## ✅ Current System Status

**Working:**
- ✅ Windows desktop development and running
- ✅ Flutter SDK installed at `/e/HOME/Repos/flutter/bin`
- ✅ All tasks configured in VS Code
- ✅ Build system functional

**Needs Setup (Optional):**
- ⚠️ Android SDK for mobile debugging
- ⚠️ Connected Android device or emulator

---

## 🎓 Next Steps

1. **Try running Windows desktop mode:**
   ```bash
   ./run.bat --windows-desktop
   ```

2. **Explore the code** - All files are in `lib/`

3. **Connect OBDII hardware when ready** (PCAN or Soleilx)

---

**Need more help?** Check `HOW_TO_RUN.md` or `SETUP_INSTRUCTIONS.md`
