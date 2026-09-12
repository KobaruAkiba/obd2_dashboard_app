import 'package:flutter/material.dart';
import 'package:obd_car_monitor/core/theme/app_colors.dart';

class DtcAlertBanner extends StatelessWidget {
  const DtcAlertBanner({super.key, required this.codes});

  final String codes;

  @override
  Widget build(BuildContext context) {
    if (codes.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.danger),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Diagnostic trouble code',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  codes,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.speed,
                        fontFamily: 'monospace',
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
