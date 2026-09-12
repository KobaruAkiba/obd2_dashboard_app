import 'package:flutter/material.dart';
import 'package:obd_car_monitor/core/theme/app_colors.dart';
import 'package:obd_car_monitor/domain/models/connection_mode.dart';

/// Compact debug readout of factory / connection state.
class DebugServicePanel extends StatelessWidget {
  const DebugServicePanel({
    super.key,
    required this.info,
    required this.mode,
    required this.useMock,
  });

  final Map<String, dynamic> info;
  final ConnectionMode mode;
  final bool useMock;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DEBUG', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 8),
          Text(
            'mode=$mode  useMock=$useMock  service=${info['serviceType']}  '
            'preferMock=${info['preferMock']}  windows=${info['isWindows']}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }
}
