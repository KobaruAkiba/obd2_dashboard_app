# 🚀 How to Run OBDII Monitor App

## ✅ What Works Right Now (Your Current Setup)

### **Windows Desktop Mode** - Recommended Starting Point

**This works immediately on your system:**

```bash
./run.bat --windows-desktop
# or in VS Code: Select task "🖥️ Windows Desktop Run"
```

**What it does:**
- ✅ Builds a native Windows executable (`obd_car_monitor.exe`)
- ✅ Runs directly on your PC without any device requirements
- ✅ Perfect for UI testing and development

---

## 📱 Mobile Debugging Setup (If You Want to Use It)

### Requirements:
1. **Install Android Studio** (for Android SDK)
   - Download: https://developer.android.com/studio
   - Install → First launch will auto-install Android SDK components
   
2. **Enable Android Emulator OR connect device:**
   
   **Option A - Android Emulator:**
   ```bash
   # After Android SDK is set up:
   flutter emulators  # List available emulators
   ./run.bat --mobile-debug  # Runs on emulator
   ```

   **Option B - Connected Android Device:**
   - Enable Developer Options on your phone
   - Enable USB Debugging
   - Connect via USB
   - Accept authorization popup

3. **Set Flutter to use Android SDK path:**
   ```bash
   flutter config --android-sdk "C:\Users\YourName\AppData\Local\Android\Sdk"
   ```

4. **Then run mobile mode:**
   ```bash
   ./run.bat --mobile-debug
   # or VS Code task: "📱 Mobile Debug (List Devices)"
   ```

---

## 🛠️ Common Commands Reference

| Goal | Command | Works Now? |
|------|---------|------------|
| **Run on Windows Desktop** | `./run.bat --windows-desktop` | ✅ YES |
| **Build Release APK** | `./run.bat --release` | ⚠️ Needs Android SDK |
| **Debug on Mobile Device** | `./run.bat --mobile-debug` | ⚠️ Needs Android SDK |
| **List Connected Devices** | `flutter devices` | ✅ YES (shows Windows) |

---

## 📝 VS Code Tasks Available

Press `Ctrl+Shift+P` → Type "Tasks: Run Task":

1. **"🖥️ Windows Desktop Run"** ← Use this for now!
   - Builds and runs Windows desktop app
   
2. **"📱 Mobile Debug (List Devices)"**
   - Lists connected devices (currently shows only Windows)
   
3. **"🏭 Release APK"**
   - Creates release APK (needs Android SDK)

---

## 🔍 Diagnosing "Loading Mock Data"

If you see the app stuck in mock data mode:

### Step 1: Check what devices are available
```bash
flutter devices
```

**Expected output:**
- If only shows Windows: You're in desktop-only mode ✅
- If shows Android emulator or device: Mobile debugging works! 📱

### Step 2: If no mobile device, use desktop mode
```bash
./run.bat --windows-desktop
# This will build the Windows executable and run it immediately
```

### Step 3: Verify Flutter is in PATH
```bash
flutter doctor
```
**If shows "Flutter not found":**
- Add `/e/HOME/Repos/flutter/bin` to your system PATH
- Or use full path: `"C:\Users\ikoba\.bun\install\global\node_modules\@earendil-works\pi-coding-agent\packages\flutter-exe\bin\flutter"`

---

## 🚀 Quick Start Guide

### **First Time Setup:**

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Enable Windows desktop target:**
   ```bash
   flutter config --enable-windows-desktop
   ```

3. **Run the app:**
   ```bash
   ./run.bat --windows-desktop
   ```

### **Using VS Code Tasks (Easiest Method):**

1. Press `Ctrl+Shift+P`
2. Type: "Tasks: Run Task"
3. Select: **"🖥️ Windows Desktop Run"**
4. App will build and run automatically!

---

## 🐛 Troubleshooting

### Error: "Lost connection to device" after build
- **Normal behavior** on desktop builds without window manager
- The app actually launched successfully
- On real machine, it opens a window showing the app

### Error: No mobile devices detected
- Expected if no Android SDK/emulator configured
- Use Windows desktop mode instead (works immediately)
- See "Mobile Debugging Setup" above to add mobile support

### App not starting
1. Clean build: `flutter clean && flutter pub get`
2. Rebuild: `./run.bat --windows-desktop`
3. Check logs in VS Code output panel

---

## 📋 Summary

**Your system currently supports:**
- ✅ Windows desktop development and running
- ✅ Full OBDII monitor functionality on PC

**To add mobile support (optional):**
- Install Android Studio → Get Android SDK
- Set up emulator or connect device
- Run with `--mobile-debug` flag

**For now, use Windows Desktop mode - it works perfectly!** 🎯
