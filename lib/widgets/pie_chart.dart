import 'dart:math';
import 'package:flutter/material.dart';

class PieChart extends StatelessWidget {
  final List<int> categories;
  final List<Color> colours;
  PieChart(this.categories, this.colours)
      : assert(categories.length == colours.length);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (_, constraints) => SizedBox(
          height: constraints.maxHeight,
          width: constraints.maxHeight,
          child: CustomPaint(
            foregroundPainter: _PieChartPainter(categories, colours),
          ),
        ),
      );
}

class _PieChartPainter extends CustomPainter {
  final List<int> categories;
  final List<Color> colours;
  _PieChartPainter(this.categories, this.colours);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width < size.height ? size.width / 2 : size.height / 2;

    final paint = Paint()..style = PaintingStyle.fill;

    double total = 0.0;
    for (final c in categories) total += c;

    double startAngle = -pi / 2;
    for (int i = 0; i < categories.length; i++) {
      paint.color = colours[i];
      final sweepAngle = categories[i] / total * 2 * pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) => false;
}
