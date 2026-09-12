import 'package:flutter/material.dart';
import 'package:obd_car_monitor/core/theme/app_colors.dart';
import 'package:obd_car_monitor/domain/models/connection_mode.dart';

extension ConnectionModeUi on ConnectionMode {
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
