import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'package:odb_dashboard/core/connection/connection_error_markers.dart';
import 'package:odb_dashboard/core/logging/debug_log.dart';
import 'package:odb_dashboard/data/adapters/ble/ble_device_filter.dart';
import 'package:odb_dashboard/domain/obd/elm327/elm327_client.dart';

/// flutter_blue_plus wrapper that exposes an [Elm327Uart] over Nordic UART.
class BleUartLink implements Elm327Uart {
  BleUartLink({
    this.scanTimeout = const Duration(seconds: 12),
    this.connectionTimeout = const Duration(seconds: 15),
  });

  final Duration scanTimeout;
  final Duration connectionTimeout;

  final _incomingController = StreamController<List<int>>.broadcast();

  BluetoothDevice? _device;
  BluetoothCharacteristic? _rx;
  BluetoothCharacteristic? _tx;
  StreamSubscription<List<int>>? _notifySub;
  bool _open = false;

  @override
  Stream<List<int>> get incoming => _incomingController.stream;

  bool get isOpen => _open;

  String? get deviceName => _device?.platformName;

  /// Scan for ELM/NUS candidates, connect, discover UART characteristics.
  Future<void> open() async {
    if (_open) return;

    if (await FlutterBluePlus.isSupported == false) {
      throw StateError(
        '${ConnectionErrorMarkers.bleNotSupported} on this device',
      );
    }

    final adapterState = await FlutterBluePlus.adapterState
        .where((s) => s != BluetoothAdapterState.unknown)
        .first
        .timeout(const Duration(seconds: 5));
    if (adapterState != BluetoothAdapterState.on) {
      throw StateError(
        '${ConnectionErrorMarkers.bluetoothOff} — turn it on and retry',
      );
    }

    final device = await _scanForDevice();
    debugLog('[BLE] Connecting to ${device.platformName} ${device.remoteId}');

    await device.connect(
      timeout: connectionTimeout,
      autoConnect: false,
    );
    _device = device;

    final services = await device.discoverServices();
    final pair = BleDeviceFilter.resolveUartCharacteristics(services);
    if (pair == null) {
      await device.disconnect();
      _device = null;
      throw StateError(
        '${ConnectionErrorMarkers.noUartRxTx} characteristics found on device',
      );
    }

    _rx = pair.rx;
    _tx = pair.tx;

    await _tx!.setNotifyValue(true);
    _notifySub = _tx!.onValueReceived.listen((value) {
      if (!_incomingController.isClosed && value.isNotEmpty) {
        _incomingController.add(List<int>.from(value));
      }
    });
    device.cancelWhenDisconnected(_notifySub!);

    _open = true;
    debugLog(
      '[BLE] UART ready rx=${_rx!.uuid} tx=${_tx!.uuid} '
      'name=${device.platformName}',
    );
  }

  @override
  Future<void> write(List<int> data) async {
    final rx = _rx;
    if (!_open || rx == null) {
      throw StateError('BLE UART not open');
    }
    final withoutResponse = rx.properties.writeWithoutResponse;
    await rx.write(data, withoutResponse: withoutResponse);
  }

  Future<void> close() async {
    _open = false;
    await _notifySub?.cancel();
    _notifySub = null;
    try {
      if (_tx != null && _tx!.isNotifying) {
        await _tx!.setNotifyValue(false);
      }
    } catch (_) {}
    _rx = null;
    _tx = null;
    final device = _device;
    _device = null;
    if (device != null) {
      try {
        await device.disconnect();
      } catch (_) {}
    }
  }

  void dispose() {
    unawaited(close());
    if (!_incomingController.isClosed) {
      _incomingController.close();
    }
  }

  Future<BluetoothDevice> _scanForDevice() async {
    debugLog('[BLE] Scanning (${scanTimeout.inSeconds}s)…');
    final seen = <String, ScanResult>{};
    final completer = Completer<BluetoothDevice>();

    late final StreamSubscription<List<ScanResult>> sub;
    sub = FlutterBluePlus.scanResults.listen((results) {
      for (final r in results) {
        seen[r.device.remoteId.str] = r;
        if (!BleDeviceFilter.isCandidate(r)) continue;
        if (!completer.isCompleted) {
          debugLog(
            '[BLE] Candidate ${r.device.platformName} rssi=${r.rssi}',
          );
          completer.complete(r.device);
        }
      }
    });

    try {
      await FlutterBluePlus.startScan(
        timeout: scanTimeout,
        androidUsesFineLocation: true,
      );

      // Prefer early candidate; otherwise pick best RSSI among name/NUS matches
      // after scan window, or strongest overall as last resort.
      final device = await completer.future.timeout(
        scanTimeout + const Duration(seconds: 1),
        onTimeout: () {
          final candidates = seen.values
              .where(BleDeviceFilter.isCandidate)
              .toList()
            ..sort((a, b) => b.rssi.compareTo(a.rssi));
          if (candidates.isNotEmpty) return candidates.first.device;

          final all = seen.values.toList()
            ..sort((a, b) => b.rssi.compareTo(a.rssi));
          if (all.isNotEmpty) {
            debugLog(
              '[BLE] No ELM name/NUS match — trying strongest: '
              '${all.first.device.platformName}',
            );
            return all.first.device;
          }
          throw StateError(
            '${ConnectionErrorMarkers.noBleDevices} during scan',
          );
        },
      );
      return device;
    } finally {
      await FlutterBluePlus.stopScan();
      await sub.cancel();
    }
  }
}
