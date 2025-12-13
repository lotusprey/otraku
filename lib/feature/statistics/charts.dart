import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:otraku/extension/card_extension.dart';
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
      mainAxisSize: .min,
      crossAxisAlignment: .stretch,
      children: [
        Padding(
          padding: const .symmetric(vertical: 5),
          child: Text(title, style: TextTheme.of(context).titleSmall),
        ),
        if (toolbar != null) toolbar!,
        SizedBox(
          height: 280,
          child: ShadowedOverflowList(
            itemCount: names.length,
            itemExtent: barWidth + 5,
            itemBuilder: (_, i) => Column(
              mainAxisAlignment: .end,
              children: [
                Text(
                  values[i].toString(),
                  style: TextTheme.of(context).labelMedium,
                  overflow: .ellipsis,
                  maxLines: 1,
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: values[i] * maxHeight + Theming.offset,
                  margin: const .symmetric(vertical: 5),
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
                  overflow: .ellipsis,
                  maxLines: 1,
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
    required this.highContrast,
  }) : assert(names.length == values.length);

  final String title;
  final List<String> names;
  final List<int> values;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);

    final container = CardExtension.highContrast(highContrast)(
      child: Row(
        mainAxisSize: MediaQuery.sizeOf(context).width > 420 ? .min : .max,
        mainAxisAlignment: .spaceBetween,
        spacing: Theming.offset,
        children: [
          Expanded(
            child: Padding(
              padding: const .all(Theming.offset),
              child: AspectRatio(
                aspectRatio: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: .circle,
                    gradient: RadialGradient(
                      center: const Alignment(-0.5, -0.5),
                      radius: 0.8,
                      colors: [colorScheme.primary, colorScheme.primary.withAlpha(100)],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                  child: CustomPaint(foregroundPainter: _PieLines(colorScheme.surface, values)),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const .only(top: 5, bottom: 5, right: Theming.offset),
              itemCount: names.length,
              itemBuilder: (context, i) => Padding(
                padding: const .symmetric(vertical: 5),
                child: Row(
                  spacing: 5,
                  children: [
                    Expanded(child: Text(names[i])),
                    Text(values[i].toString(), style: TextTheme.of(context).labelMedium),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .start,
      spacing: 5,
      children: [
        Text(title, style: TextTheme.of(context).titleSmall),
        Expanded(child: container),
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
