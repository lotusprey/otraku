import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/extension/iterable_extension.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/input/search_field.dart';
import 'package:otraku/widget/input/stateful_tiles.dart';
import 'package:otraku/widget/grid/chip_grids.dart';
import 'package:otraku/widget/loaders.dart';
import 'package:otraku/widget/sheets.dart';
import 'package:otraku/widget/shadowed_overflow_list.dart';
import 'package:otraku/feature/tag/tag_model.dart';
import 'package:otraku/feature/tag/tag_provider.dart';

class TagPicker extends StatefulWidget {
  const TagPicker({
    required this.includedGenres,
    required this.excludedGenres,
    required this.includedTags,
    required this.excludedTags,
  });

  final List<String> includedGenres;
  final List<String> excludedGenres;
  final List<String> includedTags;
  final List<String> excludedTags;

  @override
  TagPickerState createState() => TagPickerState();
}

class TagPickerState extends State<TagPicker> {
  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    for (final name in widget.includedGenres) {
      children.add(_DualStateTagChip(
        key: Key(name),
        label: name,
        positive: true,
        onChanged: (positive) => _toggleGenre(name, positive),
        onRemoved: () => setState(() => widget.includedGenres.remove(name)),
      ));
    }

    for (final name in widget.excludedGenres) {
      children.add(_DualStateTagChip(
        key: Key(name),
        label: name,
        positive: false,
        onChanged: (positive) => _toggleGenre(name, positive),
        onRemoved: () => setState(() => widget.excludedGenres.remove(name)),
      ));
    }

    for (final name in widget.includedTags) {
      children.add(_DualStateTagChip(
        key: Key(name),
        label: name,
        positive: true,
        onChanged: (positive) => _toggleTag(name, positive),
        onRemoved: () => setState(() => widget.includedTags.remove(name)),
      ));
    }

    for (final name in widget.excludedTags) {
      children.add(_DualStateTagChip(
        key: Key(name),
        label: name,
        positive: false,
        onChanged: (positive) => _toggleTag(name, positive),
        onRemoved: () => setState(() => widget.excludedTags.remove(name)),
      ));
    }

    return ChipGridTemplate(
      title: 'Tags',
      placeholder: 'tags',
      children: children,
      onEdit: () => showSheet(
        context,
        SimpleSheet(
          builder: (context, scrollCtrl) => Consumer(
            builder: (context, ref, child) {
              TagCollection tags;
              switch (ref.watch(tagsProvider)) {
                case AsyncData(:final value):
                  tags = value;
                  break;
                case AsyncError(:final error):
                  return Center(
                    child: Padding(
                      padding: Theming.paddingAll,
                      child: Text('Failed to load tags: ${error.toString()}'),
                    ),
                  );
                case AsyncLoading():
                  return const Center(child: Loader());
              }

              return _FilterTagSheet(
                tags: tags,
                includedGenres: widget.includedGenres,
                excludedGenres: widget.excludedGenres,
                includedTags: widget.includedTags,
                excludedTags: widget.excludedTags,
                scrollCtrl: scrollCtrl,
              );
            },
          ),
        ),
      ).then((_) => setState(() {})),
      onClear: () => setState(() {
        widget.includedGenres.clear();
        widget.excludedGenres.clear();
        widget.includedTags.clear();
        widget.excludedTags.clear();
      }),
    );
  }

  void _toggleGenre(String name, bool positive) {
    if (positive) {
      widget.includedGenres.add(name);
      widget.excludedGenres.remove(name);
    } else {
      widget.excludedGenres.add(name);
      widget.includedGenres.remove(name);
    }
  }

  void _toggleTag(String name, bool positive) {
    if (positive) {
      widget.includedTags.add(name);
      widget.excludedTags.remove(name);
    } else {
      widget.excludedTags.add(name);
      widget.includedTags.remove(name);
    }
  }
}

class _DualStateTagChip extends StatefulWidget {
  const _DualStateTagChip({
    required super.key,
    required this.label,
    required this.positive,
    required this.onChanged,
    required this.onRemoved,
  });

  final String label;
  final bool positive;
  final void Function(bool) onChanged;
  final void Function() onRemoved;

  @override
  State<_DualStateTagChip> createState() => _DualStateTagChipState();
}

class _DualStateTagChipState extends State<_DualStateTagChip> {
  late bool _positive = widget.positive;

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(widget.label),
      labelStyle: TextStyle(
        color: _positive
            ? ColorScheme.of(context).onSecondaryContainer
            : ColorScheme.of(context).onErrorContainer,
      ),
      deleteIconColor: _positive
          ? ColorScheme.of(context).onSecondaryContainer
          : ColorScheme.of(context).onErrorContainer,
      backgroundColor: _positive
          ? ColorScheme.of(context).secondaryContainer
          : ColorScheme.of(context).errorContainer,
      onDeleted: widget.onRemoved,
      onPressed: () {
        setState(() => _positive = !_positive);
        widget.onChanged(_positive);
      },
    );
  }
}

