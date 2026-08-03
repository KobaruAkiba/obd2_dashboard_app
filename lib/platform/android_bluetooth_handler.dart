import 'dart:async';
import 'package:flutter/services.dart';
import 'package:obd_car_monitor/utils/debug.dart';

/// Android platform-specific Bluetooth Serial handler
class AndroidBluetoothHandler {
  static const platform = MethodChannel('obd_bluetooth/android');
  static const eventChannel = EventChannel('obd_bluetooth/data_stream');

  late Stream<dynamic> _dataStream;

  AndroidBluetoothHandler._();

  /// Discover available Bluetooth devices for OBDII dongle pairing
  dynamic discoverBluetoothDevices() async {
    dynamic result = await platform.invokeMethod('discover_devices');
    return result;
  }

  /// Connect to discovered Soleilx OBDII device
  Future<void> connectToDevice(String deviceId) async {
    try {
      // Parse Bluetooth MAC address and service UUID
      final macAddress = _parseMacAddress(deviceId);

      await platform.invokeMethod('connect', {
        'mac': macAddress,
        'serviceUuid': '0000110a-0000-1000-8000-00805f9b34fb',
        'baudRate': 115200,
      });
      printIfDebug('Connected to Bluetooth OBDII dongle: $deviceId');
    } catch (e) {
      printIfDebug('Connection failed: $e');
      rethrow;
    }
  }

  /// Parse Bluetooth device ID to MAC address format
  String _parseMacAddress(String deviceId) {
    // Remove colons and convert to standard format
    final clean = deviceId.replaceAll(':', '');

    if (clean.length == 12) {
      return '${clean.substring(0, 2)}:'
          '${clean.substring(2, 4)}:'
          '${clean.substring(4, 6)}:'
          '${clean.substring(6, 8)}:'
          '${clean.substring(8, 10)}:'
          '${clean.substring(10, 12)}';
    }

    return deviceId;
  }

  /// Disconnect from current device
  Future<void> disconnect() async {
    await platform.invokeMethod('disconnect');
    printIfDebug('Disconnected from Bluetooth OBDII dongle');
  }

  /// Receive incoming data stream
  Stream<dynamic> get receiveStream => _dataStream;

  /// Set up initial data stream listener
  Future<void> initDataStream() async {
    await platform.invokeMethod('enable_streaming');

    _dataStream = eventChannel.receiveBroadcastStream();
    _dataStream.listen((dynamic data) {
      if (data is List && data.isNotEmpty) {
        // Filter out garbage bytes for OBDII protocol
        final cleanBytes = data
            .where((dynamic byte) => byte is int && byte >= 32 && byte <= 127)
            .toList();

        // Forward clean bytes to main app
        if (cleanBytes.isNotEmpty) {
          platform.invokeMethod('emit_data', {'bytes': cleanBytes});
        }
      }
    },
        onError: (dynamic error, [stackTrace]) =>
            {printIfDebug('Data stream error: $error')});

    printIfDebug('Data stream initialized');
  }

  /// Send raw OBDII query command
  Future<void> sendQuery(String command) async {
    await platform.invokeMethod('send_query', {'command': command});
  }

  /// Initialize Bluetooth Serial service on Android
  Future<bool> initialize() async {
    // Check if Bluetooth is enabled and permission granted
    final bluetoothEnabled =
        await platform.invokeMethod('is_bluetooth_enabled');
    final permissionsGranted = await platform.invokeMethod('check_permissions');

    if (bluetoothEnabled != true || permissionsGranted != true) {
      printIfDebug('Android: Bluetooth or permissions not ready');
      return false;
    }

    // Start discovery mode
    await platform.invokeMethod('start_discovery');

    return true;
  }

  /// Get current connection status from Android side
  Future<bool> getConnectionStatus() async {
    dynamic result = await platform.invokeMethod('get_connection_status');
    return (result as bool?) ?? false;
  }

  /// Send ISO-TP frame (Layer 1 message)
  Future<void> sendIsoTpFrame({
    required int messageType,
    required String payload,
  }) async {
    await platform.invokeMethod('send_iso_tp', {
      'messageType': messageType,
      'payload': payload,
    });
  }

  /// Handle incoming ISO-TP frame from OBDII ECU
  Future<void> onIsoTpFrameReceived({
    required String messageType,
    required List<int> data,
  }) async {
    await platform.invokeMethod('handle_iso_tp_response', {
      'messageType': messageType,
      'data': data,
    });
  }

  /// Dispose resources when widget is removed
  Future<void> dispose() async {
    await disconnect();
  }
}

/// Platform channel delegates for Android native code integration
class PlatformChannelDelegates {
  static const _delegate = MethodChannel('obd_bluetooth/android_delegates');

  /// Handle connection events from Android side
  static Future<void> onConnectionChanged(bool connected) async {
    await _delegate
        .invokeMethod('connection_changed', {'connected': connected});
  }

  /// Handle discovery events
  static Future<void> onDiscoveryCompleted(
      List<Map<String, dynamic>> devices) async {
    await _delegate.invokeMethod('discovery_completed', {'devices': devices});
  }

  /// Send error notifications from Android native code
  static Future<void> onError(String error) async {
    await _delegate.invokeMethod('error_occurred', {'message': error});
  }
}
