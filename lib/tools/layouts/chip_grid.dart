import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/app_config.dart';
import 'package:otraku/tools/fields/chip_field.dart';
import 'package:otraku/tools/fields/three_state_field.dart';

class ChipGrid extends StatefulWidget {
  final String title;
  final List<String> options;
  final List<String> inclusive;
  final List<String> exclusive;

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
              Text(widget.title, style: Theme.of(context).textTheme.subtitle1),
              IconButton(
                icon: Icon(FluentSystemIcons.ic_fluent_settings_dev_filled),
                onPressed: () => showModalBottomSheet(
                  context: context,
                  builder: (_) => _OptionSheet(
                    options: widget.options,
                    inclusive: [...widget.inclusive],
                    exclusive: [...widget.exclusive],
                    onDone: (inclusive, exclusive) => setState(() {
                      widget.inclusive
                          .replaceRange(0, widget.inclusive.length, inclusive);
                      widget.exclusive
                          .replaceRange(0, widget.exclusive.length, exclusive);
                    }),
                  ),
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                ),
              ),
            ],
          ),
          widget.inclusive.length + widget.exclusive.length > 0
              ? Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(
                        widget.inclusive.length,
                        (index) {
                          String value = widget.inclusive[index];

                          return ChipField(
                            key: UniqueKey(),
                            title: value,
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
                          String value = widget.exclusive[index];

                          return ChipField(
                            title: value,
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
                )
              : SizedBox(
                  height: AppConfig.MATERIAL_TAP_TARGET_SIZE,
                  child: Center(
                    child: Text(
                      'No selected items',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ),
                ),
        ],
      );
}

class _OptionSheet extends StatelessWidget {
  final List<String> options;
  final List<String> inclusive;
  final List<String> exclusive;
  final Function(List<String>, List<String>) onDone;

  _OptionSheet({
    @required this.options,
    @required this.inclusive,
    @required this.exclusive,
    @required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.mediaQuery.size.height -
          Get.mediaQuery.viewPadding.top -
          Get.mediaQuery.viewPadding.bottom -
          100,
      margin: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: 10,
      ),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: AppConfig.BORDER_RADIUS,
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemBuilder: (_, index) => ThreeStateField(
                title: options[index],
                initialState: inclusive.contains(options[index])
                    ? 1
                    : exclusive.contains(options[index])
                        ? 2
                        : 0,
                onChanged: (state) {
                  if (state == 0) {
                    exclusive.remove(options[index]);
                  } else if (state == 1) {
                    inclusive.add(options[index]);
                  } else {
                    inclusive.remove(options[index]);
                    exclusive.add(options[index]);
                  }
                },
              ),
              itemCount: options.length,
            ),
          ),
          FlatButton.icon(
            onPressed: () {
              onDone(inclusive, exclusive);
              Navigator.pop(context);
            },
            icon: Icon(
              FluentSystemIcons.ic_fluent_checkmark_filled,
              color: Theme.of(context).accentColor,
            ),
            label: Text('Done', style: Theme.of(context).textTheme.bodyText2),
          ),
        ],
      ),
    );
  }
}
