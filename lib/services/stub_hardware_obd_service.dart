import 'dart:async';

import '../models/vehicle_data.dart';
import 'mock_obd_service.dart';
import 'obd_service.dart';

/// Placeholder for real BLE / BT-serial / CAN adapters.
///
/// Today it delegates to [MockObdService] so the UI stays wired to one
/// [ObdService] contract. Replace the inner implementation when native
/// adapters are ready.
class StubHardwareObdService implements ObdService {
  StubHardwareObdService({
    required this.displayName,
    this.connectionDelay = const Duration(milliseconds: 800),
  });

  @override
  final String displayName;

  final Duration connectionDelay;
  final MockObdService _inner = MockObdService(cycleMs: 1800);
  final _stateController = StreamController<ObdConnectionState>.broadcast();
  bool _disposed = false;

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
