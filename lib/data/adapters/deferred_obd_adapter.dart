import 'dart:async';

import 'package:obd_car_monitor/data/mock/mock_obd_service.dart';
import 'package:obd_car_monitor/domain/models/vehicle_data.dart';
import 'package:obd_car_monitor/domain/obd/obd_service.dart';
import 'package:obd_car_monitor/domain/obd/obd_transport.dart';

/// Placeholder for real BLE / BT-serial / CAN adapters.
///
/// Today it delegates to [MockObdService] so the UI stays wired to one
/// [ObdService] contract. Replace the inner implementation when native
/// adapters are ready.
class DeferredObdAdapter implements ObdService {
  DeferredObdAdapter({
    required this.transport,
    this.connectionDelay = const Duration(milliseconds: 800),
  }) : assert(transport != ObdTransport.mock);

  @override
  final ObdTransport transport;

  final Duration connectionDelay;
  final MockObdService _inner = MockObdService(cycleMs: 1800);
  final _stateController = StreamController<ObdConnectionState>.broadcast();
  bool _disposed = false;

  @override
  String get displayName => transport.displayName;

  @override
  Stream<VehicleData> get vehicleData => _inner.vehicleData;

  @override
  Stream<ObdConnectionState> get connectionState => _stateController.stream;

  @override
  Future<void> connect() async {
    if (_disposed) return;
    _stateController.add(ObdConnectionState.connecting);
    await Future<void>.delayed(connectionDelay);
    if (_disposed) return;
    await _inner.connect();
    _stateController.add(ObdConnectionState.connected);
  }

  @override
  Future<void> disconnect() async {
    await _inner.disconnect();
    if (!_stateController.isClosed) {
      _stateController.add(ObdConnectionState.disconnected);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _inner.dispose();
    _stateController.close();
  }
}
