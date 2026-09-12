import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:odb_dashboard/core/logging/debug_log.dart';
import 'package:odb_dashboard/data/adapters/can/can_bus_driver.dart';
import 'package:odb_dashboard/data/adapters/can/can_config.dart';
import 'package:odb_dashboard/data/adapters/can/can_obd_session.dart';
import 'package:odb_dashboard/data/adapters/can/pcan/pcan_driver.dart';
import 'package:odb_dashboard/domain/models/vehicle_data.dart';
import 'package:odb_dashboard/domain/obd/obd_service.dart';
import 'package:odb_dashboard/domain/obd/obd_transport.dart';

/// Windows USB-CAN OBD-II source: PCAN (or injected [CanBusDriver]) → ISO-TP.
///
/// [vehicleData] emits at most ~20 Hz ([CanConfig.uiSampleInterval]), always
/// forwarding the latest snapshot. Inject [driver] / [session] for tests
/// without `PCANBasic.dll`.
class CanBusObdService implements ObdService {
  CanBusObdService({
    CanBusDriver? driver,
    CanObdSession? session,
    this.emitInterval = CanConfig.uiSampleInterval,
  })  : _injectedDriver = driver,
        _injectedSession = session;

  final CanBusDriver? _injectedDriver;
  final CanObdSession? _injectedSession;
  final Duration emitInterval;

  CanBusDriver? _driver;
  CanObdSession? _session;

  final _dataController = StreamController<VehicleData>.broadcast();
  final _stateController = StreamController<ObdConnectionState>.broadcast();

  StreamSubscription<VehicleData>? _sessionSub;
  Timer? _emitTimer;
  VehicleData _latest = const VehicleData();
  bool _hasData = false;
  bool _pendingEmit = false;
  DateTime? _lastEmit;
  bool _disposed = false;

  /// Debug: how many high-rate session updates were coalesced (not emitted).
  int droppedStreamUpdates = 0;

  VehicleData get latestSnapshot => _latest;

  @override
  String get displayName => ObdTransport.canBus.displayName;

  @override
  ObdTransport get transport => ObdTransport.canBus;

  @override
  Stream<VehicleData> get vehicleData => _dataController.stream;

  @override
  Stream<ObdConnectionState> get connectionState => _stateController.stream;

  @override
  Future<void> connect() async {
    if (_disposed) return;
    _stateController.add(ObdConnectionState.connecting);

    try {
      final driver = _injectedDriver ?? PcanDriver();
      _driver = driver;

      if (!driver.isOpen) {
        await driver.open();
      }
      if (_disposed) {
        await driver.close();
        return;
      }

      final session = _injectedSession ??
          CanObdSession(driver: driver, startRxPump: true);
      _session = session;

      _sessionSub = session.vehicleData.listen(_onSessionData);
      await session.start();
      if (_disposed) return;

      _stateController.add(ObdConnectionState.connected);
      debugLog('[CAN] ObdService connected ($displayName)');
    } catch (e, st) {
      debugLog('[CAN] connect failed: $e\n$st');
      await _teardown();
      if (!_disposed && !_stateController.isClosed) {
        _stateController.add(ObdConnectionState.error);
      }
      rethrow;
    }
  }

  /// Debug / tests: push a high-rate sample through the same emit throttle.
  @visibleForTesting
  void debugPushVehicleData(VehicleData data) => _onSessionData(data);

  void _onSessionData(VehicleData data) {
    if (_disposed) return;
    _latest = data;
    _hasData = true;
    _startEmitTimer();

    final now = DateTime.now();
    final last = _lastEmit;
    if (last == null || now.difference(last) >= emitInterval) {
      _emitNow(now);
    } else {
      _pendingEmit = true;
      droppedStreamUpdates++;
    }
  }

  void _startEmitTimer() {
    if (_emitTimer != null || _disposed) return;
    _emitTimer = Timer.periodic(emitInterval, (_) {
      if (_disposed) return;
      if (_pendingEmit && _hasData) {
        _emitNow(DateTime.now());
      }
    });
  }

  void _emitNow(DateTime now) {
    _lastEmit = now;
    _pendingEmit = false;
    if (!_dataController.isClosed) {
      _dataController.add(_latest);
    }
  }

  @override
  Future<void> disconnect() async {
    await _teardown();
    if (!_disposed && !_stateController.isClosed) {
      _stateController.add(ObdConnectionState.disconnected);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_teardown());
    _dataController.close();
    _stateController.close();
  }

  Future<void> _teardown() async {
    _emitTimer?.cancel();
    _emitTimer = null;
    await _sessionSub?.cancel();
    _sessionSub = null;

    // Only dispose session we created (injected session owned by caller/tests).
    if (_injectedSession == null) {
      _session?.dispose();
    } else {
      await _session?.stop();
    }
    _session = null;

    if (_injectedDriver == null) {
      await _driver?.close();
    }
    _driver = null;
  }
}
