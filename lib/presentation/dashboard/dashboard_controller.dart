import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:odb_dashboard/data/obd_service_factory.dart';
import 'package:odb_dashboard/domain/models/connection_mode.dart';
import 'package:odb_dashboard/domain/models/vehicle_data.dart';
import 'package:odb_dashboard/domain/obd/obd_service.dart';
import 'package:odb_dashboard/domain/obd/obd_transport.dart';

/// Owns connection lifecycle and feeds the cockpit UI.
class DashboardController extends ChangeNotifier {
  ObdService? _service;
  StreamSubscription<VehicleData>? _dataSub;
  StreamSubscription<ObdConnectionState>? _stateSub;
  bool _disposed = false;

  VehicleData data = const VehicleData();
  DateTime? lastUpdate;
  ConnectionMode mode = ConnectionMode.connecting;
  String detail = 'Starting OBD service…';
  Map<String, dynamic> serviceInfo = const {};

  /// Debug-only: when true, use [MockObdService] instead of hardware stubs.
  bool useMock = false;
  bool switching = false;

  Future<void> bootstrap() async {
    // Mock is opt-in via the debug switch (or explicit OBD_SERVICE_TYPE=mock).
    useMock = kDebugMode && ObdServiceFactory.preferMock;
    serviceInfo = ObdServiceFactory.getServiceStatus();
    mode = ConnectionMode.connecting;
    detail = 'Selecting data source…';
    _notify();

    try {
      final service = await ObdServiceFactory.createService(useMock: useMock);
      await _attachService(service);
    } catch (_) {
      if (_disposed) return;
      mode = ConnectionMode.error;
      detail = kDebugMode
          ? 'Could not start service. Enable mock to continue.'
          : 'Could not start OBD service.';
      _notify();
    }
  }

  Future<void> onMockChanged(bool enabled) async {
    if (!kDebugMode || switching) return;

    useMock = enabled;
    switching = true;
    mode = ConnectionMode.connecting;
    detail = enabled ? 'Switching to mock…' : 'Switching to hardware stub…';
    _notify();

    try {
      final service = await ObdServiceFactory.createService(useMock: enabled);
      await _attachService(service);
    } catch (_) {
      if (_disposed) return;
      mode = ConnectionMode.error;
      detail = 'Failed to switch data source';
      _notify();
    } finally {
      if (!_disposed) {
        switching = false;
        _notify();
      }
    }
  }

  Future<void> _attachService(ObdService service) async {
    await _dataSub?.cancel();
    await _stateSub?.cancel();
    _service?.dispose();

    _service = service;
    _stateSub = service.connectionState.listen(_onConnectionState);
    _dataSub = service.vehicleData.listen((incoming) {
      if (_disposed) return;
      data = incoming;
      lastUpdate = DateTime.now();
      _notify();
    });

    await service.connect();
    if (_disposed) return;

    mode = _modeFor(service);
    detail = service.displayName;
    serviceInfo = ObdServiceFactory.getServiceStatus();
    _notify();
  }

  ConnectionMode _modeFor(ObdService service) {
    return switch (service.transport) {
      ObdTransport.mock => ConnectionMode.mock,
      ObdTransport.btSerial || ObdTransport.bleUart => ConnectionMode.bluetooth,
      ObdTransport.canBus => ConnectionMode.canBus,
    };
  }

  void _onConnectionState(ObdConnectionState state) {
    if (_disposed) return;
    switch (state) {
      case ObdConnectionState.connecting:
        mode = ConnectionMode.connecting;
        detail = 'Connecting to ${_service?.displayName ?? 'device'}…';
      case ObdConnectionState.connected:
        if (_service != null) {
          mode = _modeFor(_service!);
          detail = _service!.displayName;
        }
      case ObdConnectionState.error:
        mode = ConnectionMode.error;
        detail = 'Connection error';
      case ObdConnectionState.disconnected:
        mode = ConnectionMode.disconnected;
        detail = 'Disconnected';
    }
    _notify();
  }

  String formatLastUpdate() {
    final t = lastUpdate;
    if (t == null) return 'Waiting for data…';
    final diff = DateTime.now().difference(t);
    if (diff.inSeconds < 2) return 'Live';
    if (diff.inSeconds < 60) return 'Updated ${diff.inSeconds}s ago';
    return 'Updated ${diff.inMinutes}m ago';
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _dataSub?.cancel();
    _stateSub?.cancel();
    _service?.dispose();
    super.dispose();
  }
}
