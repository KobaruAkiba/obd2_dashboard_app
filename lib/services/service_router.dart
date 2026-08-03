import 'dart:io';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:obd_car_monitor/utils/debug.dart';
import '../services/mock_bluetooth_serial_service.dart';
import '../services/windows_mock_odb_service.dart';
import '../services/windows_can_bus_service.dart';
import '../services/bluetooth_odb_service.dart';
import '../services/windows_bluetooth_serial_service.dart';

/// ServiceRouter intelligently selects the appropriate ODB service based on
/// platform, build type, and available hardware.
class ServiceRouter {
  static const String windowsRealService = 'windows-can-bus';
  static const String mobileBleService = 'ble-uart';
  static const String mockWindowsService = 'mock-windows';
  static const String mockMobileService = 'mock-mobile';
  static const String windowsBtSerialService = 'bt-serial';
  static const String windowsBleService = 'windows-ble';
  static const String windowsCanBusService = 'can-bus';

  /// Environment variable to force specific service type (for testing)
  static String? get forcedServiceType =>
      Platform.environment['OBD_SERVICE_TYPE'];

  /// Whether we should use real hardware or mock data
  static bool get useRealHardware =>
      forcedServiceType == null || forcedServiceType == windowsRealService;

  /// Check if running in debug mode (may affect service selection)
  static bool get isDebugMode {
    final debug = Platform.environment['DEBUG'];
    return debug != null && debug.toString().toLowerCase() == 'true';
  }

  /// Available services with descriptions
  static Map<String, String> get availableServices => {
        windowsRealService: 'Windows PCAN/Kvaser CAN Bus (Real)',
        mobileBleService: 'Mobile BLE UART OBDII (Real)',
        mockWindowsService: 'Windows Mock Data (Development)',
        mockMobileService: 'Mobile Mock Bluetooth (Development)',
      };

  /// Get recommended service for current platform/configuration
  static String getRecommendedService() {
    if (useRealHardware) {
      return useRealHardwareCanBus ? windowsRealService : mobileBleService;
    }

    // Fall back to mock services for development
    final isWindows =
        Platform.isWindows || defaultTargetPlatform == TargetPlatform.windows;
    return isWindows ? mockWindowsService : mockMobileService;
  }

  /// Check if CAN bus service should be used (Windows with physical adapter)
  static bool get useRealHardwareCanBus =>
      useRealHardware && Platform.isWindows ||
      defaultTargetPlatform == TargetPlatform.windows;

  /// Check for physical CAN adapter on Windows/Linux
  static Future<bool> _checkForPhysicalCanAdapter() async {
    if (!Platform.isWindows) return false;

    // Check for PCAN USB device
    try {
      final result = await Process.run('powershell', [
        '-Command',
        'Get-PnpDevice | Where-Object {\$device.Class -eq "CAN-Bus"}'
      ]);

      if (result.exitCode == 0) {
        return result.stdout.toString().isNotEmpty;
      }
    } catch (e) {
      printIfDebug('[SERVICE] Checking for CAN adapter failed: $e');
    }

    // Check for Kvaser device
    try {
      final result = await Process.run('powershell', [
        '-Command',
        'Get-PnpDevice | Where-Object {\$device.FriendlyName -like "*Kvaser*" -or \$device.Class -eq "CAN-Bus"}'
      ]);

      if (result.exitCode == 0) {
        return result.stdout.toString().contains('Kvaser');
      }
    } catch (e) {
      printIfDebug('[SERVICE] Checking for Kvaser adapter failed: $e');
    }

    return false;
  }

