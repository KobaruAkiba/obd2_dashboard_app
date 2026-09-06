import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Compact gear readout (N / D / 1–7). No decorative icons.
class GearIndicator extends StatelessWidget {
  const GearIndicator({super.key, required this.gearLabel});

  final String gearLabel;

  @override
  Widget build(BuildContext context) {
    final isNeutral = gearLabel == 'N';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isNeutral
              ? AppColors.warning.withValues(alpha: 0.5)
              : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'GEAR',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(width: 12),
          Text(
            gearLabel,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: isNeutral ? AppColors.warning : AppColors.accent,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
          ),
        ],
      ),
    );
  }
}
