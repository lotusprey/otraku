import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:otraku/extension/card_extension.dart';
import 'package:otraku/util/theming.dart';

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
        // To find the max value to scale everything else
        num maxValue = values.fold(0, (prev, element) => element > prev ? element : prev);
        // Determines max available width for the bars
        double maxBarWidth = constraints.maxWidth; // Offset for labels
        double scale(num value) => value > 0 ? math.log(value + 1) : 0;
        double scaledMax = scale(maxValue);
        final totalValue = values.fold<double>(0, (sum, item) => sum + item);

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
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Row(
                          // Row for labels above the bar
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                names[i],
                                style: TextTheme.of(context).labelMedium,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            Text("${values[i]}", style: TextTheme.of(context).labelMedium),
                          ],
                        ),
                        Text(
                          "${(values[i] / totalValue * 100).toStringAsFixed(1)}%",
                          style: TextTheme.of(context).labelMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    //Stack to contain bars and borders rails
                    Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        //Border Rails
                        Container(
                          width: maxBarWidth,
                          height: 10,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: ColorScheme.of(context).surfaceContainerLowest,
                            border: Border.all(
                              color: ColorScheme.of(context).outlineVariant,
                              width: 1,
                            ),
                          ),
                        ),
                        //bars
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: (scale(values[i]) / scaledMax) * (maxBarWidth - 4),
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: LinearGradient(
                                begin: Alignment.centerRight,
                                end: Alignment.centerLeft,
                                colors: [
                                  ColorScheme.of(context).primary,
                                  ColorScheme.of(context).primary.withValues(alpha: 0.1),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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
