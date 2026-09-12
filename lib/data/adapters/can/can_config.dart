import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;

/// Configuration for the Windows PCAN / CAN OBD path.
class CanConfig {
  CanConfig._();

  /// `--dart-define` / env key for PCAN channel name (e.g. `PCAN_USBBUS1`).
  static const channelKey = 'OBD_CAN_CHANNEL';

  /// `--dart-define` / env key for bitrate in bit/s (default 500000).
  static const bitrateKey = 'OBD_CAN_BITRATE';

  /// Default PCAN channel handle name.
  static const defaultChannelName = 'PCAN_USBBUS1';

  /// PCAN_USBBUS1 handle value (PCAN-Basic).
  static const int pcanUsbBus1 = 0x51;

  /// Default bitrate 500 kbit/s.
  static const int defaultBitrate = 500000;

  /// PCAN_BAUD_500K register value.
  static const int pcanBaud500k = 0x001C;

  /// UI / vehicleData sample period — 50 ms = 20 Hz.
  static const Duration uiSampleInterval = Duration(milliseconds: 50);

  /// Max emit rate for [CanBusObdService.vehicleData].
  static const double maxEmitHz = 20;

  /// How often the RX pump polls PCAN_Read when not using a busy loop.
  static const Duration rxPollInterval = Duration(milliseconds: 1);

  /// PID poll spacing inside a session cycle.
  static const Duration pidPollInterval = Duration(milliseconds: 20);

  /// Ring buffer capacity for raw RX frames (SPSC, drop-old).
  static const int ringCapacity = 256;

  static String resolveChannelName({String? Function(String key)? envReader}) {
    const fromDefine = String.fromEnvironment(channelKey);
    if (fromDefine.isNotEmpty) return fromDefine;
    if (!kIsWeb) {
      try {
        final fromEnv = (envReader ?? _platformEnv)(channelKey);
        if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
      } catch (_) {}
    }
    return defaultChannelName;
  }

  static int resolveBitrate({String? Function(String key)? envReader}) {
    const fromDefine = String.fromEnvironment(bitrateKey);
    if (fromDefine.isNotEmpty) {
      return int.tryParse(fromDefine) ?? defaultBitrate;
    }
    if (!kIsWeb) {
      try {
        final fromEnv = (envReader ?? _platformEnv)(bitrateKey);
        if (fromEnv != null && fromEnv.isNotEmpty) {
          return int.tryParse(fromEnv) ?? defaultBitrate;
        }
      } catch (_) {}
    }
    return defaultBitrate;
  }

  /// Map channel name → PCAN handle. Unknown names fall back to USB bus 1.
  static int channelHandle(String name) {
    switch (name.toUpperCase()) {
      case 'PCAN_USBBUS1':
        return 0x51;
      case 'PCAN_USBBUS2':
        return 0x52;
      case 'PCAN_USBBUS3':
        return 0x53;
      case 'PCAN_USBBUS4':
        return 0x54;
      case 'PCAN_USBBUS5':
        return 0x55;
      case 'PCAN_USBBUS6':
        return 0x56;
      case 'PCAN_USBBUS7':
        return 0x57;
      case 'PCAN_USBBUS8':
        return 0x58;
      default:
        return pcanUsbBus1;
    }
  }

  /// Map bitrate → PCAN BTR0/BTR1 constant (common OBD rates).
  static int baudConstant(int bitrate) {
    switch (bitrate) {
      case 1000000:
        return 0x0014; // PCAN_BAUD_1M
      case 500000:
        return pcanBaud500k;
      case 250000:
        return 0x011C; // PCAN_BAUD_250K
      case 125000:
        return 0x031C; // PCAN_BAUD_125K
      default:
        return pcanBaud500k;
    }
  }

  static String? _platformEnv(String key) {
    if (kIsWeb) return null;
    return Platform.environment[key];
  }
}
