import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:otraku/extension/card_extension.dart';
import 'package:otraku/util/theming.dart';
//import 'package:otraku/widget/shadowed_overflow_list.dart';

class BarChart extends StatelessWidget {
  const BarChart({required this.title, required this.names, required this.values, this.toolbar})
    : assert(names.length == values.length);

  final String title;
  final List<String> names;
  final List<num> values;
  final Widget? toolbar;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Find the largest value to scale everything else
        num maxValue = values.fold(0, (prev, element) => element > prev ? element : prev);
        // Determine max available width for the bars
        double maxBarWidth = constraints.maxWidth - 100; // Offset for labels

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const .symmetric(vertical: 5),
              child: Text(title, style: TextTheme.of(context).titleSmall),
            ),
            if (toolbar != null)
              SizedBox(
                width: double.infinity,
                child: toolbar!,
              ), //so the toolbar uses full width of the screen.
            Padding(padding: const EdgeInsets.symmetric(vertical: 5)),
            //New logic for the horizontal bars
            ...List.generate(
              names.length,
              (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(
                        names[i],
                        style: TextTheme.of(context).labelMedium,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: (values[i] / maxValue) * maxBarWidth,
                          height: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            gradient: LinearGradient(
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                              stops: const [0, 1],
                              colors: [
                                ColorScheme.of(context).primary,
                                ColorScheme.of(context).primary.withValues(alpha: 0.1),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(values[i].toString()),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
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
