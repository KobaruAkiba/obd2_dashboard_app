import 'package:flutter/material.dart';
import 'package:odb_dashboard/core/theme/app_colors.dart';
import 'package:odb_dashboard/core/theme/app_spacing.dart';
import 'package:odb_dashboard/domain/models/connection_mode.dart';
import 'package:odb_dashboard/presentation/dashboard/widgets/section_header.dart';

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
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Debug'),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'mode=$mode  useMock=$useMock  service=${info['serviceType']}  '
            'preferMock=${info['preferMock']}  windows=${info['isWindows']}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: AppColors.onSurfaceMuted,
                  height: 1.45,
                ),
          ),
        ],
      ),
    );
  }
}
