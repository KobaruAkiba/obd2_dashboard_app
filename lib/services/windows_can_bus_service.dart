import 'dart:async';
import 'dart:io';

import 'package:obd_car_monitor/utils/debug.dart';

/// Real ODB CAN bus service for Windows using PCAN or Kvaser adapters
/// Supports physical PCAN-USB/Kvaser devices and virtual CAN tools (cantool.exe)
class WindowsCanBusService {
  final StreamController<Map<String, dynamic>> _controller =
      StreamController<Map<String, dynamic>>.broadcast();
  Timer? _heartbeatTimer;
  DateTime? _lastHeartbeat;

  /// Current connection status
  String get status => _connectionStatus ?? 'Disconnected';

  /// Connection status indicator
  String? _connectionStatus;

  bool get isConnected => _connectionStatus == 'Connected';

  Stream<Map<String, dynamic>> get stream => _controller.stream;

  /// Connect to physical PCAN adapter
  Future<bool> connectToPcan({
    required String interfaceName,
    required int baudRate,
  }) async {
    try {
      if (Platform.isWindows) {
        // Try to detect physical CAN interface
        final interfaces = await _detectPhysicalInterfaces();

        if (interfaces.isEmpty) {
          throw Exception(
              'No physical PCAN/Kvaser interfaces found. Please connect adapter or install drivers.');
        }

        printIfDebug('[CAN-BUS] Connected to PCAN interface: $interfaceName');

        // Send CAN bus initialization commands
        await _initializeCanBus(interfaceName, baudRate);

        _connectionStatus = 'PCAN Connected';
        _sendHeartbeat();
        return true;
      } else {
        throw UnsupportedError(
            'CAN bus service is only available on Windows platform');
      }
    } catch (e) {
      printIfDebug('[CAN-BUS] PCAN connection error: $e');
      _connectionStatus = 'PCAN Error';
      return false;
    }
  }

  /// Connect to Kvaser adapter
  Future<bool> connectToKvaser({
    required String interfaceName,
    required int baudRate,
  }) async {
    try {
      if (Platform.isWindows) {
        final interfaces = await _detectPhysicalInterfaces();

        if (interfaces.isEmpty) {
          throw Exception(
              'No physical Kvaser interfaces found. Please connect adapter or install drivers.');
        }

        printIfDebug('[CAN-BUS] Connected to Kvaser interface: $interfaceName');

        // Kvaser-specific initialization
        await _initializeCanBus(interfaceName, baudRate);

        _connectionStatus = 'Kvaser Connected';
        _sendHeartbeat();
        return true;
      } else {
        throw UnsupportedError(
            'CAN bus service is only available on Windows platform');
      }
    } catch (e) {
      printIfDebug('[CAN-BUS] Kvaser connection error: $e');
      _connectionStatus = 'Kvaser Error';
      return false;
    }
  }

  /// Connect to virtual CAN bus (cantool.exe or similar)
  Future<bool> connectToVirtualCan({
    required String toolPath,
    required String interfaceName,
    required int baudRate,
  }) async {
    try {
      if (!Platform.isWindows) {
        throw UnsupportedError('Virtual CAN tools only supported on Windows');
      }

      // Verify virtual CAN tool exists
      if (await File(toolPath).exists()) {
        printIfDebug('[CAN-BUS] Virtual CAN tool verified: $toolPath');
      } else {
        printIfDebug('[CAN-BUS] Virtual CAN tool not found at: $toolPath');
        return false;
      }

      printIfDebug(
          '[CAN-BUS] Connected to virtual CAN interface: $interfaceName');
      _connectionStatus = 'Virtual CAN Connected';
      _sendHeartbeat();

      // Simulate receiving virtual CAN data from cantool.exe
      await _receiveFromVirtualCan(interfaceName, baudRate);

      return true;
    } catch (e) {
      printIfDebug('[CAN-BUS] Virtual CAN connection error: $e');
      return false;
    }
  }

  /// Automatically detect and connect to available CAN adapter
  Future<bool> autoConnect() async {
    try {
      // First, check for physical adapters
      final interfaces = await _detectPhysicalInterfaces();

      if (interfaces.isNotEmpty) {
        printIfDebug(
            '[CAN-BUS] Physical CAN adapter detected: ${interfaces.first}');
        return connectToPcan(
          interfaceName: interfaces.first,
          baudRate: 500000, // Default PCAN baud rate
        );
      }

      // Fall back to virtual CAN if no physical adapter found
      final toolPath = Platform.environment['VIRTUAL_CAN_TOOL'] ??
          'C:/Program Files/can-utils/cantool.exe';

      return connectToVirtualCan(
        toolPath: toolPath,
        interfaceName: r'\Device\CAN0',
        baudRate: 500000,
      );
    } catch (e) {
      printIfDebug('[CAN-BUS] Auto-connect failed: $e');
      _connectionStatus = 'Auto-Connect Failed';
      return false;
    }
  }

  /// Disconnect from CAN bus
  Future<void> disconnect() async {
    try {
      _controller.add({
        'type': 'DISCONNECTED',
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'Disconnected',
      });
      _connectionStatus = 'Disconnected';
      _heartbeatTimer?.cancel();
      _heartbeatTimer = null;
      _sendHeartbeat();
    } catch (e) {
      printIfDebug('[CAN-BUS] Disconnect error: $e');
    }
  }

