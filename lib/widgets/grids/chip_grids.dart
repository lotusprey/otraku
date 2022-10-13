import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/utils/consts.dart';
import 'package:otraku/tag/tag_models.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/filter/filter_view.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class ChipOptionField extends StatelessWidget {
  const ChipOptionField({
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final bool selected;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(name),
        labelStyle: selected
            ? Theme.of(context).textTheme.button
            : Theme.of(context).textTheme.bodyText2,
        backgroundColor: selected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSecondary,
        side: selected
            ? BorderSide(color: Theme.of(context).colorScheme.primary)
            : BorderSide(color: Theme.of(context).colorScheme.onBackground),
      ),
    );
  }
}

/// An input chip that can switch between positive/negative state.
class _InputChip extends StatefulWidget {
  const _InputChip({
    required super.key,
    required this.text,
    required this.positive,
    required this.onChanged,
    required this.onDeleted,
  });

  final String text;
  final bool positive;
  final void Function(bool) onChanged;
  final void Function() onDeleted;

  @override
  State<_InputChip> createState() => __InputChipState();
}

class __InputChipState extends State<_InputChip> {
  late bool _positive = widget.positive;

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(widget.text),
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSecondaryContainer,
      ),
      backgroundColor: _positive
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.errorContainer,
      onDeleted: widget.onDeleted,
      onPressed: () {
        setState(() => _positive = !_positive);
        widget.onChanged(_positive);
      },
    );
  }
}

class _ChipGrid extends StatelessWidget {
  const _ChipGrid({
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
            Text(title, style: Theme.of(context).textTheme.subtitle1),
            const Spacer(),
            if (onClear != null && children.isNotEmpty)
              SizedBox(
                height: 35,
                child: IconButton(
                  icon: const Icon(Ionicons.close_outline),
                  tooltip: 'Close',
                  onPressed: onClear!,
                  color: Theme.of(context).colorScheme.onBackground,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
            SizedBox(
              height: 35,
              child: IconButton(
                icon: const Icon(Ionicons.add_circle_outline),
                tooltip: 'Edit',
                onPressed: onEdit,
                color: Theme.of(context).colorScheme.onBackground,
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
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
              ),
      ],
    );
  }
}

// The names can get modified. On every change onChanged gets called.
class ChipNamingGrid extends StatefulWidget {
  final String title;
  final String placeholder;
  final List<String> names;

  const ChipNamingGrid({
    required this.title,
    required this.placeholder,
    required this.names,
  });

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
        onDeleted: () => setState(() => widget.names.removeAt(i)),
        onPressed: () => showPopUp(
          context,
          InputDialog(
            initial: widget.names[i],
            onChanged: (name) =>
                name.isNotEmpty ? setState(() => widget.names[i] = name) : null,
          ),
        ),
      ));
    }

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
          if (name.isNotEmpty && !widget.names.contains(name)) {
            setState(() => widget.names.add(name));
          }
        });
      },
    );
  }
}

class ChipTagGrid extends StatefulWidget {
  const ChipTagGrid({
    required this.inclusiveGenres,
    required this.exclusiveGenres,
    required this.inclusiveTags,
    required this.exclusiveTags,
    this.tags,
    this.tagIdIn,
    this.tagIdNotIn,
  });

  final List<String> inclusiveGenres;
  final List<String> exclusiveGenres;
  final List<String> inclusiveTags;
  final List<String> exclusiveTags;
  final TagGroup? tags;
  final List<int>? tagIdIn;
  final List<int>? tagIdNotIn;

  @override
  ChipTagGridState createState() => ChipTagGridState();
}

class ChipTagGridState extends State<ChipTagGrid> {
  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    for (int i = 0; i < widget.inclusiveGenres.length; i++) {
      final name = widget.inclusiveGenres[i];
      children.add(_InputChip(
        key: Key(widget.inclusiveGenres[i]),
        text: Convert.clarifyEnum(name)!,
        positive: true,
        onChanged: (positive) => _toggleGenre(name, positive),
        onDeleted: () => setState(() => widget.inclusiveGenres.remove(name)),
      ));
    }

    for (int i = 0; i < widget.inclusiveTags.length; i++) {
      final name = widget.inclusiveTags[i];
      children.add(_InputChip(
        key: Key(widget.inclusiveTags[i]),
        text: Convert.clarifyEnum(name)!,
        positive: true,
        onChanged: (positive) => _toggleTag(name, positive),
        onDeleted: () => setState(() => widget.inclusiveTags.remove(name)),
      ));
    }

    for (int i = 0; i < widget.exclusiveGenres.length; i++) {
      final name = widget.exclusiveGenres[i];
      children.add(_InputChip(
        key: Key(widget.exclusiveGenres[i]),
        text: Convert.clarifyEnum(name)!,
        positive: false,
        onChanged: (positive) => _toggleGenre(name, positive),
        onDeleted: () => setState(() => widget.exclusiveGenres.remove(name)),
      ));
    }

    for (int i = 0; i < widget.exclusiveTags.length; i++) {
      final name = widget.exclusiveTags[i];
      children.add(_InputChip(
        key: Key(widget.exclusiveTags[i]),
        text: Convert.clarifyEnum(name)!,
        positive: false,
        onChanged: (positive) => _toggleTag(name, positive),
        onDeleted: () => setState(() => widget.exclusiveTags.remove(name)),
      ));
    }

    return _ChipGrid(
      title: 'Tags',
      placeholder: 'tags',
      children: children,
      onEdit: () => showSheet(
        context,
        OpaqueSheet(
          builder: (context, scrollCtrl) => TagSheetBody(
            inclusiveGenres: widget.inclusiveGenres,
            exclusiveGenres: widget.exclusiveGenres,
            inclusiveTags: widget.inclusiveTags,
            exclusiveTags: widget.exclusiveTags,
            scrollCtrl: scrollCtrl,
          ),
        ),
      ).then((_) {
        setState(() {});

        if (widget.tags == null ||
            widget.tagIdIn == null ||
            widget.tagIdNotIn == null) return;

        widget.tagIdIn!.clear();
        widget.tagIdNotIn!.clear();
        for (final t in widget.inclusiveTags) {
          final i = widget.tags!.indices[t];
          if (i == null) continue;
          widget.tagIdIn!.add(widget.tags!.ids[i]);
        }
        for (final t in widget.exclusiveTags) {
          final i = widget.tags!.indices[t];
          if (i == null) continue;
          widget.tagIdNotIn!.add(widget.tags!.ids[i]);
        }
      }),
      onClear: () => setState(() {
        widget.inclusiveGenres.clear();
        widget.exclusiveGenres.clear();
        widget.inclusiveTags.clear();
        widget.exclusiveTags.clear();
      }),
    );
  }

  void _toggleGenre(String name, bool positive) {
    if (positive) {
      widget.inclusiveGenres.add(name);
      widget.exclusiveGenres.remove(name);
    } else {
      widget.exclusiveGenres.add(name);
      widget.inclusiveGenres.remove(name);
    }
  }

  void _toggleTag(String name, bool positive) {
    if (positive) {
      widget.inclusiveTags.add(name);
      widget.exclusiveTags.remove(name);
    } else {
      widget.exclusiveTags.add(name);
      widget.inclusiveTags.remove(name);
    }
  }
}
