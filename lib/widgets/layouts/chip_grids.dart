import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/views/filter_view.dart';
import 'package:otraku/widgets/fields/chip_fields.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class _ChipGrid extends StatelessWidget {
  _ChipGrid({
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
            if (onClear != null && children.length > 0)
              Tooltip(
                message: 'Clear',
                child: GestureDetector(
                  onTap: onClear,
                  child: Container(
                    height: Consts.ICON_SMALL,
                    width: Consts.ICON_SMALL,
                    margin: Consts.PADDING,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.background,
                      size: Consts.ICON_SMALL,
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
                height: Consts.MATERIAL_TAP_TARGET_SIZE,
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
  ChipGrid({
    required this.title,
    required this.placeholder,
    required this.names,
    required this.onEdit,
  });

  final String title;
  final String placeholder;
  final List<String> names;
  final Future<void> Function(List<String>) onEdit;

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
      onEdit: () => widget.onEdit(widget.names).then((_) => setState(() {})),
      onClear: () => setState(() => widget.names.clear()),
    );
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

class ChipTagGrid extends StatefulWidget {
  ChipTagGrid({
    required this.title,
    required this.placeholder,
    required this.inclusiveGenres,
    required this.exclusiveGenres,
    required this.inclusiveTags,
    required this.exclusiveTags,
  });

  final String title;
  final String placeholder;
  final List<String> inclusiveGenres;
  final List<String> exclusiveGenres;
  final List<String> inclusiveTags;
  final List<String> exclusiveTags;

  @override
  _ChipTagGridState createState() => _ChipTagGridState();
}

class _ChipTagGridState extends State<ChipTagGrid> {
  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    for (int i = 0; i < widget.inclusiveGenres.length; i++) {
      final name = widget.inclusiveGenres[i];
      children.add(ChipToggleField(
        key: UniqueKey(),
        name: Convert.clarifyEnum(name)!,
        initial: true,
        onChanged: (positive) => _toggleGenre(name, positive),
        onRemoved: () => setState(() => widget.inclusiveGenres.remove(name)),
      ));
    }

    for (int i = 0; i < widget.inclusiveTags.length; i++) {
      final name = widget.inclusiveTags[i];
      children.add(ChipToggleField(
        key: UniqueKey(),
        name: Convert.clarifyEnum(name)!,
        initial: true,
        onChanged: (positive) => _toggleTag(name, positive),
        onRemoved: () => setState(() => widget.inclusiveTags.remove(name)),
      ));
    }

    for (int i = 0; i < widget.exclusiveGenres.length; i++) {
      final name = widget.exclusiveGenres[i];
      children.add(ChipToggleField(
        key: UniqueKey(),
        name: Convert.clarifyEnum(name)!,
        initial: false,
        onChanged: (positive) => _toggleGenre(name, positive),
        onRemoved: () => setState(() => widget.exclusiveGenres.remove(name)),
      ));
    }

    for (int i = 0; i < widget.exclusiveTags.length; i++) {
      final name = widget.exclusiveTags[i];
      children.add(ChipToggleField(
        key: UniqueKey(),
        name: Convert.clarifyEnum(name)!,
        initial: false,
        onChanged: (positive) => _toggleTag(name, positive),
        onRemoved: () => setState(() => widget.exclusiveTags.remove(name)),
      ));
    }

    return _ChipGrid(
      title: widget.title,
      placeholder: widget.placeholder,
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
      ).then((_) => setState(() {})),
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
