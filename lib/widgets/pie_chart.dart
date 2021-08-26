import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class PieChart extends StatelessWidget {
  final List<int> categories;
  PieChart(this.categories);

  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: const Alignment(-0.5, -0.5),
              radius: 0.8,
              colors: [
                Theme.of(context).colorScheme.secondary,
                Theme.of(context).colorScheme.secondary.withAlpha(100),
              ],
              stops: const [0.5, 1.0],
            ),
          ),
          child: CustomPaint(
            foregroundPainter: _LineOverlay(
              Theme.of(context).colorScheme.surface,
              categories,
            ),
          ),
        ),
      );
}

class _LineOverlay extends CustomPainter {
  final Color colour;
  final List<int> categories;
  _LineOverlay(this.colour, this.categories);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colour
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;

    double total = 0.0;
    for (final c in categories) total += c;

    final radius = math.min(size.width, size.height) / 2;
    final center = Offset(radius, radius);
    double angle = math.pi;

    for (int i = 0; i < categories.length; i++) {
      angle -= categories[i] / total * math.pi * 2;

      final point = Offset(
        center.dx + radius * math.sin(angle),
        center.dy + radius * math.cos(angle),
      );

      canvas.drawLine(center, point, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineOverlay oldDelegate) => false;
}
