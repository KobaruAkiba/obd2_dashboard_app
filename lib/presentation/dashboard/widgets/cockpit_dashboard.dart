import 'package:flutter/material.dart';

import 'package:odb_dashboard/core/theme/app_colors.dart';
import 'package:odb_dashboard/core/theme/app_spacing.dart';
import 'package:odb_dashboard/domain/models/vehicle_data.dart';
import 'package:odb_dashboard/presentation/dashboard/widgets/gauges/arc_gauge.dart';
import 'package:odb_dashboard/presentation/dashboard/widgets/gauges/gear_indicator.dart';
import 'package:odb_dashboard/presentation/live/live_metrics_grid.dart';

/// Primary Live cockpit: gear, RPM/speed gauges, and key metrics.
///
/// Gauges are wrapped in [RepaintBoundary] so high-rate updates isolate paint
/// (aligned with feature/BLE-BTserial-CAN). Public API stays `data`-only.
class CockpitDashboard extends StatelessWidget {
  const CockpitDashboard({super.key, required this.data});

  final VehicleData data;

  @override
  Widget build(BuildContext context) {
    final rpm = data.rpm ?? 0;
    final speed = data.speed ?? 0;

    return Column(
      children: [
        GearIndicator(gearLabel: data.gearLabel),
        const SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            final rpmGauge = ArcGauge(
              value: rpm,
              min: 0,
              max: 8000,
              label: 'ENGINE',
              unit: 'RPM',
              color: AppColors.rpm,
              dangerAbove: 6500,
            );
            final speedGauge = ArcGauge(
              value: speed,
              min: 0,
              max: 220,
              label: 'SPEED',
              unit: 'km/h',
              color: AppColors.accent,
              dangerAbove: 180,
            );

            // Side-by-side only on wide layouts; stacked on phone.
            if (constraints.maxWidth >= 520) {
              return RepaintBoundary(
                child: Row(
                  children: [
                    Expanded(child: rpmGauge),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: speedGauge),
                  ],
                ),
              );
            }

            return RepaintBoundary(
              child: Column(
                children: [
                  rpmGauge,
                  const SizedBox(height: AppSpacing.md),
                  speedGauge,
                ],
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        LiveMetricsGrid(data: data),
      ],
    );
  }
}
