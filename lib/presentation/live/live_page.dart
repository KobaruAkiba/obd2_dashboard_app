import 'package:flutter/material.dart';

import 'package:odb_dashboard/core/theme/app_colors.dart';
import 'package:odb_dashboard/core/theme/app_spacing.dart';
import 'package:odb_dashboard/presentation/connection/connection_mode_ui.dart';
import 'package:odb_dashboard/presentation/dashboard/dashboard_controller.dart';
import 'package:odb_dashboard/presentation/dashboard/widgets/cockpit_dashboard.dart';
import 'package:odb_dashboard/presentation/dashboard/widgets/dtc_alert_banner.dart';
import 'package:odb_dashboard/presentation/dashboard/widgets/status_led.dart';
import 'package:odb_dashboard/presentation/dashboard/widgets/status_pill.dart';

/// Glanceable cockpit: gear + primary gauges, with a compact DTC cue.
///
/// Uses its own [ListenableBuilder] so high-rate telemetry does not rebuild
/// shell chrome (matches feature/BLE split-builder approach).
class LivePage extends StatelessWidget {
  const LivePage({super.key, required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final c = controller;
        final isLive = c.formatLastUpdate() == 'Live';

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          children: [
            Row(
              children: [
                StatusPill(
                  label: c.mode.shortCode,
                  color: c.mode.color,
                ),
                const Spacer(),
                StatusPill(
                  label: isLive ? 'LIVE' : 'STALE',
                  color: isLive ? AppColors.accent : AppColors.warning,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            DtcAlertBanner(codes: c.data.dtcs),
            if (c.data.dtcs.isNotEmpty) const SizedBox(height: AppSpacing.md),
            CockpitDashboard(data: c.data),
            const SizedBox(height: AppSpacing.lg),
            _LiveFooter(
              lastUpdate: c.formatLastUpdate(),
              status: c.data.rpm != null ? c.data.statusSummary : '',
              live: isLive,
            ),
          ],
        );
      },
    );
  }
}

class _LiveFooter extends StatelessWidget {
  const _LiveFooter({
    required this.lastUpdate,
    required this.status,
    required this.live,
  });

  final String lastUpdate;
  final String status;
  final bool live;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          StatusLed(
            color: live ? AppColors.accent : AppColors.warning,
            size: 8,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            lastUpdate,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              status,
              style: Theme.of(context).textTheme.labelSmall,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
