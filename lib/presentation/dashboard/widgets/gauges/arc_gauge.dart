import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:odb_dashboard/core/theme/app_colors.dart';
import 'package:odb_dashboard/core/theme/app_spacing.dart';

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
    final dangerProgress = dangerAbove != null && max > min
        ? ((dangerAbove! - min) / (max - min)).clamp(0.0, 1.0)
        : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: inDanger
              ? AppColors.danger.withValues(alpha: 0.55)
              : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          AspectRatio(
            aspectRatio: 1.4,
            child: CustomPaint(
              painter: _ArcPainter(
                progress: progress,
                color: paintColor,
                dangerProgress: dangerProgress,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        value.toStringAsFixed(fractionDigits),
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(
                              color: paintColor,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        unit,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.onSurfaceMuted,
                              letterSpacing: 1.5,
                            ),
                      ),
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
  _ArcPainter({
    required this.progress,
    required this.color,
    this.dangerProgress,
  });

  final double progress;
  final Color color;
  final double? dangerProgress;

  static const _start = math.pi * 0.85;
  static const _sweep = math.pi * 1.3;
  static const _tickCount = 17;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = (size.shortestSide * 0.085).clamp(8.0, 16.0);
    final rect = Rect.fromLTWH(
      stroke * 1.1,
      stroke * 1.35,
      size.width - stroke * 2.2,
      size.height - stroke * 1.6,
    );
    final center = rect.center;
    final radius = math.min(rect.width, rect.height) / 2;

    // Track
    final bg = Paint()
      ..color = AppColors.gaugeTrack
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, _start, _sweep, false, bg);

    // Danger zone on track (subtle red segment near redline)
    if (dangerProgress != null && dangerProgress! < 1.0) {
      final dangerPaint = Paint()
        ..color = AppColors.danger.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        rect,
        _start + _sweep * dangerProgress!,
        _sweep * (1.0 - dangerProgress!),
        false,
        dangerPaint,
      );
    }

    // Progress arc
    final fg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    final glow = Paint()
      ..color = color.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke + 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final sweep = _sweep * progress.clamp(0.0, 1.0);
    if (sweep > 0) {
      canvas.drawArc(rect, _start, sweep, false, glow);
      canvas.drawArc(rect, _start, sweep, false, fg);
    }

    // Tick marks (instrument cluster)
    final tickPaint = Paint()
      ..color = AppColors.onSurfaceMuted.withValues(alpha: 0.55)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final majorPaint = Paint()
      ..color = AppColors.onSurface.withValues(alpha: 0.75)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final innerR = radius - stroke * 0.55;
    final outerMinor = radius - stroke * 0.15;
    final outerMajor = radius + stroke * 0.05;

    for (var i = 0; i < _tickCount; i++) {
      final t = i / (_tickCount - 1);
      final angle = _start + _sweep * t;
      final major = i % 4 == 0;
      final outer = major ? outerMajor : outerMinor;
      final paint = major ? majorPaint : tickPaint;
      final cos = math.cos(angle);
      final sin = math.sin(angle);
      canvas.drawLine(
        Offset(center.dx + cos * innerR, center.dy + sin * innerR),
        Offset(center.dx + cos * outer, center.dy + sin * outer),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.dangerProgress != dangerProgress;
}
