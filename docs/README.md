# OBDII Monitor - Documentation

This folder contains all documentation for the **OBDII Monitor** cross-platform Flutter application, organized by context:

## 📁 Documentation Structure

### [main/](./main/)
Core documentation including:
- **[README.md](./main/README.md)** - Main project overview and quick start
- **[PROJECT_STRUCTURE.md](./main/PROJECT_STRUCTURE.md)** - Detailed code structure and core logic files

### [setup/](./setup/)
Installation and setup guides:
- **[QUICK_START_GUIDE.md](./setup/QUICK_START_GUIDE.md)** - Automated setup scripts for Windows/Linux/macOS
- **[SETUP_INSTRUCTIONS.md](./setup/SETUP_INSTRUCTIONS.md)** - Detailed prerequisites, platform setup, and hardware connection

### [running/](./running/)
Running the application:
- **[HOW_TO_RUN.md](./running/HOW_TO_RUN.md)** - How to run with VS Code tasks or command line
- **[README_RUN.md](./running/README_RUN.md)** - 3-step quick start guide for running the app
- **[USE_THIS_TO_RUN.md](./running/USE_THIS_TO_RUN.md)** - Recommended working commands and troubleshooting

### [fixes/](./fixes/)
Bug fixes and troubleshooting:
- **[CLEANUP_SUMMARY.md](./fixes/CLEANUP_SUMMARY.md)** - Project cleanup and duplicate logic removal
- **[FIX_APPLIED.md](./fixes/FIX_APPLIED.md)** - Fix for "Loading mock data" issue with VS Code paths
- **[FIX_LOADING_MOCK_DATA.md](./fixes/FIX_LOADING_MOCK_DATA.md)** - Troubleshooting mobile debugging issues

## 🚀 Quick Start

**Get running immediately:**

```bash
cd obd_app
.\setup_and_run.ps1  # Windows PowerShell
# or
./setup_quick.sh --build-release  # Git Bash/Linux/macOS
```

Then run the app:

```bash
run.bat --windows-desktop
# or use VS Code Tasks → "🖥️ Run Windows Desktop App (WORKS!)"
```

## 📚 Related Documentation

- **[main/README.md](./main/README.md)** - Full project documentation with features and customization
- **[setup/QUICK_START_GUIDE.md](./setup/QUICK_START_GUIDE.md)** - Prerequisites and installation checklist

---

*Built with Flutter • OBDII Standard • Cross-platform monitoring*
