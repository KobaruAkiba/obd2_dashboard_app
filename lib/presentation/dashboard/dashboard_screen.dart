import 'package:flutter/material.dart';

import 'package:odb_dashboard/presentation/shell/dashboard_shell.dart';

/// Legacy entry point — forwards to [DashboardShell].
///
/// Kept so existing imports keep working. Connection lifecycle and tab
/// navigation live in [DashboardShell]; prefer importing the shell for new
/// call sites.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => const DashboardShell();
}
