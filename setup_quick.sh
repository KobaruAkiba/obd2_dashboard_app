#!/usr/bin/env bash
# ============================================================================
# OBDII Monitor - Quick Start Script
# Cross-platform setup for Windows (Git Bash), Linux, and macOS
# ============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Colors for output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_info() {
    echo -e "${CYAN}->${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

log_step() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_status "$1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Check if running on Windows (Git Bash) or Linux/macOS
IS_WINDOWS=false
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    IS_WINDOWS=true
fi

# Function to check and install dependencies
check_dependency() {
    local cmd="$1"
    local name="$2"
    
    if command -v "$cmd" &> /dev/null; then
        print_status "$name installed: $($cmd --version 2>&1 | head -n1)"
        return 0
    else
        print_error "$name not found"
        
        # Platform-specific installation advice
        case "$OSTYPE" in
            msys|cygwin)
                echo "   Install with winget:"
                if [[ "$cmd" == "git" ]]; then
                    echo "     winget install.Git.Git"
                elif [[ "$cmd" == "flutter" ]]; then
                    echo "     winget install Flutter"
                fi
                ;;
            *)
                echo "   Install with:"
                if [[ "$name" == "git" ]]; then
                    echo "     sudo apt-get install git"
                elif [[ "$name" == "flutter" ]]; then
                    echo "     curl -LO https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz"
                    echo "     tar xf flutter*.tar.xz -C /tmp/"
                    echo "     sudo mv /tmp/flutter /usr/local/"
                fi
                ;;
        esac
        
        return 1
    fi
}

# Check and install Flutter if needed
install_flutter() {
    local flutter_version="3.24.5"
    local flutter_zip="flutter_linux_$flutter_version-stable.tar.xz"
    local flutter_url="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/$flutter_zip"
    
    print_info "Checking Flutter installation..."
    
    if command -v flutter &> /dev/null; then
        local version=$(flutter --version 2>/dev/null | awk '{print $2}')
        print_status "Flutter already installed: $version"
        
        # Upgrade if newer version available (optional)
        if [[ "$1" == "--upgrade" ]]; then
            print_info "Upgrading Flutter to version $flutter_version..."
            
            if [[ "$IS_WINDOWS" != true ]]; then
                echo "Downloading new Flutter release..."
                curl -LO "$flutter_url"
                rm -rf flutter*
                tar xf "$flutter_zip" -C /tmp/
                sudo mv /tmp/flutter /usr/local/
                print_status "Flutter upgraded successfully!"
            else
                print_warn "To upgrade on Windows, download from:"
                echo "https://docs.flutter.dev/get-started/install/windows"
            fi
        fi
        
        return 0
    else
        print_info "Flutter not installed, installing..."
        
        # Download Flutter
        if [[ "$IS_WINDOWS" == true ]]; then
            # Windows path (for Git Bash)
            local flutter_zip="$HOME/flutter_windows_${flutter_version}-stable.zip"
            curl -L -o "$flutter_zip" "$flutter_url"
            unzip -q -o "$flutter_zip" -d "$HOME"
            rm "$flutter_zip"
            
            # Add to PATH (may require logout/login)
            export PATH="$HOME/flutter/bin:$PATH"
            print_status "Flutter installed at: $HOME/flutter"
        else
            # Linux/macOS
            echo "Downloading Flutter release..."
            curl -LO "$flutter_url"
            tar xf "$flutter_zip" -C /tmp/
            sudo mv /tmp/flutter /usr/local/
            rm "$flutter_zip"
            
            export PATH="$HOME/.local/bin:$PATH"
            print_status "Flutter installed at: /usr/local/flutter"
        fi
        
        return 0
    fi
}

# Function to setup Flutter project
setup_project() {
    log_step "Setting up Flutter project dependencies..."
    
    cd "$SCRIPT_DIR/obd_app" 2>/dev/null || (cd obd_app)
    
    if [[ ! -d ".dart_tool" ]]; then
        print_info "Getting Flutter dependencies..."
        flutter pub get
    else
        print_status "Dependencies already installed"
    fi
    
    # Create fonts directory if needed
    mkdir -p assets/fonts
    
    return 0
}

