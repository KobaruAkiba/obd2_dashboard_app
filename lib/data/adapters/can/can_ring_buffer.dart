import 'package:odb_dashboard/data/adapters/can/can_frame.dart';

/// Single-producer / single-consumer fixed-size ring of [CanFrame].
///
/// When full, the oldest frame is dropped and [droppedFrames] increments.
class CanRingBuffer {
  CanRingBuffer(this.capacity)
      : assert(capacity > 0),
        _slots = List<CanFrame?>.filled(capacity, null);

  final int capacity;
  final List<CanFrame?> _slots;
  int _head = 0; // next write
  int _tail = 0; // next read
  int _length = 0;
  int droppedFrames = 0;

  int get length => _length;
  bool get isEmpty => _length == 0;
  bool get isFull => _length == capacity;

  /// Push [frame]; drops oldest if full.
  void push(CanFrame frame) {
    if (isFull) {
      _slots[_tail] = null;
      _tail = (_tail + 1) % capacity;
      _length--;
      droppedFrames++;
    }
    _slots[_head] = frame;
    _head = (_head + 1) % capacity;
    _length++;
  }

  /// Pop oldest frame, or `null` if empty.
  CanFrame? pop() {
    if (isEmpty) return null;
    final frame = _slots[_tail];
    _slots[_tail] = null;
    _tail = (_tail + 1) % capacity;
    _length--;
    return frame;
  }

  void clear() {
    for (var i = 0; i < capacity; i++) {
      _slots[i] = null;
    }
    _head = 0;
    _tail = 0;
    _length = 0;
  }
}
