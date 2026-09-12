import 'dart:async';

import 'package:odb_dashboard/core/logging/debug_log.dart';
import 'package:odb_dashboard/data/adapters/can/can_bus_driver.dart';
import 'package:odb_dashboard/data/adapters/can/can_config.dart';
import 'package:odb_dashboard/data/adapters/can/can_frame.dart';
import 'package:odb_dashboard/data/adapters/can/can_reader_isolate.dart';
import 'package:odb_dashboard/domain/isotp/isotp_client.dart';
import 'package:odb_dashboard/domain/isotp/isotp_types.dart';
import 'package:odb_dashboard/domain/isotp/obd_on_can.dart';
import 'package:odb_dashboard/domain/models/vehicle_data.dart';

/// Adapts [CanBusDriver] (+ optional RX pump) to [IsotpCanTransport].
class _DriverIsotpTransport implements IsotpCanTransport {
  _DriverIsotpTransport(this._driver, this._frameController);

  final CanBusDriver _driver;
  final StreamController<(int, List<int>)> _frameController;

  @override
  Stream<(int canId, List<int> data)> get frames => _frameController.stream;

  @override
  Future<void> write(int id, List<int> data) {
    return _driver.write(CanFrame(id: id, data: List<int>.from(data)));
  }

  void ingest(CanFrame frame) {
    if (_frameController.isClosed) return;
    _frameController.add((frame.id, List<int>.from(frame.data)));
  }
}

/// Polls Mode $01 PIDs via ISO-TP over a [CanBusDriver].
class CanObdSession {
  CanObdSession({
    required CanBusDriver driver,
    CanReaderIsolate? reader,
    this.requestId = IsotpAddress.request,
    this.responseId = IsotpAddress.response,
    this.pollInterval = CanConfig.pidPollInterval,
    this.pids = ObdOnCan.pollPids,
    bool startRxPump = true,
  })  : _driver = driver,
        _reader = reader ?? CanReaderIsolate(),
        _ownsReader = reader == null,
        _startRxPump = startRxPump;

  final CanBusDriver _driver;
  final CanReaderIsolate _reader;
  final bool _ownsReader;
  final bool _startRxPump;

  final int requestId;
  final int responseId;
  final Duration pollInterval;
  final List<int> pids;

  final _dataController = StreamController<VehicleData>.broadcast();
  final _frameController = StreamController<(int, List<int>)>.broadcast();

  late final _DriverIsotpTransport _transport =
      _DriverIsotpTransport(_driver, _frameController);
  late final IsotpClient _isotp = IsotpClient(
    transport: _transport,
    requestId: requestId,
    responseId: responseId,
  );

  StreamSubscription<CanReaderEvent>? _readerSub;
  bool _running = false;
  bool _disposed = false;
  VehicleData _latest = const VehicleData();

  Stream<VehicleData> get vehicleData => _dataController.stream;
  VehicleData get latest => _latest;
  CanReaderIsolate get reader => _reader;

  /// Open path is assumed already [CanBusDriver.open]'d by the service.
  Future<void> start() async {
    if (_disposed) throw StateError('CanObdSession disposed');
    if (_running) return;

    if (_startRxPump) {
      _reader.startLocalPump(_driver);
    }
    _readerSub = _reader.events.listen((event) {
      if (event is CanReaderFrameEvent) {
        _transport.ingest(event.frame);
      }
    });

    _isotp.start();
    _running = true;
    unawaited(_pollLoop());
  }

  Future<void> stop() async {
    _running = false;
    await _isotp.stop();
    await _readerSub?.cancel();
    _readerSub = null;
    _reader.stop();
  }

  void dispose() {
    _disposed = true;
    _running = false;
    unawaited(stop());
    _isotp.dispose();
    if (_ownsReader) {
      _reader.dispose();
    }
    _frameController.close();
    _dataController.close();
  }

  Future<void> _pollLoop() async {
    while (_running && !_disposed) {
      var frame = _latest;
      for (final pid in pids) {
        if (!_running || _disposed) break;
        try {
          final request = ObdOnCan.mode01Request(pid);
          final response = await _isotp.transact(request);
          frame = ObdOnCan.applyResponse(frame, response);
        } catch (e) {
          debugLog('[CAN-OBD] PID 0x${pid.toRadixString(16)} failed: $e');
        }
        await Future<void>.delayed(pollInterval);
      }
      if (_disposed || _dataController.isClosed) return;
      _latest = frame.copyWith(engineReady: true);
      _dataController.add(_latest);
      // Avoid a tight spin when [pids] is empty.
      if (pids.isEmpty) {
        await Future<void>.delayed(pollInterval);
      }
    }
  }
}