# Function to verify device connection
verify_device() {
    log_step "Verifying device connections..."
    
    flutter devices --machine | jq -r '.devices[] | select(.type != "service") | .name' 2>/dev/null || true
    
    print_status "Connected devices detected (run 'flutter devices' for details)"
    
    return 0
}

# Main execution
main() {
    local mode="${1:-}"  # Optional: --build-release, --upgrade-flutter, --test-only
    
    log_step "OBDII Monitor - Quick Setup"
    echo ""
    print_info "Project: $(pwd)"
    echo ""
    
    # Check system prerequisites
    check_dependency "flutter" "Flutter SDK" || {
        if [[ "$1" != "--skip-flutter" ]]; then
            install_flutter --upgrade
        fi
    }
    
    check_dependency "git" "Git"
    check_dependency "dart" "Dart SDK (included with Flutter)"
    
    # Setup project
    setup_project
    
    # Check for build environment
    if [[ ! -d ".vscode" ]]; then
        print_info "VS Code extension not detected. Install for best experience:"
        echo "   Extensions: Dart, Flutter DevKit, Device Tools"
    fi
    
    # Verify device
    verify_device
    
    # Run based on mode or default
    if [[ "$mode" == "--build-release" ]]; then
        print_info "Building release APK..."
        flutter build apk --release
        echo ""
        print_status "Release APK created at: $(ls -t ./build/app/outputs/apk/release/*.apk | head -n1)"
    elif [[ "$mode" == "--test-only" ]]; then
        print_info "Running in test mode (no device connection)..."
        flutter run --release --debug
    elif [[ "$mode" == "--windows-desktop" ]]; then
        print_info "Building for Windows desktop..."
        
        # Create Windows project structure if missing
        mkdir -p lib/platform/windows
        
        # Setup for Windows build
        flutter config --enable-windows-desktop
        
        flutter run -d windows
    else
        # Default: Run on first connected device
        print_info "Running in debug mode (connect your device and press Enter to continue)..."
        
        # Check if device is connected
        local device_count=$(flutter devices --machine | jq '.devices[] | select(.type != "service") | .name' 2>/dev/null | wc -l)
        
        if [[ $device_count -eq 0 ]]; then
            print_warn "No connected device found"
            echo ""
            echo "Available commands:"
            echo "  flutter devices              # List available devices"
            echo "  flutter run                  # Run on first connected device"
            echo "  flutter run -d <device-id>   # Run on specific device"
            echo "  flutter build apk --release  # Build mobile APK for Android"
            echo ""
            echo "Next steps:"
            echo "1. Connect your Soleilx dongle via Bluetooth"
            echo "2. Pair it with your device (Settings → Bluetooth)"
            echo "3. Run: flutter run -d <your-device-id>"
        else
            print_info "Running Flutter app..."
            flutter run --release
        fi
    fi
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --upgrade-flutter)
            install_flutter --upgrade
            shift
            ;;
        --build-release)
            shift
            main "--build-release"
            exit 0
            ;;
        --windows-desktop)
            shift
            main "--windows-desktop"
            exit 0
            ;;
        --test-only)
            shift
            main "--test-only"
            exit 0
            ;;
        *)
            print_warn "Unknown option: $1"
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --upgrade-flutter   Upgrade Flutter SDK"
            echo "  --build-release     Build release APK"
            echo "  --windows-desktop   Build for Windows desktop"
            echo "  --test-only         Test without device"
            exit 1
            ;;
    esac
done

# Default mode
main

echo ""
echo -e "${GREEN}Setup complete!${NC}"
echo ""
print_info "Next steps:"
echo "  1. Pair Soleilx dongle to your device via Bluetooth settings"
echo "  2. Connect: Settings → Bluetooth → Scanner Diagnostico Auto Multimarca"
echo "  3. Set 'Never Disconnect' if available on your device"
echo "  4. Run the app with: flutter run -d <your-device-id>"
