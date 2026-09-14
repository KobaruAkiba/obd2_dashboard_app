import 'package:flutter/material.dart';

import 'package:odb_dashboard/core/theme/app_colors.dart';
import 'package:odb_dashboard/core/theme/app_spacing.dart';
import 'package:odb_dashboard/domain/models/vehicle_data.dart';
import 'package:odb_dashboard/presentation/dashboard/widgets/gauges/metric_tile.dart';

/// Key metrics under the Live gauges.
///
/// Phone: always 2 columns. Tablet: 3 from 600px, 4 from 900px.
/// Never 5-col under ~600 — tiles need room for unit-under-value layout.
class LiveMetricsGrid extends StatelessWidget {
  const LiveMetricsGrid({super.key, required this.data});

  final VehicleData data;

  @override
  Widget build(BuildContext context) {
    final coolant = data.coolantTemp ?? 0;
    final intake = data.intakeTemp ?? 0;
    final battery = data.batteryVoltage ?? 0;
    final throttle = data.throttlePosition ?? 0;
    final fuel = data.fuelLevel;

    final coolantHot = coolant >= 105;
    final batteryLow = battery > 0 && battery < 12.0;
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 900
        ? 4
        : width >= 600
            ? 3
            : 2;
    // Taller tiles for unit-under-value MetricTile layout.
    final aspect = width < 400 ? 1.35 : 1.42;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm + 2,
      crossAxisSpacing: AppSpacing.sm + 2,
      childAspectRatio: aspect,
      children: [
        MetricTile(
          label: 'Coolant',
          value: coolant.toStringAsFixed(0),
          unit: '°C',
          icon: Icons.thermostat_rounded,
          accent: AppColors.danger,
          alert: coolantHot,
        ),
        MetricTile(
          label: 'Intake',
          value: intake.toStringAsFixed(0),
          unit: '°C',
          icon: Icons.air_rounded,
          accent: AppColors.rpm,
        ),
        MetricTile(
          label: 'Battery',
          value: battery.toStringAsFixed(1),
          unit: 'V',
          icon: Icons.battery_charging_full_rounded,
          accent: AppColors.accent,
          alert: batteryLow,
        ),
        MetricTile(
          label: 'Throttle',
          value: throttle.toStringAsFixed(0),
          unit: '%',
          icon: Icons.speed_rounded,
          accent: AppColors.warning,
        ),
        MetricTile(
          label: 'Fuel',
          value: fuel.toStringAsFixed(0),
          unit: '%',
          icon: Icons.local_gas_station_rounded,
          accent: AppColors.rpm,
          alert: fuel < 15,
        ),
      ],
    );
  }
}
