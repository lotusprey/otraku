import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/common/widgets/shadowed_overflow_list.dart';

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
    double maxHeight = 190.0;
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
          child: Text(title, style: Theme.of(context).textTheme.titleSmall),
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
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: values[i] * maxHeight + 10,
                  margin: const EdgeInsets.only(right: 5, top: 5, bottom: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0, 1],
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
                Text(names[i], style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PieChart extends StatelessWidget {
  const PieChart(
      {required this.title, required this.names, required this.values})
      : assert(names.length == values.length);

  final String title;
  final List<String> names;
  final List<int> values;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 5),
        Container(
          height: 225,
          padding: Consts.padding,
          decoration: BoxDecoration(
            borderRadius: Consts.borderRadiusMin,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: const [0, 1],
              colors: [
                Theme.of(context).colorScheme.surfaceVariant.withAlpha(50),
                Theme.of(context).colorScheme.surfaceVariant.withAlpha(100),
              ],
            ),
          ),
          child: Row(
            mainAxisSize: MediaQuery.of(context).size.width > 420
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
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primary.withAlpha(100),
                        ],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                    child: CustomPaint(
                      foregroundPainter: _PieLines(
                        Theme.of(context).colorScheme.background,
                        values,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
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
                            style: Theme.of(context).textTheme.labelMedium,
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
