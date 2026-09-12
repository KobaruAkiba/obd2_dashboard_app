import 'dart:io';

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb, kDebugMode;

import 'package:odb_dashboard/core/logging/debug_log.dart';
import 'package:odb_dashboard/data/adapters/ble/ble_uart_obd_service.dart';
import 'package:odb_dashboard/data/adapters/deferred_obd_adapter.dart';
import 'package:odb_dashboard/data/mock/mock_obd_service.dart';
import 'package:odb_dashboard/domain/obd/obd_service.dart';
import 'package:odb_dashboard/domain/obd/obd_transport.dart';

/// Selects an [ObdService] from platform and environment configuration.
///
/// Supported `OBD_SERVICE_TYPE` values (via `--dart-define` or env):
/// - `mock` — simulated telemetry
/// - `bt-serial` — Bluetooth serial stub ([DeferredObdAdapter])
/// - `windows-can-bus` — CAN bus stub ([DeferredObdAdapter])
/// - `ble-uart` — real BLE UART ELM327 ([BleUartObdService]) on mobile
/// - unset / `auto` — BLE UART on non-Windows; CAN stub on Windows
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

    if (wantsBluetooth || type == btSerial) {
      return DeferredObdAdapter(transport: ObdTransport.btSerial);
    }

    if (type == windowsCanBus) {
      return DeferredObdAdapter(transport: ObdTransport.canBus);
    }

    // Real BLE UART on mobile / when explicitly requested.
    // Windows auto stays on deferred CAN — FBP BLE on Windows is unreliable.
    if (type == bleUart || (type == auto && !isWindows)) {
      return BleUartObdService();
    }

    if (isWindows) {
      return DeferredObdAdapter(transport: ObdTransport.canBus);
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
