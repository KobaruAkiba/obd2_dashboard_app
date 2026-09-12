import 'dart:ffi';

import 'package:ffi/ffi.dart';

/// Manual FFI bindings for PEAK PCANBasic.dll (PCAN-Basic C API subset).
///
/// Bound symbols: CAN_Initialize, CAN_Uninitialize, CAN_Read, CAN_Write,
/// CAN_GetStatus.
class PcanBindings {
  PcanBindings._(this._lib);

  final DynamicLibrary _lib;

  late final int Function(
    int channel,
    int btr0btr1,
    int hwType,
    int ioPort,
    int interrupt,
  ) canInitialize = _lib.lookupFunction<
      Uint32 Function(Uint16 channel, Uint16 btr0btr1, Uint8 hwType,
          Uint32 ioPort, Uint16 interrupt),
      int Function(int channel, int btr0btr1, int hwType, int ioPort,
          int interrupt)>('CAN_Initialize');

  late final int Function(int channel) canUninitialize = _lib.lookupFunction<
      Uint32 Function(Uint16 channel),
      int Function(int channel)>('CAN_Uninitialize');

  late final int Function(
    int channel,
    Pointer<TPCANMsg> msg,
    Pointer<TPCANTimestamp> ts,
  ) canRead = _lib.lookupFunction<
      Uint32 Function(
          Uint16 channel, Pointer<TPCANMsg> msg, Pointer<TPCANTimestamp> ts),
      int Function(int channel, Pointer<TPCANMsg> msg,
          Pointer<TPCANTimestamp> ts)>('CAN_Read');

  late final int Function(int channel, Pointer<TPCANMsg> msg) canWrite =
      _lib.lookupFunction<
          Uint32 Function(Uint16 channel, Pointer<TPCANMsg> msg),
          int Function(int channel, Pointer<TPCANMsg> msg)>('CAN_Write');

  late final int Function(int channel) canGetStatus = _lib.lookupFunction<
      Uint32 Function(Uint16 channel),
      int Function(int channel)>('CAN_GetStatus');

  /// Load PCANBasic.dll from the process search path / System32.
  ///
  /// Throws if the DLL is missing — callers must surface a clear connect
  /// failure (no silent mock).
  static PcanBindings load({String dllName = 'PCANBasic.dll'}) {
    final lib = DynamicLibrary.open(dllName);
    return PcanBindings._(lib);
  }
}

/// TPCANStatus success.
const int pcanErrorOk = 0x00000;

/// Receive queue empty (not a hard failure).
const int pcanErrorQrcvEmpty = 0x00020;

/// Standard (11-bit) message type.
const int pcanMessageStandard = 0x00;

/// PCAN message structure (packed as used by PCAN-Basic on Windows).
final class TPCANMsg extends Struct {
  @Uint32()
  external int id;

  @Uint8()
  external int msgType;

  @Uint8()
  external int len;

  @Array(8)
  external Array<Uint8> data;
}

/// Optional timestamp buffer for CAN_Read.
final class TPCANTimestamp extends Struct {
  @Uint32()
  external int millis;

  @Uint16()
  external int millisOverflow;

  @Uint16()
  external int micros;
}

/// Allocate a [TPCANMsg] on the native heap.
Pointer<TPCANMsg> allocPcanMsg() => calloc<TPCANMsg>();

/// Allocate a [TPCANTimestamp] on the native heap.
Pointer<TPCANTimestamp> allocPcanTimestamp() => calloc<TPCANTimestamp>();
