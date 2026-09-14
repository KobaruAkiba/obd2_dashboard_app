import 'package:flutter/material.dart';
import 'package:odb_dashboard/core/theme/app_colors.dart';
import 'package:odb_dashboard/core/theme/app_spacing.dart';
import 'package:odb_dashboard/domain/models/connection_mode.dart';
import 'package:odb_dashboard/presentation/connection/connection_mode_ui.dart';
import 'package:odb_dashboard/presentation/dashboard/widgets/status_led.dart';
import 'package:odb_dashboard/presentation/dashboard/widgets/status_pill.dart';

class ConnectionBanner extends StatelessWidget {
  const ConnectionBanner({
    super.key,
    required this.mode,
    required this.detail,
  });

  final ConnectionMode mode;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final color = mode.color;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md - 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.ledRing(color)),
      ),
      child: Row(
        children: [
          StatusIconBadge(icon: mode.icon, color: color, size: 42),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    StatusLed(color: color, size: 9),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        mode.label,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.onSurfaceBright,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    StatusPill(
                      label: mode.shortCode,
                      color: color,
                      led: false,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceMuted,
                        fontSize: 13,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
