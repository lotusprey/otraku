import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/theming.dart';
import 'package:otraku/widgets/fields/chip_field.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';

class ChipGrid extends StatefulWidget {
  final String title;
  final String placeholder;
  final List<String> inclusive;
  final List<String>? exclusive;

  // This opens the sheet of options. It accepts copies of the current inclusive
  // and exclusive, as well as a callback function, which is triggered when the
  // user confirms new changes, that accepts the new inclusive and
  // exclusive.
  final void Function({
    required List<String> inclusive,
    required List<String>? exclusive,
    required void Function(List<String>, List<String>?) onDone,
  }) openSheet;

  ChipGrid({
    required this.title,
    required this.placeholder,
    required this.openSheet,
    required this.inclusive,
    this.exclusive,
  });

  @override
  _ChipGridState createState() => _ChipGridState();
}

class _ChipGridState extends State<ChipGrid> {
  @override
  Widget build(BuildContext context) {
    final chips = <ChipField>[];

    if (widget.exclusive == null)
      for (final val in widget.inclusive)
        chips.add(ChipField(
          key: UniqueKey(),
          title: Convert.clarifyEnum(val)!,
          initiallyPositive: true,
          onRemoved: () => setState(() => widget.inclusive.remove(val)),
        ));
    else {
      for (final val in widget.inclusive)
        chips.add(ChipField(
          key: UniqueKey(),
          title: Convert.clarifyEnum(val)!,
          initiallyPositive: true,
          onRemoved: () => setState(() => widget.inclusive.remove(val)),
          onChanged: (positive) {
            if (positive) {
              widget.exclusive!.remove(val);
              widget.inclusive.add(val);
            } else {
              widget.inclusive.remove(val);
              widget.exclusive!.add(val);
            }
          },
        ));

      for (final val in widget.exclusive!)
        chips.add(ChipField(
          key: UniqueKey(),
          title: Convert.clarifyEnum(val)!,
          initiallyPositive: false,
          onRemoved: () => setState(() => widget.exclusive!.remove(val)),
          onChanged: (positive) {
            if (positive) {
              widget.exclusive!.remove(val);
              widget.inclusive.add(val);
            } else {
              widget.inclusive.remove(val);
              widget.exclusive!.add(val);
            }
          },
        ));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(widget.title, style: Theme.of(context).textTheme.subtitle1),
            const Spacer(),
            if (chips.length > 0)
              Tooltip(
                message: 'Clear',
                child: GestureDetector(
                  onTap: () => setState(() {
                    widget.inclusive.clear();
                    widget.exclusive?.clear();
                  }),
                  child: Container(
                    height: Theming.ICON_BIG,
                    width: Theming.ICON_BIG,
                    margin: Config.PADDING,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.background,
                      size: Theming.ICON_SMALL,
                    ),
                  ),
                ),
              ),
            AppBarIcon(
              tooltip: 'Options',
              icon: Ionicons.options_outline,
              colour: Theme.of(context).colorScheme.primary,
              onTap: () => widget.openSheet(
                inclusive: [...widget.inclusive],
                exclusive:
                    widget.exclusive != null ? [...widget.exclusive!] : null,
                onDone: (List<String> inclusive, List<String>? exclusive) {
                  setState(() {
                    widget.inclusive.clear();
                    widget.inclusive.addAll(inclusive);

                    if (widget.exclusive == null) return;

                    widget.exclusive!.clear();
                    widget.exclusive!.addAll(exclusive!);
                  });
                },
              ),
            ),
          ],
        ),
        chips.isNotEmpty
            ? Wrap(spacing: 10, runSpacing: 10, children: chips)
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
