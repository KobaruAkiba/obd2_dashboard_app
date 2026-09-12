import 'dart:async';
import 'dart:collection';

import 'package:odb_dashboard/data/adapters/can/can_bus_driver.dart';
import 'package:odb_dashboard/data/adapters/can/can_frame.dart';
import 'package:odb_dashboard/domain/isotp/isotp_types.dart';

/// Scriptable [CanBusDriver] for unit tests — no PCAN DLL required.
///
/// Optionally auto-replies to Mode $01 ISO-TP requests with canned SF
/// responses (useful for session / RPM integration tests).
class FakeCanDriver implements CanBusDriver {
  FakeCanDriver({
    this.autoRespondMode01 = false,
    Map<int, List<int>>? mode01Replies,
  }) : _mode01Replies = {
          0x0C: [0x41, 0x0C, 0x2E, 0xE0], // 3000 RPM
          0x0D: [0x41, 0x0D, 90],
          0x05: [0x41, 0x05, 128],
          0x0F: [0x41, 0x0F, 80],
          0x11: [0x41, 0x11, 128],
          0x2F: [0x41, 0x2F, 200],
          0x42: [0x41, 0x42, 0x33, 0x90],
          ...?mode01Replies,
        };

  final bool autoRespondMode01;
  final Map<int, List<int>> _mode01Replies;
  final Queue<CanFrame> _rx = Queue<CanFrame>();
  final List<CanFrame> written = [];
  bool _open = false;

  /// Enqueue frames that [read] will return (FIFO).
  void enqueue(CanFrame frame) => _rx.add(frame);

  void enqueueAll(Iterable<CanFrame> frames) => _rx.addAll(frames);

  @override
  bool get isOpen => _open;

  @override
  String get statusDescription => _open ? 'fake-open' : 'fake-closed';

  @override
  Future<void> open() async {
    _open = true;
  }

  @override
  Future<void> close() async {
    _open = false;
    _rx.clear();
  }

  @override
  Future<CanFrame?> read() async {
    if (_rx.isEmpty) return null;
    return _rx.removeFirst();
  }

  @override
  Future<void> write(CanFrame frame) async {
    if (!_open) {
      throw StateError('FakeCanDriver is closed');
    }
    written.add(frame);

    if (!autoRespondMode01) return;
    if (frame.id != IsotpAddress.request) return;
    if (frame.data.isEmpty) return;

    // SF request: PCI len, 0x01, pid
    final pci = frame.data[0] & 0xFF;
    if ((pci >> 4) != 0) return; // only SF auto-reply
    final len = pci & 0x0F;
    if (len < 2 || frame.data.length < 3) return;
    if (frame.data[1] != 0x01) return;
    final pid = frame.data[2] & 0xFF;
    final reply = _mode01Replies[pid];
    if (reply == null) return;

    final data = List<int>.filled(8, 0);
    data[0] = reply.length & 0x0F;
    for (var i = 0; i < reply.length && i < 7; i++) {
      data[1 + i] = reply[i];
    }
    _rx.add(
      CanFrame(
        id: IsotpAddress.response,
        data: data,
        timestampMicros: DateTime.now().microsecondsSinceEpoch,
      ),
    );
  }
}
