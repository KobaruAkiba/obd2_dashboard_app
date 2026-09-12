import 'package:flutter/material.dart';

import 'package:obd_car_monitor/core/theme/app_theme.dart';
import 'package:obd_car_monitor/presentation/dashboard/dashboard_screen.dart';

class ObdApp extends StatelessWidget {
  const ObdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OBD Monitor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const DashboardScreen(),
    );
  }
}
