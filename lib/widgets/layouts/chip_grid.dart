import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:otraku/enums/themes.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/widgets/fields/chip_field.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class ChipGrid<T> extends StatefulWidget {
  final String title;
  final String placeholder;
  final List<String> options;
  final List<T> values;
  final List<T>? inclusive;
  final List<T>? exclusive;

  ChipGrid({
    required this.title,
    required this.placeholder,
    required this.options,
    required this.values,
    required this.inclusive,
    this.exclusive,
  });

  @override
  _ChipGridState createState() => _ChipGridState();
}

class _ChipGridState extends State<ChipGrid> {
  @override
  Widget build(BuildContext context) {
    final list = List.generate(
        widget.inclusive!.length + (widget.exclusive?.length ?? 0), (index) {
      final value = index < widget.inclusive!.length
          ? widget.inclusive![index]
          : widget.exclusive![index - widget.inclusive!.length];
      return ChipField(
        key: UniqueKey(),
        title: Convert.clarifyEnum(value),
        initiallyPositive: index < widget.inclusive!.length,
        onChanged: widget.exclusive == null
            ? null
            : (changed) {
                if (changed) {
                  widget.exclusive!.remove(value);
                  widget.inclusive!.add(value);
                } else {
                  widget.inclusive!.remove(value);
                  widget.exclusive!.add(value);
                }
              },
        onRemoved: () {
          if (index < widget.inclusive!.length)
            setState(() => widget.inclusive!.remove(value));
          else
            setState(() => widget.exclusive!.remove(value));
        },
      );
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.title, style: Theme.of(context).textTheme.subtitle1),
            Row(
              children: [
                if (list.length > 0)
                  Tooltip(
                    message: 'Clear',
                    child: GestureDetector(
                      onTap: () => setState(() {
                        widget.inclusive!.clear();
                        widget.exclusive?.clear();
                      }),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).disabledColor,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Theme.of(context).backgroundColor,
                          size: Style.ICON_SMALL,
                        ),
                      ),
                    ),
                  ),
                IconButton(
                  tooltip: 'Options',
                  icon: Icon(FluentIcons.options_24_regular),
                  onPressed: () => Sheet.show(
                    ctx: context,
                    sheet: SelectionSheet(
                      options: widget.options,
                      values: widget.values,
                      inclusive: [...widget.inclusive!],
                      exclusive: widget.exclusive != null
                          ? [...widget.exclusive!]
                          : null,
                      fixHeight: widget.options.length <= 10,
                      onDone: (inclusive, exclusive) {
                        setState(() {
                          widget.inclusive!.clear();
                          for (final i in inclusive) widget.inclusive!.add(i);
                          if (widget.exclusive != null) {
                            widget.exclusive!.clear();
                            for (final e in exclusive!)
                              widget.exclusive!.add(e);
                          }
                        });
                      },
                    ),
                    isScrollControlled: widget.options.length <= 10,
                  ),
                ),
              ],
            ),
          ],
        ),
        list.length > 0
            ? Wrap(spacing: 10, runSpacing: 10, children: list)
            : SizedBox(
                height: Config.MATERIAL_TAP_TARGET_SIZE,
                child: Center(
                  child: Text(
                    'No selected ${widget.placeholder}',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
              ),
      ],
    );
  }
}
