import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:serial_port_win32/serial_port_win32.dart';

import 'package:odb_dashboard/core/connection/connection_error_markers.dart';
import 'package:odb_dashboard/core/logging/debug_log.dart';
import 'package:odb_dashboard/data/adapters/bt_serial/bt_serial_config.dart';
import 'package:odb_dashboard/data/adapters/bt_serial/bt_serial_port_resolver.dart';
import 'package:odb_dashboard/domain/obd/elm327/elm327_client.dart';

/// Windows COM / Bluetooth SPP pipe that exposes [Elm327Uart].
///
/// Pair the dongle in the OS first; this link opens the resulting COMx at
/// 9600 8N1. On non-Windows, [open] throws a clear [StateError].
class BtSerialLink implements Elm327Uart {
  BtSerialLink({
    BtSerialPortResolver? resolver,
    this.readChunkSize = BtSerialConfig.readChunkSize,
    this.readPollInterval = BtSerialConfig.readPollInterval,
  }) : _resolver = resolver ?? BtSerialPortResolver();

  final BtSerialPortResolver _resolver;
  final int readChunkSize;
  final Duration readPollInterval;

  final _incomingController = StreamController<List<int>>.broadcast();

  SerialPort? _port;
  String? _portName;
  bool _open = false;
  bool _pumping = false;

  @override
  Stream<List<int>> get incoming => _incomingController.stream;

  bool get isOpen => _open;

  /// Resolved COM name after a successful [open] (e.g. `COM5`).
  String? get portName => _portName;

  /// Open the configured / auto-detected COM port and start the read pump.
  Future<void> open() async {
    if (_open) return;

    if (kIsWeb || !Platform.isWindows) {
      throw StateError(
        'BT serial (COM) is ${ConnectionErrorMarkers.btSerialWindowsOnly}. '
        'Use ble-uart on Android/iOS, or mock for UI development.',
      );
    }

    final name = _resolver.resolve();
    debugLog('[BT-SERIAL] Opening $name @ ${BtSerialConfig.baudRate} 8N1');

    final port = SerialPort(
      name,
      BaudRate: BtSerialConfig.baudRate,
      ByteSize: BtSerialConfig.dataBits,
      openNow: false,
    );

    await port.open();
    _port = port;
    _portName = name;
    _open = true;
    unawaited(_readPump());
    debugLog('[BT-SERIAL] UART ready on $name');
  }

  @override
  Future<void> write(List<int> data) async {
    final port = _port;
    if (!_open || port == null) {
      throw StateError(ConnectionErrorMarkers.btSerialNotOpen);
    }
    final ok = await port.writeBytesFromUint8List(
      Uint8List.fromList(data),
      timeout: 1000,
    );
    if (!ok) {
      throw StateError(
        '${ConnectionErrorMarkers.btSerialWriteTimedOut} on $_portName',
      );
    }
  }

  Future<void> close() async {
    _open = false;
    // Let the pump observe `_open == false` and exit.
    var spins = 0;
    while (_pumping && spins < 50) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      spins++;
    }

    final port = _port;
    _port = null;
    if (port != null) {
      try {
        if (port.isOpened) {
          port.close();
        }
      } catch (_) {
        try {
          port.close();
        } catch (_) {}
      }
    }
    _portName = null;
  }

  void dispose() {
    unawaited(close());
    if (!_incomingController.isClosed) {
      _incomingController.close();
    }
  }

  Future<void> _readPump() async {
    if (_pumping) return;
    _pumping = true;
    try {
      while (_open) {
        final port = _port;
        if (port == null) break;
        try {
          final chunk = await port.readBytes(
            readChunkSize,
            timeout: readPollInterval,
          );
          if (!_open) break;
          if (chunk.isNotEmpty && !_incomingController.isClosed) {
            _incomingController.add(List<int>.from(chunk));
          }
        } catch (e) {
          if (!_open) break;
          debugLog('[BT-SERIAL] read error: $e');
          await Future<void>.delayed(readPollInterval);
        }
      }
    } finally {
      _pumping = false;
    }
  }
}
