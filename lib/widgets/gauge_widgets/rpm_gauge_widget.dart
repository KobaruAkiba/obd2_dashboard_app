// Simple RPM gauge with gear indicator and digital display
import 'package:flutter/material.dart';

class RpmGaugeWidget extends StatelessWidget {
  final double rpm;
  final int gear;

  const RpmGaugeWidget(this.rpm, this.gear, {super.key});

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
            Text((rpm / 100).toStringAsFixed(1).replaceAll('.', ','),
                style: TextStyle(
                    color: rpm > 7500 ? Colors.red : Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      );
}
