import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:otraku/tools/fields/chip_field.dart';

class ChipGrid extends StatefulWidget {
  final String title;
  final List<String> options;
  final List<int> inclusive;
  final List<int> exclusive;

  ChipGrid({
    @required this.title,
    @required this.options,
    @required this.inclusive,
    @required this.exclusive,
  });

  @override
  _ChipGridState createState() => _ChipGridState();
}

class _ChipGridState extends State<ChipGrid> {
  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.title, style: Theme.of(context).textTheme.headline4),
              IconButton(
                icon:
                    Icon(FluentSystemIcons.ic_fluent_content_settings_regular),
                onPressed: () {},
              ),
            ],
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(
                  widget.inclusive.length,
                  (index) {
                    int value = widget.inclusive[index];

                    return ChipField(
                      title: widget.options[value],
                      initiallyPositive: true,
                      onChanged: (changed) {
                        if (changed) {
                          widget.exclusive.remove(value);
                          widget.inclusive.add(value);
                        } else {
                          widget.inclusive.remove(value);
                          widget.exclusive.add(value);
                        }
                      },
                      onRemoved: () =>
                          setState(() => widget.inclusive.remove(value)),
                    );
                  },
                ) +
                List.generate(
                  widget.exclusive.length,
                  (index) {
                    int value = widget.exclusive[index];

                    return ChipField(
                      title: widget.options[value],
                      initiallyPositive: false,
                      onChanged: (changed) {
                        if (changed) {
                          widget.exclusive.remove(value);
                          widget.inclusive.add(value);
                        } else {
                          widget.inclusive.remove(value);
                          widget.exclusive.add(value);
                        }
                      },
                      onRemoved: () =>
                          setState(() => widget.exclusive.remove(value)),
                    );
                  },
                ),
          ),
        ],
      );
}
