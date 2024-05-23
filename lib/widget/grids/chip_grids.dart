import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/util/consts.dart';
import 'package:otraku/widget/overlays/dialogs.dart';

class ChipGridTemplate extends StatelessWidget {
  const ChipGridTemplate({
    required this.title,
    required this.placeholder,
    required this.children,
    required this.onEdit,
    this.onClear,
  });

  final String title;
  final String placeholder;
  final List<Widget> children;
  final void Function() onEdit;
  final void Function()? onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(title),
            const Spacer(),
            if (onClear != null && children.isNotEmpty)
              SizedBox(
                height: 35,
                child: IconButton(
                  key: const ValueKey('Clear'),
                  icon: const Icon(Ionicons.close_outline),
                  tooltip: 'Clear',
                  onPressed: onClear!,
                  color: Theme.of(context).colorScheme.onSurface,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
            SizedBox(
              height: 35,
              child: IconButton(
                icon: const Icon(Ionicons.add_circle_outline),
                tooltip: 'Edit',
                onPressed: onEdit,
                color: Theme.of(context).colorScheme.onSurface,
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          ],
        ),
        children.isNotEmpty
            ? Wrap(spacing: 5, children: children)
            : SizedBox(
                height: Consts.tapTargetSize,
                child: Center(
                  child: Text(
                    'No $placeholder',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ),
      ],
    );
  }
}

// The names can get modified. On every change onChanged gets called.
class ChipNamingGrid extends StatefulWidget {
  const ChipNamingGrid({
    required this.title,
    required this.placeholder,
    required this.names,
    required this.onChanged,
  });

  final String title;
  final String placeholder;
  final List<String> names;
  final void Function() onChanged;

  @override
  ChipNamingGridState createState() => ChipNamingGridState();
}

class ChipNamingGridState extends State<ChipNamingGrid> {
  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (int i = 0; i < widget.names.length; i++) {
      children.add(InputChip(
        key: Key(widget.names[i]),
        label: Text(widget.names[i]),
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
        onDeleted: () {
          setState(() => widget.names.removeAt(i));
          widget.onChanged();
        },
        onPressed: () => showPopUp(
          context,
          InputDialog(
            initial: widget.names[i],
            onChanged: (name) {
              if (name.isNotEmpty) {
                setState(() => widget.names[i] = name);
                widget.onChanged();
              }
            },
          ),
        ),
      ));
    }

    return ChipGridTemplate(
      title: widget.title,
      placeholder: widget.placeholder,
      children: children,
      onEdit: () {
        String name = '';
        showPopUp(
          context,
          InputDialog(initial: name, onChanged: (n) => name = n),
        ).then((_) {
          if (name.isNotEmpty && !widget.names.contains(name)) {
            setState(() => widget.names.add(name));
            widget.onChanged();
          }
        });
      },
    );
  }
}
