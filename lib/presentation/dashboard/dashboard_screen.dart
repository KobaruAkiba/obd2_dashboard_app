import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:odb_dashboard/core/theme/app_colors.dart';
import 'package:odb_dashboard/presentation/connection/connection_mode_ui.dart';
import 'package:odb_dashboard/presentation/dashboard/dashboard_controller.dart';
import 'package:odb_dashboard/presentation/dashboard/widgets/cockpit_dashboard.dart';
import 'package:odb_dashboard/presentation/dashboard/widgets/connection_banner.dart';
import 'package:odb_dashboard/presentation/dashboard/widgets/debug_service_panel.dart';
import 'package:odb_dashboard/presentation/dashboard/widgets/dtc_alert_banner.dart';
import 'package:odb_dashboard/presentation/dashboard/widgets/mock_mode_switch.dart';

/// Thin shell that binds [DashboardController] to the cockpit layout.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardController _controller;

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
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final c = _controller;
        return Scaffold(
          appBar: AppBar(
            title: const Text('OBD Monitor'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Chip(
                  avatar: Icon(c.mode.icon, size: 16, color: c.mode.color),
                  label: Text(c.mode.label),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                if (kDebugMode) ...[
                  MockModeSwitch(
                    value: c.useMock,
                    enabled: !c.switching,
                    onChanged: c.onMockChanged,
                  ),
                  const SizedBox(height: 12),
                ],
                ConnectionBanner(
                  mode: c.mode,
                  detail: c.detail,
                ),
                const SizedBox(height: 20),
                CockpitDashboard(data: c.data),
                const SizedBox(height: 16),
                DtcAlertBanner(codes: c.data.dtcs),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 14, color: AppColors.muted),
                    const SizedBox(width: 6),
                    Text(
                      c.formatLastUpdate(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        c.data.rpm != null ? c.data.statusSummary : '',
                        style: Theme.of(context).textTheme.labelSmall,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                if (kDebugMode) ...[
                  const SizedBox(height: 20),
                  DebugServicePanel(
                    info: c.serviceInfo,
                    mode: c.mode,
                    useMock: c.useMock,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
