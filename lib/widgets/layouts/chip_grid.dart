import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:otraku/enums/themes.dart';
import 'package:otraku/models/tag_model.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/widgets/action_icon.dart';
import 'package:otraku/widgets/fields/chip_field.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class ChipGrid extends StatefulWidget {
  final String title;
  final String placeholder;
  final List<String>? options;
  final List<String>? values;
  final List<String> inclusive;
  final List<String>? exclusive;
  final Map<String, List<TagModel>>? tags;

  ChipGrid({
    required this.title,
    required this.placeholder,
    required this.inclusive,
    this.options,
    this.values,
    this.exclusive,
    this.tags,
  }) : assert(tags == null || (options == null && values == null));

  @override
  _ChipGridState createState() => _ChipGridState();
}

class _ChipGridState extends State<ChipGrid> {
  @override
  Widget build(BuildContext context) {
    final list = <ChipField>[];
    if (widget.exclusive == null)
      for (final val in widget.inclusive)
        list.add(ChipField(
          key: UniqueKey(),
          title: Convert.clarifyEnum(val)!,
          initiallyPositive: true,
          onRemoved: () => setState(() => widget.inclusive.remove(val)),
        ));
    else {
      for (final val in widget.inclusive)
        list.add(ChipField(
          key: UniqueKey(),
          title: Convert.clarifyEnum(val)!,
          initiallyPositive: true,
          onChanged: (changed) {
            if (changed) {
              widget.exclusive!.remove(val);
              widget.inclusive.add(val);
            } else {
              widget.inclusive.remove(val);
              widget.exclusive!.add(val);
            }
          },
          onRemoved: () => setState(() => widget.inclusive.remove(val)),
        ));
      for (final val in widget.exclusive!)
        list.add(ChipField(
          key: UniqueKey(),
          title: Convert.clarifyEnum(val)!,
          initiallyPositive: false,
          onChanged: (changed) {
            if (changed) {
              widget.exclusive!.remove(val);
              widget.inclusive.add(val);
            } else {
              widget.inclusive.remove(val);
              widget.exclusive!.add(val);
            }
          },
          onRemoved: () => setState(() => widget.exclusive!.remove(val)),
        ));
    }

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
                        widget.inclusive.clear();
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
                const SizedBox(width: 15),
                ActionIcon(
                  tooltip: 'Options',
                  icon: FluentIcons.options_24_regular,
                  onTap: () => Sheet.show(
                    ctx: context,
                    sheet: widget.tags != null
                        ? _tagSheet()
                        : SelectionSheet(
                            options: widget.options!,
                            values: widget.values!,
                            inclusive: [...widget.inclusive],
                            exclusive: widget.exclusive != null
                                ? [...widget.exclusive!]
                                : null,
                            fixHeight: widget.options!.length <= 10,
                            onDone: (inclusive, exclusive) {
                              setState(() {
                                widget.inclusive.clear();
                                for (final i in inclusive as List<String>)
                                  widget.inclusive.add(i);
                                if (widget.exclusive != null) {
                                  widget.exclusive!.clear();
                                  for (final e in exclusive! as List<String>)
                                    widget.exclusive!.add(e);
                                }
                              });
                            },
                          ),
                    isScrollControlled: widget.options != null
                        ? widget.options!.length <= 10
                        : false,
                  ),
                ),
              ],
            ),
          ],
        ),
        list.isNotEmpty
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

  Widget _tagSheet() => TagSelectionSheet(
        tags: widget.tags!,
        inclusive: [...widget.inclusive],
        exclusive: [...widget.exclusive!],
        onDone: (inclusive, exclusive) {
          setState(() {
            widget.inclusive.clear();
            for (final i in inclusive) widget.inclusive.add(i);
            if (widget.exclusive != null) {
              widget.exclusive!.clear();
              for (final e in exclusive) widget.exclusive!.add(e);
            }
          });
        },
      );
}
