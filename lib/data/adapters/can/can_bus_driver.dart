import 'package:odb_dashboard/data/adapters/can/can_frame.dart';

/// Platform CAN adapter (PCAN, fake, …).
abstract class CanBusDriver {
  /// Open the channel / interface.
  Future<void> open();

  /// Close and release hardware.
  Future<void> close();

  /// True after a successful [open].
  bool get isOpen;

  /// Non-blocking read; returns `null` when the RX queue is empty.
  Future<CanFrame?> read();

  /// Transmit one frame.
  Future<void> write(CanFrame frame);

  /// Optional status string for diagnostics.
  String get statusDescription => isOpen ? 'open' : 'closed';
}
