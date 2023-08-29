import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/common/utils/convert.dart';
import 'package:otraku/common/widgets/fields/checkbox_field.dart';
import 'package:otraku/common/widgets/fields/search_field.dart';
import 'package:otraku/common/widgets/grids/chip_grids.dart';
import 'package:otraku/common/widgets/overlays/sheets.dart';
import 'package:otraku/common/widgets/shadowed_overflow_list.dart';
import 'package:otraku/modules/tag/tag_models.dart';
import 'package:otraku/modules/tag/tag_provider.dart';

class TagSelector extends StatefulWidget {
  const TagSelector({
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
  TagSelectorState createState() => TagSelectorState();
}

class TagSelectorState extends State<TagSelector> {
  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    for (int i = 0; i < widget.inclusiveGenres.length; i++) {
      final name = widget.inclusiveGenres[i];
      children.add(_DualStateTagChip(
        key: Key(widget.inclusiveGenres[i]),
        text: Convert.clarifyEnum(name)!,
        positive: true,
        onChanged: (positive) => _toggleGenre(name, positive),
        onDeleted: () => setState(() => widget.inclusiveGenres.remove(name)),
      ));
    }

    for (int i = 0; i < widget.inclusiveTags.length; i++) {
      final name = widget.inclusiveTags[i];
      children.add(_DualStateTagChip(
        key: Key(widget.inclusiveTags[i]),
        text: Convert.clarifyEnum(name)!,
        positive: true,
        onChanged: (positive) => _toggleTag(name, positive),
        onDeleted: () => setState(() => widget.inclusiveTags.remove(name)),
      ));
    }

    for (int i = 0; i < widget.exclusiveGenres.length; i++) {
      final name = widget.exclusiveGenres[i];
      children.add(_DualStateTagChip(
        key: Key(widget.exclusiveGenres[i]),
        text: Convert.clarifyEnum(name)!,
        positive: false,
        onChanged: (positive) => _toggleGenre(name, positive),
        onDeleted: () => setState(() => widget.exclusiveGenres.remove(name)),
      ));
    }

    for (int i = 0; i < widget.exclusiveTags.length; i++) {
      final name = widget.exclusiveTags[i];
      children.add(_DualStateTagChip(
        key: Key(widget.exclusiveTags[i]),
        text: Convert.clarifyEnum(name)!,
        positive: false,
        onChanged: (positive) => _toggleTag(name, positive),
        onDeleted: () => setState(() => widget.exclusiveTags.remove(name)),
      ));
    }

    return ChipGridTemplate(
      title: 'Tags',
      placeholder: 'tags',
      children: children,
      onEdit: () => showSheet(
        context,
        OpaqueSheet(
          builder: (context, scrollCtrl) => _FilterTagSheet(
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
        widget.tagIdIn?.clear();
        widget.tagIdNotIn?.clear();
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

class _DualStateTagChip extends StatefulWidget {
  const _DualStateTagChip({
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
  State<_DualStateTagChip> createState() => _DualStateTagChipState();
}

class _DualStateTagChipState extends State<_DualStateTagChip> {
  late bool _positive = widget.positive;

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(widget.text),
      labelStyle: TextStyle(
        color: _positive
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : Theme.of(context).colorScheme.onErrorContainer,
      ),
      deleteIconColor: _positive
          ? Theme.of(context).colorScheme.onPrimaryContainer
          : Theme.of(context).colorScheme.onErrorContainer,
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

class _FilterTagSheet extends ConsumerStatefulWidget {
  const _FilterTagSheet({
    required this.inclusiveGenres,
    required this.exclusiveGenres,
    required this.inclusiveTags,
    required this.exclusiveTags,
    required this.scrollCtrl,
  });

  final List<String> inclusiveGenres;
  final List<String> exclusiveGenres;
  final List<String> inclusiveTags;
  final List<String> exclusiveTags;
  final ScrollController scrollCtrl;

  @override
  ConsumerState<_FilterTagSheet> createState() => _FilterTagSheetState();
}

class _FilterTagSheetState extends ConsumerState<_FilterTagSheet> {
  late final TagGroup _tags;
  late final List<int> _categoryIndices;
  late final List<int> _itemIndices;
  String _filter = '';
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _tags = ref.read(tagsProvider).valueOrNull!;
    _itemIndices = [..._tags.categoryItems[_index]];
    _categoryIndices = [];
    for (int i = 0; i < _tags.categoryNames.length; i++) {
      _categoryIndices.add(i);
    }
  }

  @override
  Widget build(BuildContext context) {
    late final List<String> inclusive;
    late final List<String> exclusive;
    if (_categoryIndices.isNotEmpty && _categoryIndices[_index] == 0) {
      inclusive = widget.inclusiveGenres;
      exclusive = widget.exclusiveGenres;
    } else {
      inclusive = widget.inclusiveTags;
      exclusive = widget.exclusiveTags;
    }

    return Stack(
      children: [
        if (_itemIndices.isNotEmpty)
          ListView.builder(
            padding: EdgeInsets.only(
              top: 90,
              left: 10,
              right: 10,
              bottom: MediaQuery.of(context).padding.bottom,
            ),
            controller: widget.scrollCtrl,
            itemExtent: Consts.tapTargetSize,
            itemCount: _itemIndices.length,
            itemBuilder: (_, i) {
              final name = _tags.names[_itemIndices[i]];
              return CheckBoxTriField(
                key: Key(name),
                title: name,
                initial: inclusive.contains(name)
                    ? 1
                    : exclusive.contains(name)
                        ? -1
                        : 0,
                onChanged: (state) {
                  if (state == 0) {
                    exclusive.remove(name);
                  } else if (state == 1) {
                    inclusive.add(name);
                  } else {
                    inclusive.remove(name);
                    exclusive.add(name);
                  }
                },
              );
            },
          )
        else
          const Center(child: Text('No Results')),
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Consts.radiusMax),
          child: BackdropFilter(
            filter: Consts.blurFilter,
            child: Container(
              height: 110,
              color: Theme.of(context).navigationBarTheme.backgroundColor,
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                      bottom: 10,
                    ),
                    child: SearchField(
                      hint: 'Tag',
                      value: _filter,
                      onChanged: (val) {
                        _filter = val.toLowerCase();
                        _categoryIndices.clear();
                        _itemIndices.clear();

                        categoryLoop:
                        for (int i = 0; i < _tags.categoryNames.length; i++) {
                          for (final j in _tags.categoryItems[i]) {
                            if (_tags.names[j]
                                .toLowerCase()
                                .contains(_filter)) {
                              _categoryIndices.add(i);
                              continue categoryLoop;
                            }
                          }
                        }

                        if (_categoryIndices.isEmpty) {
                          _index = 0;
                          setState(() {});
                          return;
                        }

                        if (_index >= _categoryIndices.length) {
                          _index = _categoryIndices.length - 1;
                        }

                        final itemsIndex = _categoryIndices[_index];
                        for (final i in _tags.categoryItems[itemsIndex]) {
                          if (_tags.names[i].toLowerCase().contains(_filter)) {
                            _itemIndices.add(i);
                          }
                        }

                        setState(() {});
                      },
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: ShadowedOverflowList(
                      itemCount: _categoryIndices.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: _TagCategoryChip(
                          name: _tags.categoryNames[_categoryIndices[i]],
                          selected: i == _index,
                          onTap: () {
                            if (_index == i) return;

                            _index = i;
                            _itemIndices.clear();

                            final itemsIndex = _categoryIndices[_index];
                            for (final i in _tags.categoryItems[itemsIndex]) {
                              if (_tags.names[i]
                                  .toLowerCase()
                                  .contains(_filter)) _itemIndices.add(i);
                            }

                            setState(() {});
                          },
                        ),
                      ),
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
            ? Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Theme.of(context).colorScheme.background)
            : Theme.of(context).textTheme.bodyMedium,
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
