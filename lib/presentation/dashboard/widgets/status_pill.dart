import 'package:flutter/material.dart';
import 'package:odb_dashboard/core/theme/app_colors.dart';
import 'package:odb_dashboard/core/theme/app_spacing.dart';
import 'package:odb_dashboard/presentation/dashboard/widgets/status_led.dart';

/// Small labeled status chip (e.g. BLE · live).
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.color,
    this.led = true,
  });

  final String label;
  final Color color;
  final bool led;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.ledFill(color),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.ledRing(color)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (led) ...[
            StatusLed(color: color, size: 8),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
