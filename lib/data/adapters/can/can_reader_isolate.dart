import 'dart:async';
import 'dart:isolate';

import 'package:odb_dashboard/data/adapters/can/can_bus_driver.dart';
import 'package:odb_dashboard/data/adapters/can/can_config.dart';
import 'package:odb_dashboard/data/adapters/can/can_frame.dart';
import 'package:odb_dashboard/data/adapters/can/can_ring_buffer.dart';

/// Messages sent from the reader isolate / pump to the main isolate.
sealed class CanReaderEvent {
  const CanReaderEvent();
}

class CanReaderFrameEvent extends CanReaderEvent {
  const CanReaderFrameEvent(this.frame);
  final CanFrame frame;
}

class CanReaderErrorEvent extends CanReaderEvent {
  const CanReaderErrorEvent(this.message);
  final String message;
}

class CanReaderStoppedEvent extends CanReaderEvent {
  const CanReaderStoppedEvent();
}

/// Optional CAN RX helper.
///
/// Prefers [Isolate.spawn] with a [SendPort] when [spawnIsolate] is true and
/// a factory that can construct a driver inside the isolate is provided.
/// On Windows, PCAN FFI can be awkward inside isolates (DLL + isolate memory);
/// use [startLocalPump] to poll [CanBusDriver.read] on a Timer in the current
/// isolate instead — still off the UI rebuild path when driven from a service.
class CanReaderIsolate {
  CanReaderIsolate({
    int ringCapacity = CanConfig.ringCapacity,
  }) : ring = CanRingBuffer(ringCapacity);

  final CanRingBuffer ring;
  final _controller = StreamController<CanReaderEvent>.broadcast();

  Isolate? _isolate;
  ReceivePort? _receivePort;
  StreamSubscription<dynamic>? _sub;
  Timer? _localTimer;
  CanBusDriver? _localDriver;
  bool _running = false;

  Stream<CanReaderEvent> get events => _controller.stream;

  int get droppedFrames => ring.droppedFrames;

  /// Poll [driver] on a periodic timer in this isolate (safe for PCAN FFI).
  void startLocalPump(
    CanBusDriver driver, {
    Duration interval = CanConfig.rxPollInterval,
  }) {
    stop();
    _running = true;
    _localDriver = driver;
    _localTimer = Timer.periodic(interval, (_) => _pumpOnce());
  }

  Future<void> _pumpOnce() async {
    if (!_running) return;
    final driver = _localDriver;
    if (driver == null || !driver.isOpen) return;
    try {
      // Drain a few frames per tick to keep up without blocking forever.
      for (var i = 0; i < 32; i++) {
        final frame = await driver.read();
        if (frame == null) break;
        ring.push(frame);
        if (!_controller.isClosed) {
          _controller.add(CanReaderFrameEvent(frame));
        }
      }
    } catch (e) {
      if (!_controller.isClosed) {
        _controller.add(CanReaderErrorEvent('$e'));
      }
    }
  }

  /// Spawn a background isolate that repeatedly calls [entry] with a SendPort.
  ///
  /// [entry] must be a top-level or static function. Prefer this when the
  /// driver can be opened inside the isolate; otherwise use [startLocalPump].
  Future<void> startIsolate(void Function(SendPort) entry) async {
    stop();
    _running = true;
    _receivePort = ReceivePort();
    _sub = _receivePort!.listen(_onIsolateMessage);
    _isolate = await Isolate.spawn(entry, _receivePort!.sendPort);
  }

  void _onIsolateMessage(dynamic message) {
    if (message is SendPort) {
      // Handshake — isolate ready; no command channel needed for RX-only.
      return;
    }
    if (message is CanFrame) {
      ring.push(message);
      if (!_controller.isClosed) {
        _controller.add(CanReaderFrameEvent(message));
      }
      return;
    }
    if (message is String) {
      if (!_controller.isClosed) {
        _controller.add(CanReaderErrorEvent(message));
      }
    }
  }

  /// Pop next buffered frame (from ring), or `null`.
  CanFrame? popFrame() => ring.pop();

  void stop() {
    _running = false;
    _localTimer?.cancel();
    _localTimer = null;
    _localDriver = null;
    _sub?.cancel();
    _sub = null;
    _receivePort?.close();
    _receivePort = null;
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    if (!_controller.isClosed) {
      _controller.add(const CanReaderStoppedEvent());
    }
  }

  void dispose() {
    stop();
    _controller.close();
  }
}

/// Example isolate entry that echoes nothing useful without a driver factory.
/// Kept as a documented hook for future PCAN-in-isolate setups.
void canReaderIsolateEntry(SendPort mainSend) {
  final reply = ReceivePort();
  mainSend.send(reply.sendPort);
  // Real deployments open the driver here and loop CAN_Read → mainSend.send.
}
