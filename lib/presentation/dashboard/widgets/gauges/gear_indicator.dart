import 'package:flutter/material.dart';
import 'package:odb_dashboard/core/theme/app_colors.dart';
import 'package:odb_dashboard/core/theme/app_spacing.dart';

/// Compact gear readout (N / D / 1–7). No decorative icons.
class GearIndicator extends StatelessWidget {
  const GearIndicator({super.key, required this.gearLabel});

  final String gearLabel;

  @override
  Widget build(BuildContext context) {
    final isNeutral = gearLabel == 'N';
    final accent = isNeutral ? AppColors.warning : AppColors.accent;

    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg + 2,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isNeutral
              ? AppColors.warning.withValues(alpha: 0.65)
              : AppColors.borderBright,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'GEAR',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            width: 1,
            height: 22,
            color: AppColors.border,
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            gearLabel,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  height: 1,
                ),
          ),
        ],
      ),
    );
  }
}
