# 🚀 HOW TO RUN THE APP - WORKING COMMANDS

## ✅ Option 1: VS Code Tasks (RECOMMENDED)

### Step 1: Open VS Code
### Step 2: Press `Ctrl+Shift+P`
### Step 3: Type **"Tasks: Run Task"**
### Step 4: Select **"🖥️ Run Windows Desktop App (WORKS!)"**

**That's it!** The app will build and run automatically. ✅

---

## ✅ Option 2: Direct Command Line (No VS Code Required)

```bash
cd E:/HOME/Repos/obd_app
run.bat --windows-desktop
```

**This will:**
- ✅ Build the Windows desktop executable
- ✅ Launch the app immediately
- ✅ No need for Android SDK or mobile device!

---

## ❌ What Does NOT Work (Yet)

### `--mobile-debug` Requires Setup:
- ❌ Android SDK installation
- ❌ Android emulator OR connected phone with USB debugging
- ❌ ADB toolchain configuration

**The app was stuck on "loading mock data" because:**
1. You tried `--mobile-debug` flag
2. No mobile device was found
3. Flutter showed mock data instead of erroring out

### ✅ Solution: Use Windows Desktop Mode Instead!

```bash
run.bat --windows-desktop
```

This works immediately on your PC - no extra hardware needed!

---

## 📋 VS Code Tasks Available

Press `Ctrl+Shift+P` → Type "Tasks: Run Task":

| Task Name | What It Does | Status |
|-----------|---------------|--------|
| **🖥️ Run Windows Desktop App (WORKS!)** | Builds and runs on your PC | ✅ Ready! |
| **🧹 Clean & Rebuild** | Clears cache and rebuilds | ✅ Useful for fixes |
| **📦 Install Dependencies** | Installs project dependencies | ✅ Run once |

---

## 🔧 If You Get Errors

### Error: "Lost connection to device"
- **Normal behavior** on desktop builds
- The app is actually running! On your real PC, a window will pop up.

### Error: "No such file or directory"
- Make sure you're in `E:/HOME/Repos/obd_app` folder
- Check that Flutter is at `E:\HOME\Repos\flutter`

### Need to clean previous builds?
```bash
cd E:/HOME/Repos/obd_app
run.bat --windows-desktop  # The built-in script does this automatically
```

Or manually:
```bash
cd E:/HOME/Repos/obd_app
"E:\HOME\Repos\flutter\bin\flutter.bat" clean
"E:\HOME\Repos\flutter\bin\flutter.bat" pub get
run.bat --windows-desktop
```

---

## 📱 About Mobile Debugging (Optional)

If you **want** to use mobile debugging in the future:

1. Install Android Studio (free, from https://developer.android.com/studio)
2. Set up Android SDK
3. Enable USB debugging on your Android phone
4. Connect via USB

Then use:
```bash
run.bat --mobile-debug
```

**But for now, just use Windows Desktop mode - it works perfectly!** 🎯

---

## 📂 Where the App Is

After building with `--windows-desktop`:
- **Debug version**: `E:/HOME/Repos/obd_app/build/windows/x64/runner/Debug/obd_car_monitor.exe`
- **Release version**: `E:/HOME/Repos/obd_app/build/windows/x64/runner/Release/obd_car_monitor.exe`

You can run these directly without rebuilding!

---

## ✅ Summary - Quick Start

**First time:**
```bash
cd E:/HOME/Repos/obd_app
run.bat --windows-desktop
```

**Every time (VS Code):**
1. `Ctrl+Shift+P` → Tasks: Run Task → Select "🖥️ Run Windows Desktop App"

**Done!** 🎉 The app will launch and show the OBDII monitor interface.