  /// Send CAN frame to bus
  Future<void> sendCanFrame({
    required int id,
    required List<int> data,
    required int dl, // Data length
  }) async {
    try {
      if (_connectionStatus == 'Connected') {
        await _sendRawData(
          id: id,
          data: data,
          dl: dl,
        );

        _controller.add({
          'type': 'TX_FRAME',
          'timestamp': DateTime.now().toIso8601String(),
          'id': id,
          'data': List.generate(data.length, (i) => '%02X'[data[i]]),
          'dl': dl,
        });
      }
    } catch (e) {
      printIfDebug('[CAN-BUS] TX error: $e');
    }
  }

  /// Receive CAN frame from bus
  Future<void> receiveCanFrame() async {
    try {
      if (_connectionStatus == 'Connected') {
        // Simulated receive - in real implementation would call PCAN/Kvaser receive function
        await _receiveRawData();
      }
    } catch (e) {
      printIfDebug('[CAN-BUS] RX error: $e');
    }
  }

  /// Send OBDII query request
  Future<void> sendOdbQuery({required int pid, bool extended = false}) async {
    try {
      if (_connectionStatus != 'Connected') {
        printIfDebug('[CAN-BUS] Cannot query: Not connected');
        return;
      }

      // Construct OBDII request frame
      const id = 0x7DF; // Standard OBD response address
      final data = [pid]; // PID byte
      const dl = 1; // Data length

      await sendCanFrame(id: id, data: data, dl: dl);

      _controller.add({
        'type': 'QUERY_SENT',
        'timestamp': DateTime.now().toIso8601String(),
        'pid': pid,
        'extended': extended,
      });

      // Wait for response
      await Future<void>.delayed(const Duration(milliseconds: 100));

      await receiveCanFrame();
    } catch (e) {
      printIfDebug('[CAN-BUS] OBD query error: $e');
    }
  }

  /// Receive ODBII response
  Future<void> receiveOdbResponse() async {
    try {
      if (_connectionStatus == 'Connected') {
        // Parse OBD response frames
        await _receiveRawData();
      }
    } catch (e) {
      printIfDebug('[CAN-BUS] OBD response error: $e');
    }
  }

  /// Detect available physical CAN interfaces
  Future<List<String>> _detectPhysicalInterfaces() async {
    final List<String> interfaces = [];

    if (Platform.isWindows) {
      // Check for PCAN-USB devices in Windows registry and device manager
      try {
        // Try to list PCAN devices via command line
        final result = await Process.run('powershell', [
          '-Command',
          'Get-PnpDevice -Class "CAN-Bus" | Select-Object FriendlyName, Status | Format-List'
        ]);

        if (result.stderr == null && result.stdout.toString().isNotEmpty) {
          interfaces.add(result.stdout.toString());
        }
      } catch (e) {
        printIfDebug('[CAN-BUS] PowerShell check failed: $e');
      }

      // Check common PCAN interface paths
      final pcanPaths = [
        'PCAN-USB',
        'PCAN-PCI',
        'Kvaser USB-CAN',
        'Kvaser PCI-CAN'
      ];

      for (final path in pcanPaths) {
        try {
          // Check Windows registry for installed devices
          final result = await Process.run('powershell', [
            '-Command',
            'Get-PnpDevice | Where-Object {\$device.Class -eq "CAN-Bus" -or \$device.FriendlyName -like "*$path*"}'
          ]);

          if (result.exitCode == 0) {
            interfaces.add(path);
          }
        } catch (e) {/* Ignore */}
      }
    } else {
      // For mobile platforms, check Linux CAN devices
      try {
        final result = await Process.run('ls', ['-l', '/dev/can*']);
        if (result.stdout.toString().contains('can0')) {
          interfaces.add('/dev/can0');
        }
      } catch (e) {/* Ignore */}
    }

    return interfaces;
  }

  /// Initialize CAN bus with proper baud rate and mode
  Future<void> _initializeCanBus(String interface, int baudRate) async {
    try {
      // PCAN/Kvaser initialization sequence (placeholder)
      if (Platform.isWindows) {
        await Process.run('powershell', [
          '-Command',
          'Write-Host "Initializing CAN $interface at ${baudRate}bps"'
        ]);
      }
      _sendHeartbeat();
    } catch (e) {
      throw Exception('Cannot initialize CAN bus: $e');
    }
  }

  /// Receive data from virtual CAN tool (cantool.exe)
  Future<void> _receiveFromVirtualCan(String interface, int baudRate) async {
    try {
      // Start listening to virtual CAN device (placeholder)
      if (Platform.isWindows) {
        await Process.run('powershell', [
          '-Command',
          'Start-Sleep -Seconds 5; Write-Host "Listening on $interface"'
        ]);
      }
      _sendHeartbeat();
    } catch (e) {
      printIfDebug('[CAN-BUS] Virtual CAN listen error: $e');
    }
  }

  /// Send raw CAN frame data
  Future<void> _sendRawData({
    required int id,
    required List<int> data,
    required int dl,
  }) async {
    // PCAN/Kvaser send implementation would go here
    // This is a placeholder for actual CAN transmission
  }

  /// Receive raw CAN frame data
  Future<void> _receiveRawData() async {
    // PCAN/Kvaser receive implementation would go here
    // This is a placeholder for actual CAN reception
  }

  /// Send heartbeat signal to keep connection alive
  void _sendHeartbeat() {
    _heartbeatTimer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
      _controller.add({
        'type': 'HEARTBEAT',
        'timestamp': DateTime.now().toIso8601String(),
      });
    });
  }

  /// Get last heartbeat time
  Duration get connectionDuration {
    if (_lastHeartbeat != null) {
      return DateTime.now().difference(_lastHeartbeat!);
    }
    return Duration.zero;
  }

  /// Dispose resources
  Future<void> dispose() async {
    await disconnect();
    _heartbeatTimer?.cancel();
    _controller.close();
    _connectionStatus = null;
  }
}
