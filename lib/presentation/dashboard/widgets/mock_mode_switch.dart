import 'package:flutter/material.dart';
import 'package:obd_car_monitor/core/theme/app_colors.dart';

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
    return Material(
      color: AppColors.surfaceHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        title: const Text('Mock data'),
        subtitle: Text(
          value ? 'Simulated telemetry' : 'Hardware stub path',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        secondary: Icon(
          Icons.science_outlined,
          color: value ? AppColors.warning : AppColors.muted,
        ),
        value: value,
        onChanged: enabled ? onChanged : null,
      ),
    );
  }
}
