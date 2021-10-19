import 'package:flutter/material.dart';
import 'package:otraku/utils/config.dart';

class BarChart extends StatelessWidget {
  BarChart({
    required this.title,
    required this.names,
    required this.values,
    this.barWidth = 60,
    this.controls,
  }) : assert(names.length == values.length);

  final String title;
  final Widget? controls;
  final List<dynamic> names;
  final List<num> values;
  final double barWidth;

  @override
  Widget build(BuildContext context) {
    double maxHeight = 200.0;
    num maxValue = 0;
    for (final v in values) if (maxValue < v) maxValue = v;
    maxHeight /= maxValue;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (controls == null)
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 10),
            child: Text(title, style: Theme.of(context).textTheme.headline6),
          )
        else
          Wrap(
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              controls!,
            ],
          ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            physics: Config.PHYSICS,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(10),
            itemCount: names.length,
            itemExtent: barWidth + 10,
            itemBuilder: (_, i) => Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  values[i].toString(),
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: values[i] * maxHeight,
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.5, 1],
                      colors: [
                        Theme.of(context).colorScheme.secondary,
                        Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.2),
                      ],
                    ),
                  ),
                ),
                Text(
                  names[i].toString(),
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
