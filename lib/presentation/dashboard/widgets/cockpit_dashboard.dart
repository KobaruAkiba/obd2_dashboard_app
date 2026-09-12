import 'package:flutter/material.dart';
import 'package:obd_car_monitor/core/theme/app_colors.dart';
import 'package:obd_car_monitor/domain/models/vehicle_data.dart';
import 'package:obd_car_monitor/presentation/dashboard/widgets/gauges/arc_gauge.dart';
import 'package:obd_car_monitor/presentation/dashboard/widgets/gauges/gear_indicator.dart';
import 'package:obd_car_monitor/presentation/dashboard/widgets/gauges/metric_tile.dart';

/// Primary OBD cockpit: dual gauges, gear, and key metrics.
class CockpitDashboard extends StatelessWidget {
  const CockpitDashboard({super.key, required this.data});

  final VehicleData data;

  @override
  Widget build(BuildContext context) {
    final rpm = data.rpm ?? 0;
    final speed = data.speed ?? 0;
    final coolant = data.coolantTemp ?? 0;
    final intake = data.intakeTemp ?? 0;
    final battery = data.batteryVoltage ?? 0;
    final throttle = data.throttlePosition ?? 0;
    final fuel = data.fuelLevel;

    final coolantHot = coolant >= 105;
    final batteryLow = battery > 0 && battery < 12.0;

    return Column(
      children: [
        GearIndicator(gearLabel: data.gearLabel),
        const SizedBox(height: 16),
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

            if (constraints.maxWidth >= 520) {
              return Row(
                children: [
                  Expanded(child: rpmGauge),
                  const SizedBox(width: 12),
                  Expanded(child: speedGauge),
                ],
              );
            }

            return Column(
              children: [
                rpmGauge,
                const SizedBox(height: 12),
                speedGauge,
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: MediaQuery.sizeOf(context).width >= 600 ? 5 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.55,
          children: [
            MetricTile(
              label: 'Coolant',
              value: coolant.toStringAsFixed(0),
              unit: '°C',
              icon: Icons.thermostat,
              accent: AppColors.danger,
              alert: coolantHot,
            ),
            MetricTile(
              label: 'Intake',
              value: intake.toStringAsFixed(0),
              unit: '°C',
              icon: Icons.air,
              accent: AppColors.rpm,
            ),
            MetricTile(
              label: 'Battery',
              value: battery.toStringAsFixed(1),
              unit: 'V',
              icon: Icons.battery_charging_full,
              accent: AppColors.accent,
              alert: batteryLow,
            ),
            MetricTile(
              label: 'Throttle',
              value: throttle.toStringAsFixed(0),
              unit: '%',
              icon: Icons.speed,
              accent: AppColors.warning,
            ),
            MetricTile(
              label: 'Fuel',
              value: fuel.toStringAsFixed(0),
              unit: '%',
              icon: Icons.local_gas_station,
              accent: AppColors.rpm,
              alert: fuel < 15,
            ),
          ],
        ),
      ],
    );
  }
}
