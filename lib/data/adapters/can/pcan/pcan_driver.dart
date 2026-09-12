import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:odb_dashboard/core/logging/debug_log.dart';
import 'package:odb_dashboard/data/adapters/can/can_bus_driver.dart';
import 'package:odb_dashboard/data/adapters/can/can_config.dart';
import 'package:odb_dashboard/data/adapters/can/can_frame.dart';
import 'package:odb_dashboard/data/adapters/can/pcan/pcan_bindings.dart';

/// [CanBusDriver] backed by PEAK PCAN-Basic (`PCANBasic.dll`).
///
/// If the DLL cannot be loaded or [CAN_Initialize] fails, [open] throws with
/// a clear message — there is **no** silent mock fallback.
class PcanDriver implements CanBusDriver {
  PcanDriver({
    int? channel,
    int? baud,
    PcanBindings? bindings,
    String dllName = 'PCANBasic.dll',
  })  : _channel = channel ??
            CanConfig.channelHandle(CanConfig.resolveChannelName()),
        _baud = baud ?? CanConfig.baudConstant(CanConfig.resolveBitrate()),
        _bindings = bindings,
        _dllName = dllName;

  final int _channel;
  final int _baud;
  final String _dllName;
  PcanBindings? _bindings;
  bool _open = false;

  Pointer<TPCANMsg>? _readMsg;
  Pointer<TPCANTimestamp>? _readTs;
  Pointer<TPCANMsg>? _writeMsg;

  @override
  bool get isOpen => _open;

  @override
  String get statusDescription {
    if (!_open || _bindings == null) return 'closed';
    final st = _bindings!.canGetStatus(_channel);
    return 'PCAN status=0x${st.toRadixString(16)} channel=0x${_channel.toRadixString(16)}';
  }

  @override
  Future<void> open() async {
    if (_open) return;

    try {
      _bindings ??= PcanBindings.load(dllName: _dllName);
    } catch (e) {
      throw StateError(
        'Failed to load $_dllName. Install PEAK PCAN-Basic drivers and ensure '
        'the DLL is on PATH / next to the app. Underlying error: $e',
      );
    }

    // CAN_Initialize(Channel, Btr0Btr1, HwType=0, IOPort=0, Interrupt=0)
    final status = _bindings!.canInitialize(_channel, _baud, 0, 0, 0);
    if (status != pcanErrorOk) {
      throw StateError(
        'CAN_Initialize failed for channel 0x${_channel.toRadixString(16)} '
        'baud=0x${_baud.toRadixString(16)}: status=0x${status.toRadixString(16)}. '
        'Check that the PCAN device is connected and not in use.',
      );
    }

    _readMsg = allocPcanMsg();
    _readTs = allocPcanTimestamp();
    _writeMsg = allocPcanMsg();
    _open = true;
    debugLog(
      '[PCAN] Initialized channel=0x${_channel.toRadixString(16)} '
      'baud=0x${_baud.toRadixString(16)}',
    );
  }

  @override
  Future<void> close() async {
    if (!_open) return;
    _open = false;
    try {
      _bindings?.canUninitialize(_channel);
    } catch (e) {
      debugLog('[PCAN] Uninitialize error: $e');
    }
    if (_readMsg != null) {
      calloc.free(_readMsg!);
      _readMsg = null;
    }
    if (_readTs != null) {
      calloc.free(_readTs!);
      _readTs = null;
    }
    if (_writeMsg != null) {
      calloc.free(_writeMsg!);
      _writeMsg = null;
    }
  }

  @override
  Future<CanFrame?> read() async {
    if (!_open || _bindings == null || _readMsg == null) return null;

    final status = _bindings!.canRead(_channel, _readMsg!, _readTs!);
    if (status == pcanErrorQrcvEmpty) return null;
    if (status != pcanErrorOk) {
      debugLog('[PCAN] CAN_Read status=0x${status.toRadixString(16)}');
      return null;
    }

    final msg = _readMsg!;
    final len = msg.ref.len.clamp(0, 8);
    final bytes = Uint8List(len);
    for (var i = 0; i < len; i++) {
      bytes[i] = msg.ref.data[i];
    }
    final ts = _readTs!;
    final micros = ts.ref.millis * 1000 + ts.ref.micros;
    return CanFrame(
      id: msg.ref.id,
      data: bytes,
      timestampMicros: micros,
      isExtended: (msg.ref.msgType & 0x02) != 0,
      isRtr: (msg.ref.msgType & 0x01) != 0,
    );
  }

  @override
  Future<void> write(CanFrame frame) async {
    if (!_open || _bindings == null || _writeMsg == null) {
      throw StateError('PCAN channel is not open');
    }

    final msg = _writeMsg!;
    msg.ref.id = frame.id;
    msg.ref.msgType = frame.isExtended
        ? 0x02
        : (frame.isRtr ? 0x01 : pcanMessageStandard);
    final len = frame.dlc;
    msg.ref.len = len;
    for (var i = 0; i < 8; i++) {
      msg.ref.data[i] = i < len ? (frame.data[i] & 0xFF) : 0;
    }

    final status = _bindings!.canWrite(_channel, msg);
    if (status != pcanErrorOk) {
      throw StateError(
        'CAN_Write failed: status=0x${status.toRadixString(16)}',
      );
    }
  }
}
