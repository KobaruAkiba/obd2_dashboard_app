import 'package:flutter/material.dart';

import 'package:odb_dashboard/core/theme/app_theme.dart';
import 'package:odb_dashboard/presentation/shell/dashboard_shell.dart';

class ObdApp extends StatelessWidget {
  const ObdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OBD Monitor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const DashboardShell(),
    );
  }
}
