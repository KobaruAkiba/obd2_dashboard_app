import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:odb_dashboard/core/theme/app_colors.dart';
import 'package:odb_dashboard/core/theme/app_spacing.dart';
import 'package:odb_dashboard/presentation/dashboard/dashboard_controller.dart';
import 'package:odb_dashboard/presentation/dashboard/widgets/connection_banner.dart';
import 'package:odb_dashboard/presentation/dashboard/widgets/debug_service_panel.dart';
import 'package:odb_dashboard/presentation/dashboard/widgets/mock_mode_switch.dart';
import 'package:odb_dashboard/presentation/dashboard/widgets/section_header.dart';
import 'package:odb_dashboard/presentation/dashboard/widgets/status_led.dart';

/// Connection detail, mock toggle, and debug readout (Connection tab).
///
/// Isolated [ListenableBuilder] so connection chrome rebuilds independently
/// of high-rate cockpit telemetry (feature/BLE pattern).
class ConnectionPage extends StatelessWidget {
  const ConnectionPage({super.key, required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final c = controller;
        final theme = Theme.of(context);
        final isLive = c.formatLastUpdate() == 'Live';

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          children: [
            const SectionHeader(title: 'Connection'),
            const SizedBox(height: AppSpacing.md),
            ConnectionBanner(mode: c.mode, detail: c.detail),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                StatusLed(
                  color: isLive ? AppColors.accent : AppColors.warning,
                  size: 8,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  c.formatLastUpdate(),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            if (kDebugMode) ...[
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(title: 'Debug'),
              const SizedBox(height: AppSpacing.md),
              MockModeSwitch(
                value: c.useMock,
                enabled: !c.switching,
                onChanged: c.onMockChanged,
              ),
              const SizedBox(height: AppSpacing.md),
              DebugServicePanel(
                info: c.serviceInfo,
                mode: c.mode,
                useMock: c.useMock,
              ),
            ],
          ],
        );
      },
    );
  }
}
