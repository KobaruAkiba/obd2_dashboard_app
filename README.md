# OBD Monitor

Flutter app for live **OBD-II vehicle telemetry**. Dark cockpit UI with RPM/speed gauges, temperatures, battery, throttle, fuel, and DTC alerts.

All processing stays on-device — no telemetry is sent to servers.

## Current status

| Layer | Reality |
|-------|---------|
| UI dashboard | Working |
| Mock data stream | Working (debug switch on dashboard) |
| Bluetooth / CAN / BLE | **Stubs** behind `ObdService` — not real adapter I/O yet |

The project is structured so real adapters can replace stubs without rewriting the UI.

## Run

```bash
flutter pub get
flutter run -d windows    # or chrome / android device
```

### Service selection

By default the app starts on the platform hardware stub. In **debug** builds, use the **Mock data** switch on the dashboard to enable simulated telemetry.

Force a source with `--dart-define` (preferred) or `OBD_SERVICE_TYPE`:

```bash
# Default — hardware stub; toggle mock from the debug UI
flutter run

# Start with mock already on (debug switch starts enabled)
flutter run --dart-define=OBD_SERVICE_TYPE=mock

# Hardware stubs (same UI path as future real adapters)
flutter run --dart-define=OBD_SERVICE_TYPE=bt-serial
flutter run --dart-define=OBD_SERVICE_TYPE=windows-can-bus
flutter run --dart-define=OBD_SERVICE_TYPE=ble-uart
```

Aliases also accepted: `mock-windows`, `mock-mobile`, `windows-bluetooth-serial`, `can-bus`.

## Architecture

```
lib/
  main.dart / app.dart          # entry + theme shell
  theme/                        # dark cockpit ThemeData
  models/                       # VehicleData, ConnectionMode
  obd/pid_parser.dart           # SAE J1979 Mode 01 formulas
  services/
    obd_service.dart            # interface
    mock_obd_service.dart       # working simulated source
    stub_hardware_obd_service.dart
    service_router.dart         # selects implementation
  screens/dashboard_screen.dart # connection + layout
  widgets/                      # cockpit, gauges, banners
```

All data sources implement `ObdService` and emit `Stream<VehicleData>` in engineering units (°C, km/h, RPM, %, V).

### PIDs used by the parser

| PID | Metric | Formula |
|-----|--------|---------|
| 0x0C | RPM | `((A×256)+B)/4` |
| 0x0D | Speed | `A` km/h |
| 0x05 / 0x0F | Temp | `A − 40` °C |
| 0x04 / 0x11 / 0x2F | Load / throttle / fuel | `A×100/255` % |
| 0x42 | Module voltage | `((A×256)+B)/1000` V |

## Target hardware (not wired yet)

Planned adapters for when stubs are replaced:

| Platform | Path | Typical hardware |
|----------|------|------------------|
| Windows | USB-CAN | PCAN-USB, Kvaser |
| Windows | Bluetooth Classic (SPS/COM) | Vgate / ELM327 with serial profile |
| Android / iOS | BLE UART | Soleilx-style and similar BLE OBD dongles |

Budget BT Classic dongles on Windows need a virtual COM port after pairing (Device Manager → Ports). Pure BLE-only dongles are a mobile path, not Windows Classic SPS.

## Roadmap

- Wire real ELM327 Bluetooth serial / BLE UART
- Optional Windows CAN (PCAN/Kvaser) via FFI
- Session history + CSV export
- Settings screen (units, redline, connection prefs)
