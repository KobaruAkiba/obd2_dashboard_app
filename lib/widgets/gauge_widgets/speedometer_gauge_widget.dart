// Simple Speedometer gauge with gear indicator and digital display
import 'package:flutter/material.dart';

class SpeedometerGaugeWidget extends StatelessWidget {
  final double speed;
  final int gear;

  const SpeedometerGaugeWidget(this.speed, this.gear, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: gear > -1
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sports_tennis,
                      size: 24,
                      color: gear > -1 ? Colors.white : Colors.orange),
                  const SizedBox(width: 8),
                  Text(gear == -1 ? 'N' : gear.abs().toString(),
                      style: TextStyle(
                          color: gear > -1 ? Colors.white : Colors.orange,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text((speed / 10).toStringAsFixed(0),
                style: TextStyle(
                    color: speed > 200 ? Colors.red : Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('km/h',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
          ],
        ),
      );
}
