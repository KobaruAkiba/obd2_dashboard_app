import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// Nordic UART Service (NUS) UUIDs and ELM327-class device name heuristics.
class BleDeviceFilter {
  BleDeviceFilter._();

  /// Nordic UART Service
  static final Guid uartServiceUuid =
      Guid('6E400001-B5A3-F393-E0A9-E50E24DCCA9E');

  /// NUS RX — phone → device (write / writeWithoutResponse)
  static final Guid uartRxUuid =
      Guid('6E400002-B5A3-F393-E0A9-E50E24DCCA9E');

  /// NUS TX — device → phone (notify)
  static final Guid uartTxUuid =
      Guid('6E400003-B5A3-F393-E0A9-E50E24DCCA9E');

  /// Common advertising / GAP name fragments for ELM327 BLE dongles.
  static const nameHints = <String>[
    'OBD',
    'OBDII',
    'OBD-II',
    'ELM',
    'ELM327',
    'VGATE',
    'VEEPEAK',
    'KONNWEI',
    'CARISTA',
    'FIXD',
    'LELINK',
    'IOS-VLINK',
    'BTSPP',
  ];

  /// True if [name] looks like a typical OBD/ELM BLE adapter.
  static bool matchesName(String? name) {
    if (name == null || name.trim().isEmpty) return false;
    final upper = name.toUpperCase();
    return nameHints.any(upper.contains);
  }

  /// Prefer devices that advertise NUS or match ELM name hints.
  static bool isCandidate(ScanResult result) {
    final adv = result.advertisementData;
    if (adv.serviceUuids.any((u) => u == uartServiceUuid)) return true;
    if (matchesName(adv.advName) || matchesName(result.device.platformName)) {
      return true;
    }
    return false;
  }

  /// Locate NUS RX/TX on [services], with fallback to first writable + notify pair.
  static ({BluetoothCharacteristic rx, BluetoothCharacteristic tx})?
      resolveUartCharacteristics(List<BluetoothService> services) {
    // 1) Canonical Nordic UART
    for (final service in services) {
      if (service.uuid != uartServiceUuid) continue;
      BluetoothCharacteristic? rx;
      BluetoothCharacteristic? tx;
      for (final c in service.characteristics) {
        if (c.uuid == uartRxUuid) rx = c;
        if (c.uuid == uartTxUuid) tx = c;
      }
      if (rx != null && tx != null) return (rx: rx, tx: tx);
    }

    // 2) Fallback: any service with one writable + one notifiable characteristic
    for (final service in services) {
      BluetoothCharacteristic? writable;
      BluetoothCharacteristic? notifiable;
      for (final c in service.characteristics) {
        final props = c.properties;
        if (writable == null &&
            (props.write || props.writeWithoutResponse)) {
          writable = c;
        }
        if (notifiable == null && (props.notify || props.indicate)) {
          notifiable = c;
        }
      }
      if (writable != null &&
          notifiable != null &&
          writable.remoteId == notifiable.remoteId) {
        // Prefer distinct chars when both roles exist on different UUIDs.
        if (writable.uuid != notifiable.uuid) {
          return (rx: writable, tx: notifiable);
        }
      }
    }

    // 3) Last resort: pick first write + first notify across all services
    BluetoothCharacteristic? anyWrite;
    BluetoothCharacteristic? anyNotify;
    for (final service in services) {
      for (final c in service.characteristics) {
        final props = c.properties;
        anyWrite ??=
            (props.write || props.writeWithoutResponse) ? c : null;
        anyNotify ??= (props.notify || props.indicate) ? c : null;
      }
    }
    if (anyWrite != null && anyNotify != null) {
      return (rx: anyWrite, tx: anyNotify);
    }
    return null;
  }
}
