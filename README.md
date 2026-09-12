# OBD Monitor

Flutter app for live **OBD-II vehicle telemetry**. Dark cockpit UI with RPM/speed gauges, temperatures, battery, throttle, fuel, and DTC alerts. All processing stays on-device — no telemetry is sent to servers.

## Current status

| Layer | Reality |
|-------|---------|
| UI dashboard | Working |
| Mock data stream | Working (debug switch on dashboard) |
| BLE UART (ELM327) | Real adapter on Android/iOS (`BleUartObdService`) |
| Bluetooth Classic serial (Windows) | Real COM/ELM adapter (`BtSerialObdService`) |
| Windows USB-CAN | Still deferred stub (`DeferredObdAdapter`) |

## BLE vs BT-serial vs CAN

- **BLE UART**: radio GATT to an ELM327-class dongle (Nordic UART). AT + Mode 01 PIDs; the dongle talks to the vehicle bus.
- **BT serial (Windows)**: Bluetooth Classic SPP after OS pairing → virtual COM port → same ELM AT/PID session.
- **CAN (`windows-can-bus`)**: native USB-CAN frames (PCAN/Kvaser) — **not** implemented yet; still a stub. That path does not use ELM.

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

### Windows Bluetooth serial (ELM)

1. Pair the ELM/OBD/Vgate dongle in **Windows Settings → Bluetooth**.
2. Open **Device Manager → Ports (COM & LPT)** and note the COMx (often “Standard Serial over Bluetooth link”).
3. Run with an explicit port (recommended) or let auto-detect pick BTHENUM/SPP / ELM-like names:

```bash
flutter run -d windows --dart-define=OBD_SERVICE_TYPE=bt-serial --dart-define=OBD_COM_PORT=COM5

# same path via env
set OBD_COM_PORT=COM5
set USE_BLUETOOTH_OBD=true
flutter run -d windows

# auto on Windows selects BtSerialObdService (not CAN)
flutter run -d windows
```

If no COM candidate is found, connect fails with a clear error — no silent mock.

### Windows CAN (still stub)

```bash
flutter run -d windows --dart-define=OBD_SERVICE_TYPE=windows-can-bus
```

## Service selection

By default the app starts on the platform hardware path (`auto`: **bt-serial on Windows**, **BLE UART elsewhere**). In **debug** builds, use the **Mock data** switch on the dashboard for simulated telemetry.

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
  data/          # ObdServiceFactory, MockObdService, adapters/ble/, adapters/bt_serial/, DeferredObdAdapter
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
| Windows | Bluetooth Classic serial | Vgate / ELM327 SPP → COMx |
| Windows | USB-CAN (stub) | PCAN-USB, Kvaser |

## Development

```bash
flutter analyze
flutter test
```

## Roadmap

- Optional Windows CAN (PCAN/Kvaser) via FFI
- Session history + CSV export
- Settings screen (units, redline, connection prefs)
