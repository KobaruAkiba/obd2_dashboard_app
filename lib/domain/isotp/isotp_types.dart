/// ISO-TP (ISO 15765-2) framing constants and helpers for OBD-II on CAN.
library;

/// Typical 11-bit OBD functional / physical IDs for the engine ECU.
class IsotpAddress {
  IsotpAddress._();

  /// Physical request to engine ECU (common default).
  static const int request = 0x7E0;

  /// Physical response from engine ECU.
  static const int response = 0x7E8;
}

/// PCI (Protocol Control Information) type nibble (upper 4 bits of first byte).
enum IsotpPciType {
  singleFrame(0x0),
  firstFrame(0x1),
  consecutiveFrame(0x2),
  flowControl(0x3);

  const IsotpPciType(this.nibble);
  final int nibble;

  static IsotpPciType? tryParse(int pciByte) {
    final n = (pciByte >> 4) & 0xF;
    for (final t in IsotpPciType.values) {
      if (t.nibble == n) return t;
    }
    return null;
  }
}

/// Flow-control status (lower nibble of FC PCI byte when type is FC).
enum IsotpFlowStatus {
  continueToSend(0x0),
  wait(0x1),
  overflow(0x2);

  const IsotpFlowStatus(this.code);
  final int code;
}

/// A decoded ISO-TP frame sitting in an 8-byte CAN data field.
sealed class IsotpFrame {
  const IsotpFrame();
}

/// Single Frame — payload length 1–7 in lower nibble of PCI.
class IsotpSingleFrame extends IsotpFrame {
  const IsotpSingleFrame({required this.length, required this.payload});

  final int length;
  final List<int> payload;
}

/// First Frame of a multi-frame transfer (total length 8–4095).
class IsotpFirstFrame extends IsotpFrame {
  const IsotpFirstFrame({required this.totalLength, required this.payload});

  final int totalLength;
  final List<int> payload;
}

/// Consecutive Frame — sequence 0–15, up to 7 data bytes.
class IsotpConsecutiveFrame extends IsotpFrame {
  const IsotpConsecutiveFrame({
    required this.sequenceNumber,
    required this.payload,
  });

  final int sequenceNumber;
  final List<int> payload;
}

/// Flow Control — typically sent by the receiver after FF.
class IsotpFlowControl extends IsotpFrame {
  const IsotpFlowControl({
    required this.status,
    required this.blockSize,
    required this.stMin,
  });

  final IsotpFlowStatus status;
  final int blockSize;
  final int stMin;
}

/// Result of assembling one complete ISO-TP message.
class IsotpMessage {
  const IsotpMessage({required this.payload, this.canId});

  final List<int> payload;
  final int? canId;
}
