# OBD Monitor

Flutter app for live **OBD-II vehicle telemetry**. Dark cockpit UI with RPM/speed gauges, temperatures, battery, throttle, fuel, and DTC alerts. All processing stays on-device — no telemetry is sent to servers.

## Current status

| Layer | Reality |
|-------|---------|
| UI dashboard | Working |
| Mock data stream | Working (debug switch on dashboard) |
| BLE UART (ELM327) | Real adapter on Android/iOS (`BleUartObdService`) |
| Bluetooth Classic / CAN | Still deferred stubs (`DeferredObdAdapter`) |

## BLE vs CAN

BLE UART talks to an **ELM327-class dongle** over Nordic UART (GATT). The app sends AT + Mode 01 PID commands; the dongle speaks to the vehicle bus (often CAN under the hood). That is **not** the same as the Windows USB-CAN path (`windows-can-bus`), which would read native CAN frames via PCAN/Kvaser without ELM.

## Run

```bash
flutter pub get
flutter run -d android   # or ios / windows / chrome
```

### BLE UART (mobile)

```bash
flutter run -d android --dart-define=OBD_SERVICE_TYPE=ble-uart
# or leave unset / auto on non-Windows — factory selects BleUartObdService
```

Grant Bluetooth (and location on Android for scanning) when prompted. Connect failure surfaces an error state — the app does **not** silently fall back to mock.

### Windows limitation

`auto` on Windows still selects the CAN stub. `ble-uart` can be forced, but `flutter_blue_plus` BLE support on Windows is immature; prefer Android/iOS for real dongles. Use the debug **Mock data** switch when you have no hardware.

```bash
flutter run -d windows --dart-define=OBD_SERVICE_TYPE=mock
flutter run -d windows --dart-define=OBD_SERVICE_TYPE=windows-can-bus
flutter run -d windows --dart-define=OBD_SERVICE_TYPE=bt-serial
```

## Service selection

By default the app starts on the platform hardware path. In **debug** builds, use the **Mock data** switch on the dashboard for simulated telemetry.

```bash
flutter run                                              # auto
flutter run --dart-define=OBD_SERVICE_TYPE=mock
flutter run --dart-define=OBD_SERVICE_TYPE=ble-uart
flutter run --dart-define=OBD_SERVICE_TYPE=bt-serial
flutter run --dart-define=OBD_SERVICE_TYPE=windows-can-bus
```

Supported values: `mock`, `bt-serial`, `windows-can-bus`, `ble-uart`, `auto`.

## Architecture

```
lib/
  main.dart / app.dart
  core/          # theme, debugLog
  domain/        # VehicleData, ObdService, PidParser, elm327/
  data/          # ObdServiceFactory, MockObdService, adapters/ble/, DeferredObdAdapter
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
| Android / iOS | BLE UART | ELM327 BLE / Vgate / similar NUS dongles |
| Windows | USB-CAN (stub) | PCAN-USB, Kvaser |
| Windows | Bluetooth Classic (stub) | Vgate / ELM327 SPS/COM |

## Development

```bash
flutter analyze
flutter test
```

## Roadmap

- Optional Windows CAN (PCAN/Kvaser) via FFI
- Bluetooth Classic serial (ELM) on Windows
- Session history + CSV export
- Settings screen (units, redline, connection prefs)
