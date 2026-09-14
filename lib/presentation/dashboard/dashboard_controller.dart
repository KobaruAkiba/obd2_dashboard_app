import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:odb_dashboard/core/connection/connection_error_service.dart';
import 'package:odb_dashboard/data/adapters/can/can_config.dart';
import 'package:odb_dashboard/data/obd_service_factory.dart';
import 'package:odb_dashboard/domain/models/connection_mode.dart';
import 'package:odb_dashboard/domain/models/vehicle_data.dart';
import 'package:odb_dashboard/domain/obd/obd_service.dart';
import 'package:odb_dashboard/domain/obd/obd_transport.dart';

/// Owns connection lifecycle and feeds the cockpit UI.
///
/// [notifyListeners] for telemetry is throttled to ~20 Hz
/// ([CanConfig.uiSampleInterval]); [data] always holds the latest sample.
class DashboardController extends ChangeNotifier {
  DashboardController({
    this.uiNotifyInterval = CanConfig.uiSampleInterval,
    ConnectionErrorService connectionErrors = const ConnectionErrorService(),
  }) : _connectionErrors = connectionErrors;

  /// Minimum gap between UI notifications driven by vehicle data.
  final Duration uiNotifyInterval;

  final ConnectionErrorService _connectionErrors;

  ObdService? _service;
  StreamSubscription<VehicleData>? _dataSub;
  StreamSubscription<ObdConnectionState>? _stateSub;
  bool _disposed = false;

  /// Last mapped connect failure; used when [ObdConnectionState.error] arrives
  /// before the [connect] catch runs (stream emits error then rethrows).
  String? _lastErrorDetail;

  VehicleData data = const VehicleData();
  DateTime? lastUpdate;
  ConnectionMode mode = ConnectionMode.connecting;
  String detail = 'Starting OBD service…';
  Map<String, dynamic> serviceInfo = const {};

  /// Debug-only: when true, use [MockObdService] instead of hardware stubs.
  bool useMock = false;
  bool switching = false;

  DateTime? _lastUiNotify;
  bool _pendingUiNotify = false;
  Timer? _uiThrottleTimer;

  /// Debug: coalesced UI notify calls (latest [data] still applied).
  int droppedUiUpdates = 0;

  Future<void> bootstrap() async {
    // Mock is opt-in via the debug switch (or explicit OBD_SERVICE_TYPE=mock).
    useMock = kDebugMode && ObdServiceFactory.preferMock;
    serviceInfo = ObdServiceFactory.getServiceStatus();
    mode = ConnectionMode.connecting;
    detail = 'Selecting data source…';
    _notifyImmediate();

    try {
      final service = await ObdServiceFactory.createService(useMock: useMock);
      await _attachService(service);
    } on Object catch (e) {
      if (_disposed) return;
      _applyConnectionError(e, transport: _service?.transport);
    }
  }

  Future<void> onMockChanged(bool enabled) async {
    if (!kDebugMode || switching) return;

    useMock = enabled;
    switching = true;
    mode = ConnectionMode.connecting;
    detail = enabled ? 'Switching to mock…' : 'Switching to hardware…';
    _notifyImmediate();

    try {
      final service = await ObdServiceFactory.createService(useMock: enabled);
      await _attachService(service);
    } on Object catch (e) {
      if (_disposed) return;
      _applyConnectionError(e, transport: _service?.transport);
    } finally {
      if (!_disposed) {
        switching = false;
        _notifyImmediate();
      }
    }
  }

  Future<void> _attachService(ObdService service) async {
    await _dataSub?.cancel();
    await _stateSub?.cancel();
    _service?.dispose();

    _lastErrorDetail = null;
    _service = service;
    _stateSub = service.connectionState.listen(_onConnectionState);
    _dataSub = service.vehicleData.listen((incoming) {
      if (_disposed) return;
      data = incoming;
      lastUpdate = DateTime.now();
      _notifyThrottled();
    });

    try {
      await service.connect();
    } on Object catch (e) {
      if (_disposed) return;
      _applyConnectionError(e, transport: service.transport);
      return;
    }
    if (_disposed) return;

    _lastErrorDetail = null;
    mode = _modeFor(service);
    detail = service.displayName;
    serviceInfo = ObdServiceFactory.getServiceStatus();
    _notifyImmediate();
  }

  void _applyConnectionError(Object error, {ObdTransport? transport}) {
    final message = _connectionErrors.userMessage(error, transport: transport);
    _lastErrorDetail = message;
    mode = ConnectionMode.error;
    detail = message;
    _notifyImmediate();
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
        _lastErrorDetail = null;
        if (_service != null) {
          mode = _modeFor(_service!);
          detail = _service!.displayName;
        }
      case ObdConnectionState.error:
        mode = ConnectionMode.error;
        // Prefer the mapped text from the connect catch when available;
        // otherwise show a transport-specific fallback (stream emits first).
        detail = _lastErrorDetail ??
            _connectionErrors.fallbackMessage(transport: _service?.transport);
      case ObdConnectionState.disconnected:
        mode = ConnectionMode.disconnected;
        detail = 'Disconnected';
    }
    _notifyImmediate();
  }

  String formatLastUpdate() {
    final t = lastUpdate;
    if (t == null) return 'Waiting for data…';
    final diff = DateTime.now().difference(t);
    if (diff.inSeconds < 2) return 'Live';
    if (diff.inSeconds < 60) return 'Updated ${diff.inSeconds}s ago';
    return 'Updated ${diff.inMinutes}m ago';
  }

  /// Connection / mode changes notify immediately.
  void _notifyImmediate() {
    if (_disposed) return;
    _pendingUiNotify = false;
    _lastUiNotify = DateTime.now();
    notifyListeners();
  }

  /// Telemetry updates: keep latest [data], notify at most ~20 Hz.
  void _notifyThrottled() {
    if (_disposed) return;
    final now = DateTime.now();
    final last = _lastUiNotify;
    if (last == null || now.difference(last) >= uiNotifyInterval) {
      _lastUiNotify = now;
      _pendingUiNotify = false;
      notifyListeners();
      return;
    }

    _pendingUiNotify = true;
    if (kDebugMode) {
      droppedUiUpdates++;
    }
    _uiThrottleTimer ??= Timer(uiNotifyInterval - now.difference(last), () {
      _uiThrottleTimer = null;
      if (_disposed || !_pendingUiNotify) return;
      _pendingUiNotify = false;
      _lastUiNotify = DateTime.now();
      notifyListeners();
    });
  }

  /// Test helper: apply a data sample through the same throttle path as the stream.
  @visibleForTesting
  void debugApplyVehicleData(VehicleData incoming) {
    if (_disposed) return;
    data = incoming;
    lastUpdate = DateTime.now();
    _notifyThrottled();
  }

  @override
  void dispose() {
    _disposed = true;
    _uiThrottleTimer?.cancel();
    _dataSub?.cancel();
    _stateSub?.cancel();
    _service?.dispose();
    super.dispose();
  }
}
