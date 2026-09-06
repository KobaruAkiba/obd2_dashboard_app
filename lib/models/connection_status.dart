import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// High-level connection mode shown in the UI.
enum ConnectionMode {
  disconnected,
  connecting,
  mock,
  bluetooth,
  canBus,
  error,
}

extension ConnectionModeX on ConnectionMode {
  String get label => switch (this) {
        ConnectionMode.disconnected => 'Disconnected',
        ConnectionMode.connecting => 'Connecting…',
        ConnectionMode.mock => 'Mock data',
        ConnectionMode.bluetooth => 'Bluetooth OBD',
        ConnectionMode.canBus => 'CAN bus',
        ConnectionMode.error => 'Connection failed',
      };

  IconData get icon => switch (this) {
        ConnectionMode.disconnected => Icons.link_off,
        ConnectionMode.connecting => Icons.hourglass_top,
        ConnectionMode.mock => Icons.science_outlined,
        ConnectionMode.bluetooth => Icons.bluetooth,
        ConnectionMode.canBus => Icons.settings_input_component,
        ConnectionMode.error => Icons.error_outline,
      };

  Color get color => switch (this) {
        ConnectionMode.disconnected => AppColors.muted,
        ConnectionMode.connecting => AppColors.warning,
        ConnectionMode.mock => AppColors.warning,
        ConnectionMode.bluetooth => AppColors.rpm,
        ConnectionMode.canBus => AppColors.accent,
        ConnectionMode.error => AppColors.danger,
      };
}
