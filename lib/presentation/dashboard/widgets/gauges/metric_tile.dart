import 'package:flutter/material.dart';
import 'package:odb_dashboard/core/theme/app_colors.dart';
import 'package:odb_dashboard/core/theme/app_spacing.dart';

class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    this.accent = AppColors.rpm,
    this.alert = false,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color accent;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    final color = alert ? AppColors.danger : accent;

    return Container(
      constraints: const BoxConstraints(minHeight: 72),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: alert
              ? AppColors.danger.withValues(alpha: 0.6)
              : AppColors.border,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(width: 3.5, color: color),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md - 2,
                AppSpacing.sm + 2,
                AppSpacing.md - 2,
                AppSpacing.sm + 2,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxHeight < 78 ||
                      constraints.maxWidth < 110;
                  final valueSize = compact ? 20.0 : 24.0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(icon, size: 15, color: color),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              label.toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppColors.onSurfaceMuted,
                                    fontSize: 10,
                                  ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          value,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: alert
                                    ? AppColors.danger
                                    : AppColors.onSurfaceBright,
                                fontWeight: FontWeight.w700,
                                fontSize: valueSize,
                                height: 1.05,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                          maxLines: 1,
                        ),
                      ),
                      if (unit.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          unit,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.onSurfaceMuted,
                                    letterSpacing: 1.1,
                                    fontSize: 10,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
