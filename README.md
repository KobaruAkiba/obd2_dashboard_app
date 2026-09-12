# OBD Monitor

Flutter app for live **OBD-II vehicle telemetry**. Dark cockpit UI with RPM/speed gauges, temperatures, battery, throttle, fuel, and DTC alerts. All processing stays on-device — no telemetry is sent to servers.

## Current status

| Layer | Reality |
|-------|---------|
| UI dashboard | Working |
| Mock data stream | Working (debug switch on dashboard) |
| Bluetooth / CAN / BLE | Deferred adapters behind `ObdService` — not real I/O yet |

## Run

```bash
flutter pub get
flutter run -d windows    # or chrome / android device
```

## Service selection

By default the app starts on the platform hardware stub. In **debug** builds, use the **Mock data** switch on the dashboard for simulated telemetry.

```bash
flutter run                                              # auto / hardware stub
flutter run --dart-define=OBD_SERVICE_TYPE=mock          # mock on at start
flutter run --dart-define=OBD_SERVICE_TYPE=bt-serial
flutter run --dart-define=OBD_SERVICE_TYPE=windows-can-bus
flutter run --dart-define=OBD_SERVICE_TYPE=ble-uart
```

Supported values: `mock`, `bt-serial`, `windows-can-bus`, `ble-uart`, `auto`.

## Architecture

```
lib/
  main.dart / app.dart
  core/          # theme, debugLog
  domain/        # VehicleData, ConnectionMode, ObdService, ObdTransport, PidParser
  data/          # ObdServiceFactory, MockObdService, DeferredObdAdapter
  presentation/  # dashboard screen/controller + cockpit widgets
```

## ObdService contract

Every data source implements `ObdService`: `displayName`, `transport` (`ObdTransport`), `Stream<VehicleData>`, `Stream<ObdConnectionState>`, plus `connect` / `disconnect` / `dispose`. Values are engineering units (°C, km/h, RPM, %, V).

## PIDs supported

| PID | Metric | Formula |
|-----|--------|---------|
| 0x0C | RPM | `((A×256)+B)/4` |
| 0x0D | Speed | `A` km/h |
| 0x05 / 0x0F | Temp | `A − 40` °C |
| 0x04 / 0x11 / 0x2F | Load / throttle / fuel | `A×100/255` % |
| 0x42 | Module voltage | `((A×256)+B)/1000` V |

## Target hardware

| Platform | Path | Typical hardware |
|----------|------|------------------|
| Windows | USB-CAN | PCAN-USB, Kvaser |
| Windows | Bluetooth Classic (SPS/COM) | Vgate / ELM327 |
| Android / iOS | BLE UART | BLE OBD dongles |

## Development

```bash
flutter analyze
flutter test
```

## Roadmap

- Wire real ELM327 Bluetooth serial / BLE UART
- Optional Windows CAN (PCAN/Kvaser) via FFI
- Session history + CSV export
- Settings screen (units, redline, connection prefs)
