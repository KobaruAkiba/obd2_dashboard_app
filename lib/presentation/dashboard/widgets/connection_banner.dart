import 'package:flutter/material.dart';
import 'package:odb_dashboard/core/theme/app_colors.dart';
import 'package:odb_dashboard/domain/models/connection_mode.dart';
import 'package:odb_dashboard/presentation/connection/connection_mode_ui.dart';

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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: mode.color.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: mode.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(mode.icon, color: mode.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mode.label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.speed,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
