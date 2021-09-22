import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/theming.dart';
import 'package:otraku/widgets/fields/chip_fields.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';

class _ChipGrid extends StatelessWidget {
  final String title;
  final String placeholder;
  final List<Widget> children;
  final void Function() onEdit;
  final void Function()? onClear;

  _ChipGrid({
    required this.title,
    required this.placeholder,
    required this.children,
    required this.onEdit,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(title, style: Theme.of(context).textTheme.subtitle1),
            const Spacer(),
            if (onClear != null && children.length > 0)
              Tooltip(
                message: 'Clear',
                child: GestureDetector(
                  onTap: onClear,
                  child: Container(
                    height: Theming.ICON_SMALL,
                    width: Theming.ICON_SMALL,
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
              tooltip: 'Edit',
              icon: Ionicons.add_circle_outline,
              colour: Theme.of(context).colorScheme.primary,
              onTap: onEdit,
            ),
          ],
        ),
        children.isNotEmpty
            ? Wrap(spacing: 5, children: children)
            : SizedBox(
                height: Config.MATERIAL_TAP_TARGET_SIZE,
                child: Center(
                  child: Text(
                    'No $placeholder',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
              ),
      ],
    );
  }
}

class ChipGrid extends StatefulWidget {
  final String title;
  final String placeholder;
  final List<String> names;
  final void Function(
    List<String> inclusive,
    void Function(List<String>) onDone,
  ) edit;

  ChipGrid({
    required this.title,
    required this.placeholder,
    required this.names,
    required this.edit,
  });

  @override
  _ChipGridState createState() => _ChipGridState();
}

class _ChipGridState extends State<ChipGrid> {
  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (int i = 0; i < widget.names.length; i++)
      children.add(ChipField(
        key: UniqueKey(),
        name: Convert.clarifyEnum(widget.names[i])!,
        onRemoved: () => setState(() => widget.names.removeAt(i)),
      ));

    return _ChipGrid(
      title: widget.title,
      placeholder: widget.placeholder,
      children: children,
      onEdit: () => widget.edit(
        [...widget.names],
        (names) => setState(() {
          widget.names.clear();
          widget.names.addAll(names);
        }),
      ),
      onClear: () => setState(() => widget.names.clear()),
    );
  }
}

class ChipToggleGrid extends StatefulWidget {
  final String title;
  final String placeholder;
  final List<String> inclusive;
  final List<String> exclusive;
  final void Function(
    List<String> inclusive,
    List<String> exclusive,
    void Function(List<String>, List<String>) onDone,
  ) edit;

  ChipToggleGrid({
    required this.title,
    required this.placeholder,
    required this.inclusive,
    required this.exclusive,
    required this.edit,
  });

  @override
  _ChipToggleGridState createState() => _ChipToggleGridState();
}

class _ChipToggleGridState extends State<ChipToggleGrid> {
  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    for (int i = 0; i < widget.inclusive.length; i++) {
      final name = widget.inclusive[i];
      children.add(ChipToggleField(
        key: UniqueKey(),
        name: Convert.clarifyEnum(name)!,
        initial: true,
        onChanged: (positive) => _toggle(name, positive),
        onRemoved: () => setState(() => widget.inclusive.removeAt(i)),
      ));
    }

    for (int i = 0; i < widget.exclusive.length; i++) {
      final name = widget.exclusive[i];
      children.add(ChipToggleField(
        key: UniqueKey(),
        name: Convert.clarifyEnum(name)!,
        initial: false,
        onChanged: (positive) => _toggle(name, positive),
        onRemoved: () => setState(() => widget.exclusive.removeAt(i)),
      ));
    }

    return _ChipGrid(
      title: widget.title,
      placeholder: widget.placeholder,
      children: children,
      onEdit: () => widget.edit(
        [...widget.inclusive],
        [...widget.exclusive],
        (inclusive, exclusive) => setState(() {
          widget.inclusive.clear();
          widget.exclusive.clear();
          widget.inclusive.addAll(inclusive);
          widget.exclusive.addAll(exclusive);
        }),
      ),
      onClear: () => setState(() {
        widget.inclusive.clear();
        widget.exclusive.clear();
      }),
    );
  }

  void _toggle(String name, bool positive) {
    if (positive) {
      widget.inclusive.add(name);
      widget.exclusive.remove(name);
    } else {
      widget.exclusive.add(name);
      widget.inclusive.remove(name);
    }
  }
}

// The names can get modified. On every change onChanged gets called.
class ChipNamingGrid extends StatefulWidget {
  final String title;
  final String placeholder;
  final List<String> names;
  final void Function() onChanged;

  ChipNamingGrid({
    required this.title,
    required this.placeholder,
    required this.names,
    required this.onChanged,
  });

  @override
  _ChipNamingGridState createState() => _ChipNamingGridState();
}

class _ChipNamingGridState extends State<ChipNamingGrid> {
  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (int i = 0; i < widget.names.length; i++)
      children.add(ChipNamingField(
        key: UniqueKey(),
        name: widget.names[i],
        onChanged: (n) {
          setState(() => widget.names[i] = n);
          widget.onChanged();
        },
        onRemoved: () {
          setState(() => widget.names.removeAt(i));
          widget.onChanged();
        },
      ));

    return _ChipGrid(
      title: widget.title,
      placeholder: widget.placeholder,
      children: children,
      onEdit: () {
        String name = '';
        showPopUp(
          context,
          InputDialog(initial: name, onChanged: (n) => name = n),
        ).then((_) {
          if (name.isEmpty || widget.names.contains(name)) return;
          setState(() => widget.names.add(name));
          widget.onChanged();
        });
      },
    );
  }
}
