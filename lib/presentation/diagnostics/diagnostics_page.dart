import 'package:flutter/material.dart';

import 'package:odb_dashboard/core/theme/app_colors.dart';
import 'package:odb_dashboard/core/theme/app_spacing.dart';
import 'package:odb_dashboard/domain/models/vehicle_data.dart';
import 'package:odb_dashboard/presentation/dashboard/dashboard_controller.dart';
import 'package:odb_dashboard/presentation/dashboard/widgets/dtc_alert_banner.dart';
import 'package:odb_dashboard/presentation/dashboard/widgets/section_header.dart';
import 'package:odb_dashboard/presentation/dashboard/widgets/status_pill.dart';

/// Diagnostics tab: DTC primary, then secondary alerts / vehicle status.
class DiagnosticsPage extends StatelessWidget {
  const DiagnosticsPage({super.key, required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final c = controller;
        final data = c.data;

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          children: [
            const SectionHeader(title: 'Trouble codes'),
            const SizedBox(height: AppSpacing.md),
            if (data.dtcs.isEmpty)
              const _EmptyDtcCard()
            else
              DtcAlertBanner(codes: data.dtcs),
            if (data.freezeFrameTimestamp != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Freeze frame: ${data.freezeFrameTimestamp}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceMuted,
                    ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            const SectionHeader(title: 'Alerts & status'),
            const SizedBox(height: AppSpacing.md),
            _SecondaryAlerts(data: data),
            const SizedBox(height: AppSpacing.lg),
            _StatusFooter(
              lastUpdate: c.formatLastUpdate(),
              summary: data.statusSummary,
            ),
          ],
        );
      },
    );
  }
}

class _EmptyDtcCard extends StatelessWidget {
  const _EmptyDtcCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.ledFill(AppColors.accent),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.ledRing(AppColors.accent)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.accent.withValues(alpha: 0.95),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No trouble codes',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.onSurfaceBright,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ECU reports a clear DTC list',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceMuted,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SecondaryAlerts extends StatelessWidget {
  const _SecondaryAlerts({required this.data});

  final VehicleData data;

  @override
  Widget build(BuildContext context) {
    final alerts = <({String label, Color color})>[];

    final coolant = data.coolantTemp;
    if (coolant != null && coolant >= 105) {
      alerts.add((label: 'Coolant hot ${coolant.toStringAsFixed(0)}°C', color: AppColors.danger));
    }
    final battery = data.batteryVoltage;
    if (battery != null && battery > 0 && battery < 12.0) {
      alerts.add((
        label: 'Battery low ${battery.toStringAsFixed(1)} V',
        color: AppColors.warning,
      ));
    }
    if (data.fuelLevel < 15) {
      alerts.add((
        label: 'Fuel low ${data.fuelLevel.toStringAsFixed(0)}%',
        color: AppColors.warning,
      ));
    }
    if (!data.engineReady) {
      alerts.add((label: 'Engine not ready', color: AppColors.warning));
    }

    if (alerts.isEmpty) {
      return const Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          StatusPill(label: 'Systems OK', color: AppColors.accent),
        ],
      );
    }

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final a in alerts) StatusPill(label: a.label, color: a.color),
      ],
    );
  }
}

class _StatusFooter extends StatelessWidget {
  const _StatusFooter({required this.lastUpdate, required this.summary});

  final String lastUpdate;
  final String summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.schedule_rounded,
              size: 14,
              color: AppColors.onSurfaceMuted,
            ),
            const SizedBox(width: 6),
            Text(
              lastUpdate,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceMuted,
                  ),
            ),
          ],
        ),
        if (summary.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            summary,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
          ),
        ],
      ],
    );
  }
}
