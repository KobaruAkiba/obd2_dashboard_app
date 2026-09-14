import 'dart:async';

import 'package:odb_dashboard/core/connection/connection_error_markers.dart';
import 'package:odb_dashboard/domain/isotp/isotp_assembler.dart';
import 'package:odb_dashboard/domain/isotp/isotp_types.dart';

/// Abstract CAN pipe used by [IsotpClient] (injected for tests / PCAN).
abstract class IsotpCanTransport {
  /// Write an 11-bit CAN frame ([id], up to 8 [data] bytes).
  Future<void> write(int id, List<int> data);

  /// Incoming frames as `(canId, data)`.
  Stream<(int canId, List<int> data)> get frames;
}

/// ISO-TP request/response over a CAN transport.
///
/// Defaults to physical OBD addresses [IsotpAddress.request] /
/// [IsotpAddress.response]. Supports SF and multi-frame with basic FC.
class IsotpClient {
  IsotpClient({
    required IsotpCanTransport transport,
    this.requestId = IsotpAddress.request,
    this.responseId = IsotpAddress.response,
    this.responseTimeout = const Duration(milliseconds: 800),
    this.flowControlTimeout = const Duration(milliseconds: 500),
  }) : _transport = transport;

  final IsotpCanTransport _transport;
  final int requestId;
  final int responseId;
  final Duration responseTimeout;
  final Duration flowControlTimeout;

  final _assembler = IsotpAssembler();
  StreamSubscription<(int, List<int>)>? _sub;
  Completer<List<int>>? _pending;
  Timer? _timer;
  bool _listening = false;

  /// Ensure RX subscription is active.
  void start() {
    if (_listening) return;
    _listening = true;
    _sub = _transport.frames.listen(_onFrame);
  }

  Future<void> stop() async {
    _listening = false;
    _failPending(StateError('IsotpClient stopped'));
    await _sub?.cancel();
    _sub = null;
    _assembler.reset();
  }

  void dispose() {
    unawaited(stop());
  }

  /// Send [payload] and wait for one assembled response from [responseId].
  Future<List<int>> transact(List<int> payload) async {
    start();
    if (_pending != null) {
      throw StateError('ISO-TP transaction already in flight');
    }

    final completer = Completer<List<int>>();
    _pending = completer;
    _assembler.reset();

    _armTimer(responseTimeout);

    final frames = IsotpAssembler.encode(payload);
    await _transport.write(requestId, frames.first);

    if (frames.length > 1) {
      // Wait briefly for FC from peer, then send consecutive frames.
      await Future<void>.delayed(const Duration(milliseconds: 5));
      for (var i = 1; i < frames.length; i++) {
        await _transport.write(requestId, frames[i]);
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }
    }

    try {
      return await completer.future;
    } finally {
      _timer?.cancel();
      _timer = null;
      if (identical(_pending, completer)) {
        _pending = null;
      }
    }
  }

  void _onFrame((int canId, List<int> data) event) {
    final (canId, data) = event;
    if (canId != responseId) return;

    final pending = _pending;
    if (pending == null || pending.isCompleted) return;

    final parsed = IsotpAssembler.parseFrame(data);

    // After FF, send Flow Control ContinuetoSend so the ECU continues.
    if (parsed is IsotpFirstFrame) {
      unawaited(
        _transport.write(
          requestId,
          IsotpAssembler.buildFlowControl(),
        ),
      );
    }

    final msg = _assembler.feed(data, canId: canId);
    if (msg == null) return;

    _timer?.cancel();
    _timer = null;
    pending.complete(List<int>.from(msg.payload));
    _pending = null;
  }

  void _armTimer(Duration d) {
    _timer?.cancel();
    _timer = Timer(d, () {
      final pending = _pending;
      if (pending != null && !pending.isCompleted) {
        pending.completeError(
          TimeoutException(ConnectionErrorMarkers.isotpTimeout, d),
        );
      }
      _pending = null;
      _assembler.reset();
    });
  }

  void _failPending(Object error) {
    final pending = _pending;
    if (pending != null && !pending.isCompleted) {
      pending.completeError(error);
    }
    _pending = null;
    _timer?.cancel();
    _assembler.reset();
  }
}
