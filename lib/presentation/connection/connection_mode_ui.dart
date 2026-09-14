import 'package:flutter/material.dart';
import 'package:odb_dashboard/core/theme/app_colors.dart';
import 'package:odb_dashboard/domain/models/connection_mode.dart';

extension ConnectionModeUi on ConnectionMode {
  String get label => switch (this) {
        ConnectionMode.disconnected => 'Disconnected',
        ConnectionMode.connecting => 'Connecting…',
        ConnectionMode.mock => 'Mock data',
        ConnectionMode.bluetooth => 'Bluetooth OBD',
        ConnectionMode.canBus => 'CAN bus',
        ConnectionMode.error => 'Connection failed',
      };

  /// Short transport code for status pills (BLE/BT/CAN).
  String get shortCode => switch (this) {
        ConnectionMode.disconnected => 'OFF',
        ConnectionMode.connecting => 'WAIT',
        ConnectionMode.mock => 'MOCK',
        ConnectionMode.bluetooth => 'BLE/BT',
        ConnectionMode.canBus => 'CAN',
        ConnectionMode.error => 'ERR',
      };

  IconData get icon => switch (this) {
        ConnectionMode.disconnected => Icons.link_off_rounded,
        ConnectionMode.connecting => Icons.hourglass_top_rounded,
        ConnectionMode.mock => Icons.science_outlined,
        ConnectionMode.bluetooth => Icons.bluetooth_connected_rounded,
        ConnectionMode.canBus => Icons.settings_input_component_rounded,
        ConnectionMode.error => Icons.error_outline_rounded,
      };

  /// LED / chrome color language:
  /// OFF muted · WAIT/MOCK amber · BLE/BT cyan · CAN green · ERR red.
  Color get color => switch (this) {
        ConnectionMode.disconnected => AppColors.muted,
        ConnectionMode.connecting => AppColors.warning,
        ConnectionMode.mock => AppColors.warning,
        ConnectionMode.bluetooth => AppColors.ble,
        ConnectionMode.canBus => AppColors.accent,
        ConnectionMode.error => AppColors.danger,
      };
}