class _FilterTagSheet extends ConsumerStatefulWidget {
  const _FilterTagSheet({
    required this.tags,
    required this.includedGenres,
    required this.excludedGenres,
    required this.includedTags,
    required this.excludedTags,
    required this.scrollCtrl,
  });

  final TagCollection tags;
  final List<String> includedGenres;
  final List<String> excludedGenres;
  final List<String> includedTags;
  final List<String> excludedTags;
  final ScrollController scrollCtrl;

  @override
  ConsumerState<_FilterTagSheet> createState() => _FilterTagSheetState();
}

class _FilterTagSheetState extends ConsumerState<_FilterTagSheet> {
  late final List<int> _itemIndexes;
  late final List<int> _categoryIndexes;
  String _filter = '';
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _itemIndexes = [...widget.tags.categories[_index].indexes];
    _categoryIndexes = List.generate(widget.tags.categories.length, (i) => i);
  }

  @override
  Widget build(BuildContext context) {
    late final List<String> included;
    late final List<String> excluded;
    if (_categoryIndexes.isNotEmpty && _categoryIndexes[_index] == 0) {
      included = widget.includedGenres;
      excluded = widget.excludedGenres;
    } else {
      included = widget.includedTags;
      excluded = widget.excludedTags;
    }

    return Stack(
      children: [
        if (_itemIndexes.isNotEmpty)
          Material(
            color: Colors.transparent,
            child: ListView.builder(
              padding: EdgeInsets.only(
                top: 110,
                bottom: MediaQuery.paddingOf(context).bottom,
              ),
              controller: widget.scrollCtrl,
              itemCount: _itemIndexes.length,
              itemExtent: 56,
              itemBuilder: (_, i) {
                final name = widget.tags.names[_itemIndexes[i]];
                return StatefulCheckboxListTile(
                  title: Text(name),
                  tristate: true,
                  value: included.contains(name)
                      ? true
                      : excluded.contains(name)
                          ? null
                          : false,
                  onChanged: (v) {
                    if (v == null) {
                      included.remove(name);
                      excluded.add(name);
                    } else if (v) {
                      included.add(name);
                    } else {
                      excluded.remove(name);
                    }
                  },
                );
              },
            ),
          )
        else
          const Center(child: Text('No Results')),
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Theming.radiusBig),
          child: BackdropFilter(
            filter: Theming.blurFilter,
            child: Container(
              height: 110,
              color: Theme.of(context).navigationBarTheme.backgroundColor,
              padding: const EdgeInsets.symmetric(vertical: Theming.offset),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: Theming.offset,
                      right: Theming.offset,
                      bottom: Theming.offset,
                    ),
                    child: SearchField(
                      hint: 'Tag',
                      value: _filter,
                      onChanged: _onSearch,
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: ShadowedOverflowList(
                      itemCount: _categoryIndexes.length,
                      itemBuilder: _categoryChipBuilder,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onSearch(String val) {
    final tags = widget.tags;
    _filter = val.toLowerCase();
    _categoryIndexes.clear();
    _itemIndexes.clear();

    for (int i = 0; i < tags.categories.length; i++) {
      final matchingTag = tags.categories[i].indexes.firstWhereOrNull(
        (index) => tags.names[index].toLowerCase().contains(_filter),
      );

      if (matchingTag != null) {
        _categoryIndexes.add(i);
      }
    }

    if (_categoryIndexes.isEmpty) {
      _index = 0;
      setState(() {});
      return;
    }

    if (_index >= _categoryIndexes.length) {
      _index = _categoryIndexes.length - 1;
    }

    for (final i in tags.categories[_categoryIndexes[_index]].indexes) {
      if (tags.names[i].toLowerCase().contains(_filter)) {
        _itemIndexes.add(i);
      }
    }

    setState(() {});
  }

  Widget _categoryChipBuilder(BuildContext context, int i) {
    final tags = widget.tags;

    return _TagCategoryChip(
      name: tags.categories[_categoryIndexes[i]].name,
      selected: i == _index,
      onTap: () {
        if (_index == i) return;

        _index = i;
        _itemIndexes.clear();

        for (final i in tags.categories[_categoryIndexes[_index]].indexes) {
          if (tags.names[i].toLowerCase().contains(_filter)) {
            _itemIndexes.add(i);
          }
        }

        setState(() {});
      },
    );
  }
}

class _TagCategoryChip extends StatelessWidget {
  const _TagCategoryChip({
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
            ? TextTheme.of(context).bodyMedium?.copyWith(color: ColorScheme.of(context).surface)
            : TextTheme.of(context).bodyMedium,
        backgroundColor:
            selected ? ColorScheme.of(context).primary : ColorScheme.of(context).onSecondary,
        side: selected
            ? BorderSide(color: ColorScheme.of(context).primary)
            : BorderSide(color: ColorScheme.of(context).onSurface),
      ),
    );
  }
}
