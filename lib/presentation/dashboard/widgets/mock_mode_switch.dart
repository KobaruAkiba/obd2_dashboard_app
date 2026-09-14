import 'package:flutter/material.dart';
import 'package:odb_dashboard/core/theme/app_colors.dart';
import 'package:odb_dashboard/core/theme/app_spacing.dart';
import 'package:odb_dashboard/presentation/dashboard/widgets/status_led.dart';

/// Debug-only toggle between mock telemetry and the hardware stub path.
class MockModeSwitch extends StatelessWidget {
  const MockModeSwitch({
    super.key,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final accent = value ? AppColors.warning : AppColors.muted;

    return Material(
      color: AppColors.surfaceHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: BorderSide(
          color: value
              ? AppColors.warning.withValues(alpha: 0.45)
              : AppColors.border,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        title: Text(
          'Mock data',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        subtitle: Text(
          value ? 'Simulated telemetry' : 'Hardware stub path',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        secondary: SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.science_outlined,
                color: accent,
                size: 24,
              ),
              if (value)
                const Positioned(
                  right: 2,
                  top: 2,
                  child: StatusLed(color: AppColors.warning, size: 8),
                ),
            ],
          ),
        ),
        value: value,
        onChanged: enabled ? onChanged : null,
      ),
    );
  }
}
