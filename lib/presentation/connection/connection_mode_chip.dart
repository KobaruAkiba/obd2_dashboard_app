import 'package:flutter/material.dart';

import 'package:odb_dashboard/domain/models/connection_mode.dart';
import 'package:odb_dashboard/presentation/connection/connection_mode_ui.dart';
import 'package:odb_dashboard/presentation/dashboard/widgets/status_pill.dart';

/// Compact AppBar connection indicator (LED + short transport code).
class ConnectionModeChip extends StatelessWidget {
  const ConnectionModeChip({super.key, required this.mode});

  final ConnectionMode mode;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: mode.label,
      child: StatusPill(
        label: mode.shortCode,
        color: mode.color,
      ),
    );
  }
}
