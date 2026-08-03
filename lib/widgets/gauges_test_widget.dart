import 'package:flutter/material.dart';
import 'gauge_widgets/widgets_export.dart';

/// Quick test widget to see both RPM and Speed gauges side by side
/// Usage: Scaffold(body: GaugesTestWidget())
class GaugesTestWidget extends StatelessWidget {
  const GaugesTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Test both gauges side by side
          const Row(
            children: [
              Expanded(
                flex: 2,
                child: RpmGaugeWidget(
                  4500.0, // Test RPM
                  4, // Test gear (D)
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: SpeedometerGaugeWidget(
                  85.0, // Test speed
                  4, // Same gear
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Legend/Info about test values
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              // color: Colors.white.withOpacity(0.05),
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🧪 Test Values:',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.speed, size: 18, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('RPM: 4,500 RPM (Gear D)'),
                  ],
                ),
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Icon(Icons.car_crash_rounded, size: 18, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Speed: 85 km/h (Gear D)'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Gear display comparison
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'RPM Gauge',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                    const Text(
                      'Gear D',
                      style: TextStyle(
                        color: Colors.yellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Speed Gauge',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                    const Text(
                      'Gear D',
                      style: TextStyle(
                        color: Colors.yellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
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

/// Alternative simple comparison layout
class SimpleGaugesComparison extends StatelessWidget {
  final double rpm;
  final double speed;
  final int gear;

  const SimpleGaugesComparison({
    super.key,
    required this.rpm,
    required this.speed,
    required this.gear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // RPM gauge at top
        RpmGaugeWidget(rpm, gear),

        const SizedBox(height: 16),

        Divider(color: Colors.white.withValues(alpha: 0.2)),

        const SizedBox(height: 16),

        // Speed gauge at bottom
        SpeedometerGaugeWidget(speed, gear),
      ],
    );
  }
}
