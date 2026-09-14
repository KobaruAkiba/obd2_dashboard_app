import 'package:flutter/material.dart';
import 'package:odb_dashboard/core/theme/app_colors.dart';
import 'package:odb_dashboard/core/theme/app_spacing.dart';

/// Compact status LED for connection / health indicators.
class StatusLed extends StatelessWidget {
  const StatusLed({
    super.key,
    required this.color,
    this.size = 10,
    this.glow = true,
  });

  final Color color;
  final double size;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Status indicator',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: glow
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.55),
                    blurRadius: size * 1.2,
                    spreadRadius: 0.5,
                  ),
                ]
              : null,
          border: Border.all(
            color: AppColors.onSurfaceBright.withValues(alpha: 0.25),
            width: 0.5,
          ),
        ),
      ),
    );
  }
}

/// Icon chip with LED-style accent fill used in connection chrome.
class StatusIconBadge extends StatelessWidget {
  const StatusIconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 40,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.ledFill(color),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.ledRing(color)),
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}
