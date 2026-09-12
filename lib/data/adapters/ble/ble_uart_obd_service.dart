import 'dart:async';

import 'package:odb_dashboard/core/logging/debug_log.dart';
import 'package:odb_dashboard/data/adapters/ble/ble_permissions.dart';
import 'package:odb_dashboard/data/adapters/ble/ble_uart_link.dart';
import 'package:odb_dashboard/domain/models/vehicle_data.dart';
import 'package:odb_dashboard/domain/obd/elm327/elm327_client.dart';
import 'package:odb_dashboard/domain/obd/obd_service.dart';
import 'package:odb_dashboard/domain/obd/obd_transport.dart';

/// Real BLE UART OBD-II source: scan → Nordic/ELM UART → [Elm327Client].
///
/// On connect failure emits [ObdConnectionState.error] and does **not** fall
/// back to mock data.
class BleUartObdService implements ObdService {
  BleUartObdService({BleUartLink? link}) : _link = link ?? BleUartLink();

  final BleUartLink _link;
  Elm327Client? _client;

  final _dataController = StreamController<VehicleData>.broadcast();
  final _stateController = StreamController<ObdConnectionState>.broadcast();

  StreamSubscription<VehicleData>? _dataSub;
  bool _disposed = false;

  @override
  String get displayName {
    final name = _link.deviceName;
    if (name != null && name.trim().isNotEmpty) {
      return 'BLE UART · $name';
    }
    return ObdTransport.bleUart.displayName;
  }

  @override
  ObdTransport get transport => ObdTransport.bleUart;

  @override
  Stream<VehicleData> get vehicleData => _dataController.stream;

  @override
  Stream<ObdConnectionState> get connectionState => _stateController.stream;

  @override
  Future<void> connect() async {
    if (_disposed) return;
    _stateController.add(ObdConnectionState.connecting);

    try {
      final ok = await BlePermissions.ensure();
      if (!ok) {
        throw StateError('Bluetooth permissions denied');
      }

      await _link.open();
      if (_disposed) {
        await _link.close();
        return;
      }

      final client = Elm327Client(uart: _link);
      _client = client;
      _dataSub = client.vehicleData.listen((data) {
        if (!_disposed && !_dataController.isClosed) {
          _dataController.add(data);
        }
      });

      await client.start();
      if (_disposed) return;

      _stateController.add(ObdConnectionState.connected);
      debugLog('[BLE] ObdService connected ($displayName)');
    } catch (e, st) {
      debugLog('[BLE] connect failed: $e\n$st');
      await _teardownLink();
      if (!_disposed && !_stateController.isClosed) {
        _stateController.add(ObdConnectionState.error);
      }
      // Surface failure to callers; do not silently switch to mock.
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    await _teardownLink();
    if (!_disposed && !_stateController.isClosed) {
      _stateController.add(ObdConnectionState.disconnected);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_teardownLink());
    _dataController.close();
    _stateController.close();
  }

  Future<void> _teardownLink() async {
    await _dataSub?.cancel();
    _dataSub = null;
    _client?.dispose();
    _client = null;
    await _link.close();
  }
}
