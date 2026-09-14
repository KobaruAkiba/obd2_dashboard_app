import 'package:flutter/material.dart';

import 'package:odb_dashboard/presentation/shell/dashboard_shell.dart';

/// Legacy entry point — forwards to [DashboardShell].
///
/// Kept for existing imports/tests. Lifecycle + split [ListenableBuilder]
/// chrome live in [DashboardShell] and tab pages.
///
/// On merge with feature/BLE-BTserial-CAN: keep the shell; do not re-inline
/// their monolithic ListView into this file.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => const DashboardShell();
}
