import 'dart:io';

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb, kDebugMode;

import 'package:odb_dashboard/core/logging/debug_log.dart';
import 'package:odb_dashboard/data/adapters/ble/ble_uart_obd_service.dart';
import 'package:odb_dashboard/data/adapters/bt_serial/bt_serial_obd_service.dart';
import 'package:odb_dashboard/data/adapters/can/can_bus_obd_service.dart';
import 'package:odb_dashboard/data/adapters/deferred_obd_adapter.dart';
import 'package:odb_dashboard/data/mock/mock_obd_service.dart';
import 'package:odb_dashboard/domain/obd/obd_service.dart';
import 'package:odb_dashboard/domain/obd/obd_transport.dart';

/// Selects an [ObdService] from platform and environment configuration.
///
/// Supported `OBD_SERVICE_TYPE` values (via `--dart-define` or env):
/// - `mock` — simulated telemetry
/// - `bt-serial` — real Bluetooth Classic COM/ELM ([BtSerialObdService]) on
///   Windows; [DeferredObdAdapter] elsewhere
/// - `windows-can-bus` — real PCAN ISO-TP ([CanBusObdService]) on Windows;
///   [DeferredObdAdapter] elsewhere
/// - `ble-uart` — real BLE UART ELM327 ([BleUartObdService]) on mobile
/// - unset / `auto` — [BtSerialObdService] on Windows; BLE UART on non-Windows
///
/// `USE_BLUETOOTH_OBD=true` forces the bt-serial path (real on Windows only).
class ObdServiceFactory {
  static const mock = 'mock';
  static const btSerial = 'bt-serial';
  static const windowsCanBus = 'windows-can-bus';
  static const bleUart = 'ble-uart';
  static const auto = 'auto';

  static String? get forcedServiceType {
    const fromDefine = String.fromEnvironment('OBD_SERVICE_TYPE');
    if (fromDefine.isNotEmpty) return fromDefine;
    if (kIsWeb) return null;
    try {
      return Platform.environment['OBD_SERVICE_TYPE'];
    } catch (_) {
      return null;
    }
  }

  static bool get isDebugFlag {
    const fromDefine = String.fromEnvironment('DEBUG');
    if (fromDefine.toLowerCase() == 'true') return true;
    if (kIsWeb) return kDebugMode;
    try {
      final env = Platform.environment['DEBUG'];
      return env != null && env.toLowerCase() == 'true';
    } catch (_) {
      return kDebugMode;
    }
  }

  static bool get isWindows =>
      !kIsWeb &&
      (Platform.isWindows || defaultTargetPlatform == TargetPlatform.windows);

  static bool get wantsBluetooth {
    final type = forcedServiceType;
    if (type == btSerial) return true;
    if (kIsWeb) return false;
    try {
      return Platform.environment['USE_BLUETOOTH_OBD'] == 'true';
    } catch (_) {
      return false;
    }
  }

  /// True only when mock is explicitly forced via define/env.
  static bool get preferMock {
    final type = forcedServiceType;
    if (type == null || type == auto) return false;
    return type == mock;
  }

  /// Creates a service. Pass [useMock] to override compile-time preference
  /// (used by the debug-only mock switch on the dashboard).
  static Future<ObdService> createService({bool? useMock}) async {
    final type = forcedServiceType ?? auto;
    final wantMock = useMock ?? preferMock;
    debugLog(
      '[SERVICE] Creating service type=$type preferMock=$preferMock '
      'useMock=$wantMock',
    );

    if (wantMock) {
      return MockObdService();
    }

    // Explicit bt-serial / USE_BLUETOOTH_OBD — real COM only on Windows.
    if (wantsBluetooth || type == btSerial) {
      if (isWindows) {
        return BtSerialObdService();
      }
      return DeferredObdAdapter(transport: ObdTransport.btSerial);
    }

    if (type == windowsCanBus) {
      if (isWindows) {
        return CanBusObdService();
      }
      return DeferredObdAdapter(transport: ObdTransport.canBus);
    }

    // Real BLE UART on mobile / when explicitly requested.
    if (type == bleUart || (type == auto && !isWindows)) {
      return BleUartObdService();
    }

    // auto on Windows → BT serial ELM (CAN only via windows-can-bus).
    if (isWindows) {
      return BtSerialObdService();
    }

    return BleUartObdService();
  }

  static Map<String, dynamic> getServiceStatus() {
    return {
      'preferMock': preferMock,
      'isWindows': isWindows,
      'isDebugMode': isDebugFlag || kDebugMode,
      'serviceType': forcedServiceType ?? (preferMock ? mock : auto),
      'wantsBluetooth': wantsBluetooth,
    };
  }
}
