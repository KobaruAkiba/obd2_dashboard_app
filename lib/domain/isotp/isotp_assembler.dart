import 'package:odb_dashboard/domain/isotp/isotp_types.dart';

/// Parses and assembles ISO-TP frames from 8-byte CAN data fields.
///
/// Handles SF (complete in one frame) and FF+CF multi-frame with basic
/// sequence checking. Flow-control generation is exposed separately for
/// the client to transmit.
class IsotpAssembler {
  List<int>? _pending;
  int _expectedLen = 0;
  int _nextSeq = 1;
  bool _awaitingFc = false;

  /// True while a multi-frame transfer is in progress.
  bool get isAssembling => _pending != null;

  /// True after FF when the peer expects a Flow Control frame.
  bool get needsFlowControl => _awaitingFc;

  /// Reset any in-progress multi-frame state.
  void reset() {
    _pending = null;
    _expectedLen = 0;
    _nextSeq = 1;
    _awaitingFc = false;
  }

  /// Decode a single CAN data field (up to 8 bytes) into an [IsotpFrame].
  static IsotpFrame? parseFrame(List<int> data) {
    if (data.isEmpty) return null;
    final pci = data[0] & 0xFF;
    final type = IsotpPciType.tryParse(pci);
    if (type == null) return null;

    switch (type) {
      case IsotpPciType.singleFrame:
        final len = pci & 0x0F;
        if (len == 0 || len > 7 || data.length < 1 + len) return null;
        return IsotpSingleFrame(
          length: len,
          payload: List<int>.unmodifiable(data.sublist(1, 1 + len)),
        );
      case IsotpPciType.firstFrame:
        if (data.length < 2) return null;
        final total = ((pci & 0x0F) << 8) | (data[1] & 0xFF);
        if (total < 8) return null;
        final avail = data.length - 2;
        final take = avail.clamp(0, 6);
        return IsotpFirstFrame(
          totalLength: total,
          payload: List<int>.unmodifiable(data.sublist(2, 2 + take)),
        );
      case IsotpPciType.consecutiveFrame:
        final seq = pci & 0x0F;
        final payload = data.length > 1
            ? List<int>.unmodifiable(data.sublist(1))
            : const <int>[];
        return IsotpConsecutiveFrame(sequenceNumber: seq, payload: payload);
      case IsotpPciType.flowControl:
        if (data.length < 3) return null;
        final statusCode = pci & 0x0F;
        IsotpFlowStatus? status;
        for (final s in IsotpFlowStatus.values) {
          if (s.code == statusCode) {
            status = s;
            break;
          }
        }
        if (status == null) return null;
        return IsotpFlowControl(
          status: status,
          blockSize: data[1] & 0xFF,
          stMin: data[2] & 0xFF,
        );
    }
  }

  /// Feed one CAN data field. Returns a complete message when assembly finishes.
  IsotpMessage? feed(List<int> data, {int? canId}) {
    final frame = parseFrame(data);
    if (frame == null) return null;

    switch (frame) {
      case IsotpSingleFrame(:final payload):
        reset();
        return IsotpMessage(payload: List<int>.from(payload), canId: canId);

      case IsotpFirstFrame(:final totalLength, :final payload):
        _pending = List<int>.from(payload);
        _expectedLen = totalLength;
        _nextSeq = 1;
        _awaitingFc = true;
        if (_pending!.length >= _expectedLen) {
          final done = _pending!.sublist(0, _expectedLen);
          reset();
          return IsotpMessage(payload: done, canId: canId);
        }
        return null;

      case IsotpConsecutiveFrame(:final sequenceNumber, :final payload):
        if (_pending == null) return null;
        if (sequenceNumber != (_nextSeq & 0x0F)) {
          reset();
          return null;
        }
        _pending!.addAll(payload);
        _nextSeq = (_nextSeq + 1) & 0x0F;
        if (_pending!.length >= _expectedLen) {
          final done = _pending!.sublist(0, _expectedLen);
          reset();
          return IsotpMessage(payload: done, canId: canId);
        }
        return null;

      case IsotpFlowControl():
        // Receiver FC — not part of payload assembly on the requestor side.
        return null;
    }
  }

  /// Build an 8-byte Flow Control ContinuetoSend frame (BS=0, STmin=0).
  static List<int> buildFlowControl({
    IsotpFlowStatus status = IsotpFlowStatus.continueToSend,
    int blockSize = 0,
    int stMin = 0,
  }) {
    return [
      0x30 | (status.code & 0x0F),
      blockSize & 0xFF,
      stMin & 0xFF,
      0,
      0,
      0,
      0,
      0,
    ];
  }

  /// Encode [payload] as one or more ISO-TP CAN data fields (SF or FF+CF).
  ///
  /// Does not insert wait-for-FC between FF and CF — the caller / client
  /// should wait for Flow Control when [needsPeerFlowControl] is true.
  static List<List<int>> encode(List<int> payload) {
    if (payload.isEmpty || payload.length > 4095) {
      throw ArgumentError('ISO-TP payload length must be 1–4095');
    }

    if (payload.length <= 7) {
      final frame = List<int>.filled(8, 0);
      frame[0] = payload.length & 0x0F;
      for (var i = 0; i < payload.length; i++) {
        frame[1 + i] = payload[i] & 0xFF;
      }
      return [frame];
    }

    final frames = <List<int>>[];
    final ff = List<int>.filled(8, 0);
    ff[0] = 0x10 | ((payload.length >> 8) & 0x0F);
    ff[1] = payload.length & 0xFF;
    const firstTake = 6;
    for (var i = 0; i < firstTake; i++) {
      ff[2 + i] = payload[i] & 0xFF;
    }
    frames.add(ff);

    var offset = firstTake;
    var seq = 1;
    while (offset < payload.length) {
      final cf = List<int>.filled(8, 0);
      cf[0] = 0x20 | (seq & 0x0F);
      final take = (payload.length - offset).clamp(0, 7);
      for (var i = 0; i < take; i++) {
        cf[1 + i] = payload[offset + i] & 0xFF;
      }
      frames.add(cf);
      offset += take;
      seq = (seq + 1) & 0x0F;
    }
    return frames;
  }

  /// True when [encode] produced a First Frame (peer must send FC).
  static bool needsPeerFlowControl(List<int> payload) => payload.length > 7;
}
