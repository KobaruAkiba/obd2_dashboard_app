import 'package:flutter/material.dart';
import 'dart:math' as math;

class RpmGauge extends StatelessWidget {
  final double value;
  final VoidCallback? onTap;

  const RpmGauge({super.key, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          CustomPaint(
            size: const Size(280, 280),
            painter: RpmGaugePainter(value: value / 8500.0),
          ),
          const SizedBox(height: 16),
          Text(
            '${value.toStringAsFixed(0)} RPM',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: value > 6500 ? Colors.red : Colors.white,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class SpeedGauge extends StatelessWidget {
  final double value;
  final VoidCallback? onTap;

  const SpeedGauge({super.key, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          CustomPaint(
            size: const Size(280, 280),
            painter: SpeedGaugePainter(value: value),
          ),
          const SizedBox(height: 16),
          Text(
            value.toStringAsFixed(1),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class CoolantGauge extends StatelessWidget {
  final double value;
  final VoidCallback? onTap;

  const CoolantGauge({super.key, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
              height: 280,
              child: CustomPaint(painter: CoolantGaugePainter(value: value))),
          const SizedBox(height: 16),
          Text(
            '${value.toStringAsFixed(0)}°C',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: value < 90
                      ? Colors.green
                      : (value < 105 ? Colors.yellow : Colors.red),
                ),
          ),
        ],
      ),
    );
  }
}

class RpmGaugePainter extends CustomPainter {
  final double value;

  RpmGaugePainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.5);
    final radius = size.width * 0.4;

    // Dark background
    canvas.drawCircle(
      center,
      radius - 5,
      Paint()..color = const Color(0xFF1A1A2E),
    );

    // Gauge arc
    final arcPath = Path()
      ..moveTo(center.dx, center.dy - radius + 5)
      ..arcTo(Rect.fromCircle(center: center, radius: radius - 5), math.pi / 2,
          math.pi * 1.35, false);

    canvas.drawPath(
        arcPath,
        Paint()
          ..color = const Color(0xFF3A7BD5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.02);

    // Value indicator
    final indicatorPaint = Paint()
      ..color = const Color(0xFFE94560)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.015;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius - 5), math.pi,
        math.pi * 1.35 - (math.pi * 1.35) * value, false, indicatorPaint);

    // Value text
    final tp = TextPainter(
      text: TextSpan(text: (value * 0.2).toStringAsFixed(0)),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: size.width);
    tp.paint(canvas, Offset(center.dx - size.width / 4, center.dy));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class SpeedGaugePainter extends CustomPainter {
  final double value;

  SpeedGaugePainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.5);
    final radius = size.width * 0.4;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Dark background
    canvas.drawCircle(
        center, radius - 5, Paint()..color = const Color(0xFF1A1A2E));

    // Gauge arc (half circle)
    final arcPath = Path()
      ..moveTo(center.dx, center.dy - radius + 5)
      ..arcTo(rect, math.pi / 2, math.pi * 0.8, false);

    canvas.drawPath(
        arcPath,
        Paint()
          ..color = const Color(0xFF3A7BD5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.02);

    // Value indicator
    final endAngle = (math.pi * 0.8) * (value / 240);
    canvas.drawArc(rect, math.pi, endAngle, false,
        Paint()..color = const Color(0xFF1E90FF));

    // Center value text
    final tp = TextPainter(
      text: TextSpan(text: value.toStringAsFixed(1)),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: size.width);
    tp.paint(canvas, Offset(center.dx - size.width / 6.5, center.dy));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class CoolantGaugePainter extends CustomPainter {
  final double value;

  CoolantGaugePainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    // Background container
    final rect = Rect.fromLTWH(40, 60, size.width - 80, 240);
    canvas.drawRect(rect, Paint()..color = const Color(0xFF1A1A2E));

    // Temperature bar with color based on temp range
    if (value < 95) {
      canvas.drawRect(
        Rect.fromLTWH(
            rect.left + 4, rect.top + 28, rect.width - 8, rect.height - 36),
        Paint()
          ..color = const Color(0xFF2ECC71)
          ..style = PaintingStyle.fill,
      );
    } else if (value < 105) {
      canvas.drawRect(
        Rect.fromLTWH(
            rect.left + 4, rect.top + 28, rect.width - 8, rect.height - 36),
        Paint()
          ..color = const Color(0xFFF39C12)
          ..style = PaintingStyle.fill,
      );
    } else {
      canvas.drawRect(
        Rect.fromLTWH(
            rect.left + 4, rect.top + 28, rect.width - 8, rect.height - 36),
        Paint()
          ..color = const Color(0xFFE74C3C)
          ..style = PaintingStyle.fill,
      );
    }

    // Value text centered
    final tp = TextPainter(
      text: TextSpan(text: '${value.toStringAsFixed(0)}°C'),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: size.width);
    final centerY = rect.top + rect.height / 2 - tp.height / 2;
    tp.paint(canvas, Offset(size.width / 2 - tp.width / 2, centerY));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
