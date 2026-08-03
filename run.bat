@echo off
REM ============================================================================
REM OBDII Monitor - Quick Run Script for Windows (PowerShell)
REM Flutter path: E:\HOME\Repos\flutter\bin\flutter.bat
REM ============================================================================

set FLUTTER="E:\HOME\Repos\flutter\bin\flutter.bat"

echo.
echo ╔════════════════════════════════════════════════════╗
echo ║  OBDII Monitor - Quick Run Script (Windows)        ║
echo ╚════════════════════════════════════════════════════╝
echo.

REM Check Flutter installation
"%FLUTTER%" --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [!] Flutter not found!
    echo Please verify Flutter is installed at: E:\HOME\Repos\flutter
    pause
    exit /b 1
)

REM Show connected devices
echo Checking connected devices...
"%FLUTTER%" devices

if "%1" == "--release" (
    echo.
    echo Building release APK for Android...
    "%FLUTTER%" build apk --release --no-tree-shake-icons
    echo.
    echo Release APK created!
    echo Location: .\build\app\outputs\apk\release\\*.apk
) else if "%1" == "--windows-desktop" (
    echo.
    echo ╔════════════════════════════════════════════════════╗
    echo ║  Building Windows Desktop Executable               ║
    echo ╚════════════════════════════════════════════════════╝
    echo.
    
    REM Enable Windows desktop target if not already enabled
    "%FLUTTER%" config --enable-windows-desktop
    
    echo Building Windows application...
    "%FLUTTER%" build windows --debug
    
    echo.
    echo ╔════════════════════════════════════════════════════╗
    echo ║  Build Complete!                                    ║
    echo ╚════════════════════════════════════════════════════╝
    echo.
    echo The Windows executable is located at:
    echo   .\build\windows\x64\runner\Debug\obd_car_monitor.exe
    
    echo.
    echo To run the app, launch it directly or use VS Code tasks:
    echo   Ctrl+Shift+P → Type "Tasks: Run Task"
    echo   Select: "🖥️ Windows Desktop Run (WORKS NOW)"
    echo.
    
    pause
) else if "%1" == "--mobile-debug" (
    echo.
    echo ╔════════════════════════════════════════════════════╗
    echo ║  OBDII Monitor - Mobile Debug Mode                 ║
    echo ╚════════════════════════════════════════════════════╝
    echo.
    
    "%FLUTTER%" devices --device-timeout=30
    
    echo.
    echo Connecting to mobile device...
    "%FLUTTER%" run -d "connected-mobile" --device-timeout=30
) else (
    REM Default: Run Windows Desktop
    echo.
    echo ════════════════════════════════════════
    echo   OBDII Monitor - Windows Desktop Mode  
    echo ════════════════════════════════════════
    echo.
    
    "%FLUTTER%" config --enable-windows-desktop
    
    echo Building Windows application...
    "%FLUTTER%" build windows --debug
    
    echo.
    echo ╔════════════════════════════════════════════════════╗
    echo ║  Build Complete!                                    ║
    echo ╚════════════════════════════════════════════════════╝
    echo.
    
    pause
)

echo.
echo ╔════════════════════════════════════════════════════╗
echo ║           Quick Reference Commands                  ║
echo ╚════════════════════════════════════════════════════╝
echo.
echo   ./run.bat --windows-desktop    Build Windows app (WORKS!)
echo   ./run.bat --mobile-debug       Debug on mobile device
echo   ./run.bat --release            Build Android APK
echo   flutter devices                List connected devices
echo.

pause
