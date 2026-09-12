import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:serial_port_win32/serial_port_win32.dart';

import 'package:odb_dashboard/data/adapters/bt_serial/bt_serial_config.dart';

/// Portable view of a Windows COM port (mirrors [PortInfo] fields we need).
class BtSerialDetectedPort {
  const BtSerialDetectedPort({
    required this.portName,
    this.friendlyName = '',
    this.hardwareID = '',
  });

  final String portName;
  final String friendlyName;
  final String hardwareID;
}

typedef BtSerialPortListProvider = List<BtSerialDetectedPort> Function();
typedef BtSerialEnvReader = String? Function(String key);

/// Resolves the COM port for an ELM327 SPP adapter.
///
/// Order: `--dart-define=OBD_COM_PORT` → env `OBD_COM_PORT` → auto-detect
/// (`BTHENUM` / SPP UUID, then ELM/OBD/Vgate names). No candidate → [StateError].
class BtSerialPortResolver {
  BtSerialPortResolver({
    this.listPorts,
    this.envReader,
  });

  /// Override for tests; defaults to [SerialPort.getPortsWithFullMessages].
  final BtSerialPortListProvider? listPorts;

  /// Override for tests; defaults to [Platform.environment].
  final BtSerialEnvReader? envReader;

  /// Compile-time `--dart-define=OBD_COM_PORT=COMx`.
  static String? get definedPort {
    const fromDefine = String.fromEnvironment(BtSerialConfig.comPortKey);
    if (fromDefine.isEmpty) return null;
    return fromDefine;
  }

  /// Picks a COM port or throws a clear [StateError] (never silent mock).
  String resolve() {
    final defined = definedPort;
    if (defined != null && defined.trim().isNotEmpty) {
      return normalizePortName(defined);
    }

    final fromEnv = _readEnv(BtSerialConfig.comPortKey);
    if (fromEnv != null && fromEnv.trim().isNotEmpty) {
      return normalizePortName(fromEnv);
    }

    final ports = (listPorts ?? defaultListPorts)();
    final auto = autoDetect(ports);
    if (auto == null) {
      throw StateError(
        'No OBD Bluetooth COM port found. Pair the ELM/OBD dongle in Windows '
        'Settings, note the COMx in Device Manager, then set '
        '${BtSerialConfig.comPortKey} via --dart-define or environment '
        '(example: --dart-define=${BtSerialConfig.comPortKey}=COM5).',
      );
    }
    return normalizePortName(auto);
  }

  /// Auto-detect among [ports]: BTHENUM / SPP UUID first, then name hints.
  static String? autoDetect(List<BtSerialDetectedPort> ports) {
    for (final p in ports) {
      if (_isBluetoothSpp(p)) return p.portName;
    }
    for (final p in ports) {
      if (_matchesNameHint(p)) return p.portName;
    }
    return null;
  }

  static bool _isBluetoothSpp(BtSerialDetectedPort p) {
    final hw = p.hardwareID.toUpperCase();
    final id = '${p.friendlyName} ${p.portName}'.toUpperCase();
    final blob = '$hw $id';
    return blob.contains(BtSerialConfig.bthenumHint) ||
        blob.contains(BtSerialConfig.sppUuidHint);
  }

  static bool _matchesNameHint(BtSerialDetectedPort p) {
    final blob = '${p.friendlyName} ${p.portName} ${p.hardwareID}'.toUpperCase();
    for (final hint in BtSerialConfig.nameHints) {
      if (blob.contains(hint)) return true;
    }
    return false;
  }

  static String normalizePortName(String raw) {
    final t = raw.trim().toUpperCase();
    if (t.startsWith('COM')) return t;
    // Allow bare number → COMn
    if (RegExp(r'^\d+$').hasMatch(t)) return 'COM$t';
    return t;
  }

  String? _readEnv(String key) {
    final reader = envReader;
    if (reader != null) return reader(key);
    if (kIsWeb) return null;
    try {
      return Platform.environment[key];
    } catch (_) {
      return null;
    }
  }

  /// Default enumerator — Windows only; callers must guard platform.
  static List<BtSerialDetectedPort> defaultListPorts() {
    if (kIsWeb || !Platform.isWindows) {
      return const [];
    }
    return SerialPort.getPortsWithFullMessages()
        .map(
          (PortInfo p) => BtSerialDetectedPort(
            portName: p.portName,
            friendlyName: p.friendlyName,
            hardwareID: p.hardwareID,
          ),
        )
        .toList(growable: false);
  }
}
