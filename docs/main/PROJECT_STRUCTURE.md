# 🏗️ Project Structure Overview

```
obd_app/
├── lib/                          # Flutter source code
│   ├── main.dart                 # App entry point with dark theme
│   ├── models/                   # Data models
│   │   └── vehicle_data.dart     # VehicleData, DTC structures
│   ├── obdii/                    # OBDII protocol layer
│   │   └── pid_parser.dart       # SAE J1979 PID parsing
│   ├── services/                 # Platform services
│   │   └── bluetooth_serial_service.dart  # Soleilx Bluetooth comms
│   ├── platform/                 # Platform-specific wrappers
│   │   ├── windows_can_wrapper.dart    # PCAN/Kvaser for Windows
│   │   └── android_bluetooth_handler.dart  # Android BLE handler
│   ├── widgets/                  # UI components
│   │   └── gauge_widget.dart     # Circular gauges (RPM, Speed, Coolant)
│   └── screens/                  # Will be added: home, settings, history
├── android/                      # Android native code
│   ├── app/src/main/
│   │   ├── kotlin/com/example/...    # MainActivity.kt
│   │   ├── res/                   # UI resources, icons, colors
│   │   └── build.gradle           # Build configuration
├── assets/                       # Static assets
│   ├── fonts/                    # Gauge fonts (optional)
│   └── screenshots/              # App preview images
├── test/                         # Unit tests
├── pubspec.yaml                  # Dependencies list
├── analysis_options.yaml         # Linting rules
├── README.md                     # Documentation
├── SETUP_INSTRUCTIONS.md         # Quick setup guide
└── PROJECT_STRUCTURE.md          # This file

═══════════════════════════════════════════
                         Core Logic Files:

1. lib/obdii/pid_parser.dart
   └── Contains all OBDII PID parsing logic (SAE J1979)
       • Mode $01: Real-time data (RPM, Speed, Temps)
       • Mode $03: Vehicle identification
       • Mode $04: Clear DTCs

2. lib/services/bluetooth_serial_service.dart
   └── Soleilx-specific Bluetooth Serial communication
       • BLE discovery & pairing
       • UART profile connection
       • ISO-TP Layer 1 message handling
       • OBDII query/response parsing

3. lib/models/vehicle_data.dart
   └── Data models for UI binding
       • VehicleData: Live data snapshot
       • DTCEntry: Trouble code with severity

4. lib/widgets/gauge_widget.dart
   └── Custom painters for circular gauges
       • RpmGaugePainter
       • SpeedGaugePainter  
       • CoolantGaugePainter (linear gradient)

5. lib/platform/windows_can_wrapper.dart
   └── Windows native CAN communication
       • PCAN/Kvaser driver integration
       • ISO-TP routing configuration
       • Direct ECU frame transmission

6. lib/platform/android_bluetooth_handler.dart
   └── Android Bluetooth native integration
       • Bluetooth MAC address parsing
       • Service UUID handling
       • Foreground service streaming

═══════════════════════════════════════════
                    Main Entry: main.dart
┌─────────────────────────────────────────┐
│  MaterialApp                           │
│    ├── Theme: Dark (#1A1A2E)            │
│    └── HomeScreen widget               │
│         ├── Stack with background      │
│         ├── Status bar                 │
│         ├── GridView of gauges         │
│         ├── Connection button          │
│         └── DTC panel (conditional)    │
└─────────────────────────────────────────┘