  /// Create appropriate service instance based on current configuration
  static dynamic createService() async {
    final serviceType = ServiceRouter.forcedServiceType ?? 'auto';

    // Check if we're explicitly using Bluetooth Serial on Windows
    if (serviceType == windowsBtSerialService) {
      printIfDebug(
          '[SERVICE] Creating Windows Bluetooth Serial Port service for OBD dongle');
      return WindowsBluetoothSerialService();
    }

    // Check auto-detection for Bluetooth on Windows
    if ((Platform.isWindows ||
            defaultTargetPlatform == TargetPlatform.windows) &&
        Platform.environment['USE_BLUETOOTH_OBD'] == 'true') {
      printIfDebug('[SERVICE] Auto-detected request for Bluetooth OBD dongle');
      return WindowsBluetoothSerialService();
    }

    // Standard flow: check real hardware or mock
    if (!useRealHardware) {
      // Use mock services for development/testing
      final isWindows =
          Platform.isWindows || defaultTargetPlatform == TargetPlatform.windows;
      return isWindows ? WindowsMockOdbService() : MockBluetoothSerialService();
    }

    // Real hardware mode - select based on platform and adapter
    if (Platform.isWindows || defaultTargetPlatform == TargetPlatform.windows) {
      final hasPhysicalAdapter = await _checkForPhysicalCanAdapter();

      if (hasPhysicalAdapter) {
        // Use real CAN bus service with physical PCAN/Kvaser
        printIfDebug(
            '[SERVICE] Using REAL CAN Bus - Physical adapter detected');
        return WindowsCanBusService();
      } else {
        // Fall back to virtual CAN tools
        printIfDebug(
            '[SERVICE] No physical CAN adapter - falling back to virtual CAN');

        return WindowsCanBusService(); // Will use virtual mode
      }
    }

    // Mobile platform - use real BLE service
    printIfDebug('[SERVICE] Using REAL BLE UART for mobile');
    return BluetoothOdbService();
  }

  /// Get service status information for debug UI
  static Map<String, dynamic> getServiceStatus() {
    return {
      'useRealHardware': useRealHardware,
      'isWindows':
          Platform.isWindows || defaultTargetPlatform == TargetPlatform.windows,
      'isDebugMode': isDebugMode,
      'serviceType': forcedServiceType ?? getRecommendedService(),
      'recommendedService': getRecommendedService(),
      'availableServices': availableServices,
    };
  }

  /// Get appropriate connect parameters for the service
  static Future<Map<String, dynamic>> getServiceConnectParams() async {
    if (!useRealHardware) {
      return {'mock': true};
    }

    if (Platform.isWindows || defaultTargetPlatform == TargetPlatform.windows) {
      final toolPath = Platform.environment['VIRTUAL_CAN_TOOL'];

      if (toolPath != null && File(toolPath).existsSync()) {
        return {
          'virtualCanTool': toolPath,
          'interface': r'\Device\CAN0',
          'baudRate': 500000,
        };
      }

      final interfaces = await _detectPhysicalInterfaces();

      if (interfaces.isNotEmpty) {
        return {
          'physicalAdapter': interfaces.first,
          'interfaceName': interfaces.first,
          'baudRate': 500000,
        };
      }

      // Default configuration for virtual CAN tools
      return {
        'virtualCanTool': 'C:/Program Files/can-utils/cantool.exe',
        'interface': r'\Device\CAN0',
        'baudRate': 500000,
      };
    }

    // Mobile BLE defaults
    return {
      'deviceId': null,
      'baudRate': 115200,
      'isSoleilx': true,
    };
  }

  /// Detect available CAN interfaces for PCAN/Kvaser
  static Future<List<String>> _detectPhysicalInterfaces() async {
    final List<String> interfaces = [];

    if (Platform.isWindows) {
      try {
        final result = await Process.run('powershell', [
          '-Command',
          'Get-PnpDevice -Class "CAN-Bus" | Select-Object FriendlyName, Status | Format-Table'
        ]);

        if (result.exitCode == 0) {
          interfaces.addAll(
            result.stdout
                .toString()
                .split('\n')
                .where((line) => line.trim().isNotEmpty)
                .map((line) => line.trim()),
          );
        }
      } catch (e) {}
    }

    return interfaces;
  }
}
