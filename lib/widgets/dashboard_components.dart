import 'package:flutter/material.dart';
import 'gauge_widgets/widgets_export.dart';

/// Dashboard container for RPM gauge (main focus)
class RpmDashboard extends StatelessWidget {
  final double rpm;
  final int gear;

  const RpmDashboard({
    super.key,
    required this.rpm,
    required this.gear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // RPM Gauge Widget - Digital + Analog Hybrid
          RpmGaugeWidget(rpm, gear),

          const SizedBox(height: 8),

          // Gear name label
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Gear',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _getGearName(gear),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getGearName(int gear) {
    switch (gear) {
      case -1:
        return 'N'; // Neutral
      case 0:
        return 'D'; // Drive
      default:
        return gear.abs().toString(); // Manual gears
    }
  }
}

/// Speedometer dashboard widget with trip computer
class SpeedDashboard extends StatelessWidget {
  final double speed;
  final int gear;
  final String odometer;
  final String tripA;
  final String tripB;

  const SpeedDashboard({
    super.key,
    required this.speed,
    required this.gear,
    required this.odometer,
    required this.tripA,
    required this.tripB,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Speedometer gauge on left
          Expanded(child: SpeedometerGaugeWidget(speed, gear)),

          const SizedBox(width: 8),

          // Trip computer info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('ODO',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(width: 8),
                    Text(odometer.isEmpty ? '-' : odometer,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('TRIP A',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(width: 8),
                    Text(tripA.isEmpty ? '-' : tripA,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('TRIP B',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(width: 8),
                    Text(tripB.isEmpty ? '-' : tripB,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
