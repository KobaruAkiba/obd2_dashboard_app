import 'dart:io';

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb, kDebugMode;

import 'package:obd_car_monitor/utils/debug.dart';

import 'mock_obd_service.dart';
import 'obd_service.dart';
import 'stub_hardware_obd_service.dart';

/// Selects an [ObdService] from platform and environment configuration.
///
/// Supported `OBD_SERVICE_TYPE` values (via `--dart-define` or env):
/// - `mock` / `mock-windows` / `mock-mobile` — simulated telemetry
/// - `bt-serial` / `windows-bluetooth-serial` — Bluetooth serial stub
/// - `windows-can-bus` / `can-bus` — CAN bus stub
/// - `ble-uart` — mobile BLE stub
/// - unset / `auto` — platform hardware stub (mock is a debug UI switch)
class ServiceRouter {
  static const mock = 'mock';
  static const mockWindows = 'mock-windows';
  static const mockMobile = 'mock-mobile';
  static const btSerial = 'bt-serial';
  static const windowsBluetoothSerial = 'windows-bluetooth-serial';
  static const windowsCanBus = 'windows-can-bus';
  static const canBus = 'can-bus';
  static const bleUart = 'ble-uart';

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
    if (type == btSerial || type == windowsBluetoothSerial) return true;
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
    if (type == null || type == 'auto') return false;
    return type == mock || type == mockWindows || type == mockMobile;
  }

  /// Creates a service. Pass [useMock] to override compile-time preference
  /// (used by the debug-only mock switch on the dashboard).
  static Future<ObdService> createService({bool? useMock}) async {
    final type = forcedServiceType ?? 'auto';
    final wantMock = useMock ?? preferMock;
    printIfDebug(
      '[SERVICE] Creating service type=$type preferMock=$preferMock '
      'useMock=$wantMock',
    );

    if (wantMock) {
      return MockObdService();
    }

    if (wantsBluetooth || type == btSerial || type == windowsBluetoothSerial) {
      return StubHardwareObdService(displayName: 'Bluetooth serial (stub)');
    }

    if (type == windowsCanBus || type == canBus) {
      return StubHardwareObdService(displayName: 'CAN bus (stub)');
    }

    if (type == bleUart || !isWindows) {
      return StubHardwareObdService(displayName: 'BLE UART (stub)');
    }

    if (isWindows) {
      return StubHardwareObdService(displayName: 'CAN bus (stub)');
    }

    return StubHardwareObdService(displayName: 'BLE UART (stub)');
  }

  static Map<String, dynamic> getServiceStatus() {
    return {
      'preferMock': preferMock,
      'isWindows': isWindows,
      'isDebugMode': isDebugFlag || kDebugMode,
      'serviceType': forcedServiceType ?? (preferMock ? mock : 'auto'),
      'wantsBluetooth': wantsBluetooth,
    };
  }
}
