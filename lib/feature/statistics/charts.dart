import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/shadowed_overflow_list.dart';

class BarChart extends StatelessWidget {
  const BarChart({
    required this.title,
    required this.names,
    required this.values,
    this.barWidth = 60,
    this.toolbar,
  }) : assert(names.length == values.length);

  final String title;
  final List<String> names;
  final List<num> values;
  final Widget? toolbar;
  final double barWidth;

  @override
  Widget build(BuildContext context) {
    double maxHeight = 210.0;
    num maxValue = 0;
    for (final v in values) {
      if (maxValue < v) maxValue = v;
    }
    maxHeight /= maxValue;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(title, style: TextTheme.of(context).titleSmall),
        ),
        if (toolbar != null) toolbar!,
        SizedBox(
          height: 280,
          child: ShadowedOverflowList(
            itemCount: names.length,
            itemExtent: barWidth + 5,
            itemBuilder: (_, i) => Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  values[i].toString(),
                  style: TextTheme.of(context).labelMedium,
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: values[i] * maxHeight + Theming.offset,
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0, 1],
                      colors: [
                        ColorScheme.of(context).primary,
                        ColorScheme.of(context).primary.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                ),
                Text(
                  names[i],
                  style: TextTheme.of(context).labelMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PieChart extends StatelessWidget {
  const PieChart({
    required this.title,
    required this.names,
    required this.values,
  }) : assert(names.length == values.length);

  final String title;
  final List<String> names;
  final List<int> values;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextTheme.of(context).titleSmall),
        const SizedBox(height: 5),
        Container(
          height: 225,
          padding: Theming.paddingAll,
          decoration: BoxDecoration(
            borderRadius: Theming.borderRadiusSmall,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: const [0, 1],
              colors: [
                ColorScheme.of(context).surfaceContainerHighest.withAlpha(50),
                ColorScheme.of(context).surfaceContainerHighest.withAlpha(100),
              ],
            ),
          ),
          child: Row(
            mainAxisSize: MediaQuery.sizeOf(context).width > 420
                ? MainAxisSize.min
                : MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: const Alignment(-0.5, -0.5),
                        radius: 0.8,
                        colors: [
                          ColorScheme.of(context).primary,
                          ColorScheme.of(context).primary.withAlpha(100),
                        ],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                    child: CustomPaint(
                      foregroundPainter: _PieLines(
                        ColorScheme.of(context).surface,
                        values,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Theming.offset),
              SizedBox(
                width: 140,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (int i = 0; i < names.length; i++)
                      Row(
                        children: [
                          Expanded(child: Text(names[i])),
                          const SizedBox(width: 5),
                          Text(
                            values[i].toString(),
                            style: TextTheme.of(context).labelMedium,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The lines drawn over the [PieChart] to
/// make the [categories] distinguishable.
class _PieLines extends CustomPainter {
  _PieLines(this.colour, this.categories);

  final Color colour;
  final List<int> categories;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colour
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;

    double total = 0.0;
    for (final c in categories) {
      total += c;
    }

    final radius = math.min(size.width, size.height) / 2;
    final center = Offset(radius, radius);
    final offset = math.pi * 2 - categories.length * 0.05;
    double angle = math.pi;

    for (int i = 0; i < categories.length; i++) {
      angle -= 0.05 + (categories[i] / total) * offset;

      final point = Offset(
        center.dx + radius * math.sin(angle),
        center.dy + radius * math.cos(angle),
      );

      canvas.drawLine(center, point, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PieLines oldDelegate) => false;
}
