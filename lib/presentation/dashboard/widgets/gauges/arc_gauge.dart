import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:obd_car_monitor/core/theme/app_colors.dart';

/// Semi-circular arc gauge for RPM / speed readouts.
class ArcGauge extends StatelessWidget {
  const ArcGauge({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.label,
    required this.unit,
    this.color = AppColors.rpm,
    this.dangerAbove,
    this.fractionDigits = 0,
  });

  final double value;
  final double min;
  final double max;
  final String label;
  final String unit;
  final Color color;
  final double? dangerAbove;
  final int fractionDigits;

  @override
  Widget build(BuildContext context) {
    final inDanger = dangerAbove != null && value >= dangerAbove!;
    final paintColor = inDanger ? AppColors.danger : color;
    final clamped = value.clamp(min, max);
    final progress = max > min ? (clamped - min) / (max - min) : 0.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          AspectRatio(
            aspectRatio: 1.35,
            child: CustomPaint(
              painter: _ArcPainter(progress: progress, color: paintColor),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        value.toStringAsFixed(fractionDigits),
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: paintColor,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                      ),
                      Text(unit, style: Theme.of(context).textTheme.labelSmall),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.shortestSide * 0.08;
    final rect = Rect.fromLTWH(
      stroke,
      stroke * 1.2,
      size.width - stroke * 2,
      size.height - stroke * 1.5,
    );
    const start = math.pi * 0.85;
    const sweep = math.pi * 1.3;

    final bg = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final fg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, start, sweep, false, bg);
    canvas.drawArc(rect, start, sweep * progress.clamp(0.0, 1.0), false, fg);
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
