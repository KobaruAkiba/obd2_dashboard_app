import 'package:flutter/material.dart';

import 'package:odb_dashboard/core/theme/app_spacing.dart';
import 'package:odb_dashboard/presentation/connection/connection_mode_chip.dart';
import 'package:odb_dashboard/presentation/connection/connection_page.dart';
import 'package:odb_dashboard/presentation/dashboard/dashboard_controller.dart';
import 'package:odb_dashboard/presentation/diagnostics/diagnostics_page.dart';
import 'package:odb_dashboard/presentation/live/live_page.dart';

/// App home: owns [DashboardController] and hosts Live / Diagnostics / Connection.
///
/// Connection lifecycle is shared across tabs. AppBar mode pill uses its own
/// [ListenableBuilder]; each page also listens independently so high-rate
/// telemetry does not rebuild connection chrome (feature/BLE pattern).
class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  late final DashboardController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = DashboardController()..bootstrap();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OBD Monitor'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: Center(
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, _) {
                  return ConnectionModeChip(mode: _controller.mode);
                },
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: [
            LivePage(controller: _controller),
            DiagnosticsPage(controller: _controller),
            ConnectionPage(controller: _controller),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.speed_outlined),
            selectedIcon: Icon(Icons.speed),
            label: 'Live',
          ),
          NavigationDestination(
            icon: Icon(Icons.warning_amber_outlined),
            selectedIcon: Icon(Icons.warning_amber_rounded),
            label: 'Diagnostics',
          ),
          NavigationDestination(
            icon: Icon(Icons.link_outlined),
            selectedIcon: Icon(Icons.link),
            label: 'Connection',
          ),
        ],
      ),
    );
  }
}
