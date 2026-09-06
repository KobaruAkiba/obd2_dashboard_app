# OBD Monitor

Flutter app for live **OBD-II vehicle telemetry**. Dark cockpit UI with RPM/speed gauges, temperatures, battery, throttle, fuel, and DTC alerts.

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

You can still force a source with `--dart-define` (preferred) or `OBD_SERVICE_TYPE`:

```bash
# Default — hardware stub; toggle mock from the debug UI
flutter run

# Start with mock already on (debug switch starts enabled)
flutter run --dart-define=OBD_SERVICE_TYPE=mock

# Hardware stubs
flutter run --dart-define=OBD_SERVICE_TYPE=bt-serial
flutter run --dart-define=OBD_SERVICE_TYPE=windows-can-bus
flutter run --dart-define=OBD_SERVICE_TYPE=ble-uart
```

## Architecture

```
lib/
  main.dart / app.dart          # entry + theme shell
  theme/                        # dark cockpit ThemeData
  models/                       # VehicleData, ConnectionMode
  obd/pid_parser.dart           # SAE J1979 Mode 01 formulas
  services/
    obd_service.dart            # interface
    mock_obd_service.dart       # real working source
    stub_hardware_obd_service.dart
    service_router.dart         # selects implementation
  screens/dashboard_screen.dart # connection + layout
  widgets/                      # cockpit, gauges, banners
```

All data sources implement `ObdService` and emit `Stream<VehicleData>` in engineering units (°C, km/h, RPM, %, V).

## Roadmap

- Wire real ELM327 Bluetooth serial / BLE UART
- Optional Windows CAN (PCAN/Kvaser) via FFI
- Session history + CSV export
- Settings screen (units, redline, connection prefs)

## Docs

Older notes under `docs/` describe early experiments and may be outdated. **This README and `lib/` are the source of truth.**
