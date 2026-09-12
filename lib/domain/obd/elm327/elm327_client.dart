import 'dart:async';
import 'dart:convert';

import 'package:odb_dashboard/core/logging/debug_log.dart';
import 'package:odb_dashboard/domain/models/vehicle_data.dart';
import 'package:odb_dashboard/domain/obd/elm327/elm327_commands.dart';
import 'package:odb_dashboard/domain/obd/elm327/elm327_response_parser.dart';

/// Abstract UART byte pipe — BLE Nordic UART, classic SPP, TCP, etc.
abstract class Elm327Uart {
  /// Incoming bytes from the adapter (may be fragmented).
  Stream<List<int>> get incoming;

  /// Write bytes to the adapter (typically ASCII + CR).
  Future<void> write(List<int> data);
}

/// ELM327 session over any [Elm327Uart]: AT init + Mode $01 PID polling.
///
/// Not coupled to FlutterBluePlus — transport is injected.
class Elm327Client {
  Elm327Client({
    required Elm327Uart uart,
    this.commandTimeout = const Duration(seconds: 3),
    this.pollInterval = const Duration(milliseconds: 200),
    this.resetSettle = const Duration(milliseconds: 1200),
  }) : _uart = uart;

  final Elm327Uart _uart;
  final Duration commandTimeout;
  final Duration pollInterval;
  final Duration resetSettle;

  final _dataController = StreamController<VehicleData>.broadcast();
  final _buffer = StringBuffer();

  StreamSubscription<List<int>>? _rxSub;
  Completer<String>? _pending;
  Timer? _pendingTimer;
  bool _running = false;
  bool _disposed = false;
  VehicleData _latest = const VehicleData();

  /// Live telemetry updates (one snapshot per completed poll cycle).
  Stream<VehicleData> get vehicleData => _dataController.stream;

  VehicleData get latest => _latest;

  /// Subscribe to UART, run AT init, then start the PID poll loop.
  Future<void> start() async {
    if (_disposed) {
      throw StateError('Elm327Client disposed');
    }
    if (_running) return;

    _rxSub ??= _uart.incoming.listen(_onBytes, onError: (Object e) {
      debugLog('[ELM] UART error: $e');
      _failPending(e);
    });

    await _initialize();
    _running = true;
    unawaited(_pollLoop());
  }

  Future<void> stop() async {
    _running = false;
    _failPending(StateError('stopped'));
  }

  void dispose() {
    _disposed = true;
    _running = false;
    _failPending(StateError('disposed'));
    _rxSub?.cancel();
    _rxSub = null;
    _pendingTimer?.cancel();
    _dataController.close();
  }

  Future<void> _initialize() async {
    debugLog('[ELM] AT init…');
    for (final cmd in Elm327Commands.initSequence) {
      final response = await _transact(cmd);
      debugLog('[ELM] $cmd → ${response.replaceAll('\n', ' | ')}');
      if (cmd == Elm327Commands.reset) {
        await Future<void>.delayed(resetSettle);
      }
    }
    debugLog('[ELM] AT init done');
  }

  Future<void> _pollLoop() async {
    while (_running && !_disposed) {
      var frame = _latest;
      for (final cmd in Elm327Commands.pollPids) {
        if (!_running || _disposed) break;
        try {
          final raw = await _transact(cmd);
          final pid = int.parse(cmd.substring(2), radix: 16);
          frame = Elm327ResponseParser.applyRaw(frame, raw, expectedPid: pid);
        } catch (e) {
          debugLog('[ELM] poll $cmd failed: $e');
        }
        await Future<void>.delayed(pollInterval);
      }
      if (_disposed || _dataController.isClosed) return;
      _latest = frame.copyWith(engineReady: true);
      _dataController.add(_latest);
    }
  }

  Future<String> _transact(String command) async {
    if (_disposed) throw StateError('disposed');
    if (_pending != null) {
      throw StateError('ELM command already in flight');
    }

    final completer = Completer<String>();
    _pending = completer;
    _buffer.clear();

    _pendingTimer?.cancel();
    _pendingTimer = Timer(commandTimeout, () {
      if (!completer.isCompleted) {
        completer.completeError(
          TimeoutException('ELM timeout waiting for $command', commandTimeout),
        );
        _pending = null;
      }
    });

    final payload = utf8.encode('$command\r');
    await _uart.write(payload);

    try {
      return await completer.future;
    } finally {
      _pendingTimer?.cancel();
      _pendingTimer = null;
      if (identical(_pending, completer)) {
        _pending = null;
      }
    }
  }

  void _onBytes(List<int> chunk) {
    if (chunk.isEmpty) return;
    final text = utf8.decode(chunk, allowMalformed: true);
    _buffer.write(text);

    final pending = _pending;
    if (pending == null || pending.isCompleted) return;

    final soFar = _buffer.toString();
    // ELM prompt '>' ends a response; also accept OK-only AT replies.
    if (soFar.contains('>')) {
      final body = soFar.split('>').first;
      _buffer.clear();
      pending.complete(body);
      _pending = null;
      _pendingTimer?.cancel();
    }
  }

  void _failPending(Object error) {
    final pending = _pending;
    if (pending != null && !pending.isCompleted) {
      pending.completeError(error);
    }
    _pending = null;
    _pendingTimer?.cancel();
  }
}
