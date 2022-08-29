import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/constants/entry_sort.dart';
import 'package:otraku/constants/anime_format.dart';
import 'package:otraku/constants/media_sort.dart';
import 'package:otraku/filter/filter_models.dart';
import 'package:otraku/filter/filter_tools.dart';
import 'package:otraku/tag/tag_models.dart';
import 'package:otraku/tag/tag_provider.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/constants/manga_format.dart';
import 'package:otraku/constants/media_status.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/widgets/fields/checkbox_field.dart';
import 'package:otraku/widgets/fields/chip_fields.dart';
import 'package:otraku/widgets/fields/search_field.dart';
import 'package:otraku/widgets/grids/sliver_grid_delegates.dart';
import 'package:otraku/widgets/layouts/bottom_bar.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';
import 'package:otraku/widgets/grids/chip_grids.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class _FilterView<T extends ApplicableMediaFilter<T>> extends StatefulWidget {
  const _FilterView({
    required this.filter,
    required this.onChanged,
    required this.builder,
  });

  final T filter;
  final void Function(T) onChanged;
  final Widget Function(BuildContext, ScrollController, T) builder;

  @override
  State<_FilterView<T>> createState() => __FilterViewState<T>();
}

class __FilterViewState<T extends ApplicableMediaFilter<T>>
    extends State<_FilterView<T>> {
  late final T _filter = widget.filter.copy();

  @override
  Widget build(BuildContext context) {
    return OpaqueSheetView(
      buttons: BottomBarDualButtonRow(
        primary: BottomBarButton(
          text: 'Apply',
          icon: Icons.done_rounded,
          onTap: () {
            widget.onChanged(_filter);
            Navigator.pop(context);
          },
        ),
        secondary: BottomBarButton(
          text: 'Clear',
          icon: Icons.close,
          warning: true,
          onTap: () {
            widget.onChanged(_filter.clear());
            Navigator.pop(context);
          },
        ),
      ),
      builder: (context, scrollCtrl) =>
          widget.builder(context, scrollCtrl, _filter),
    );
  }
}

class CollectionFilterView extends StatelessWidget {
  const CollectionFilterView({required this.filter, required this.onChanged});

  final CollectionFilter filter;
  final void Function(CollectionFilter) onChanged;

  @override
  Widget build(BuildContext context) {
    return _FilterView<CollectionFilter>(
      filter: filter,
      onChanged: onChanged,
      builder: (context, scrollCtrl, filter) => ListView(
        controller: scrollCtrl,
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
          top: 20,
          bottom: 60,
        ),
        children: [
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
              minWidth: 140,
              height: 75,
            ),
            children: [
              SortDropDown(
                EntrySort.values,
                () => filter.sort.index,
                (EntrySort val) => filter.sort = val,
              ),
              OrderDropDown(
                EntrySort.values,
                () => filter.sort.index,
                (EntrySort val) => filter.sort = val,
              ),
              CountryDropDown(filter.country, (val) => filter.country = val),
            ],
          ),
          EnumChipGrid(
            title: 'Statuses',
            enumValues: MediaStatus.values,
            selected: filter.statuses,
          ),
          EnumChipGrid(
            title: 'Formats',
            enumValues:
                filter.ofAnime ? AnimeFormat.values : MangaFormat.values,
            selected: filter.formats,
          ),
          Consumer(
            builder: (context, ref, _) => ref.watch(tagsProvider).when(
                  loading: () => const Loader(),
                  error: (_, __) => const Text('Could not load tags'),
                  data: (tags) => ChipTagGrid(
                    inclusiveGenres: filter.genreIn,
                    exclusiveGenres: filter.genreNotIn,
                    inclusiveTags: filter.tagIn,
                    exclusiveTags: filter.tagNotIn,
                    tags: tags,
                    tagIdIn: filter.tagIdIn,
                    tagIdNotIn: filter.tagIdNotIn,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class DiscoverFilterView extends StatelessWidget {
  const DiscoverFilterView({required this.filter, required this.onChanged});

  final DiscoverFilter filter;
  final void Function(DiscoverFilter) onChanged;

  @override
  Widget build(BuildContext context) {
    return _FilterView<DiscoverFilter>(
      filter: filter,
      onChanged: onChanged,
      builder: (context, scrollCtrl, filter) => ListView(
        controller: scrollCtrl,
        padding:
            const EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 60),
        children: [
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
              minWidth: 140,
              height: 75,
            ),
            children: [
              SortDropDown(
                MediaSort.values,
                () => filter.sort.index,
                (MediaSort val) => filter.sort = val,
              ),
              OrderDropDown(
                MediaSort.values,
                () => filter.sort.index,
                (MediaSort val) => filter.sort = val,
              ),
              CountryDropDown(filter.country, (val) => filter.country = val),
              ListPresenceDropDown(
                value: filter.onList,
                onChanged: (val) => filter.onList = val,
              ),
            ],
          ),
          EnumChipGrid(
            title: 'Statuses',
            enumValues: MediaStatus.values,
            selected: filter.statuses,
          ),
          EnumChipGrid(
            title: 'Formats',
            enumValues:
                filter.ofAnime ? AnimeFormat.values : MangaFormat.values,
            selected: filter.formats,
          ),
          Consumer(
            builder: (context, ref, _) => ref.watch(tagsProvider).when(
                  loading: () => const Loader(),
                  error: (_, __) => const Text('Could not load tags'),
                  data: (tags) => ChipTagGrid(
                    inclusiveGenres: filter.genreIn,
                    exclusiveGenres: filter.genreNotIn,
                    inclusiveTags: filter.tagIn,
                    exclusiveTags: filter.tagNotIn,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class EnumChipGrid<T extends Enum> extends StatelessWidget {
  const EnumChipGrid({
    required this.title,
    required this.enumValues,
    required this.selected,
  });

  final String title;
  final List<T> enumValues;
  final List<String> selected;

  @override
  Widget build(BuildContext context) {
    final options = <String>[];
    final values = <String>[];
    for (final v in enumValues) {
      values.add(v.name);
      options.add(Convert.clarifyEnum(values.last)!);
    }

    return ChipGrid(
      title: title,
      placeholder: title.toLowerCase(),
      names: selected,
      onEdit: (selected) => showSheet(
        context,
        _SelectionSheet(options: options, values: values, selected: selected),
      ),
    );
  }
}

class _SelectionSheet<T> extends StatelessWidget {
  const _SelectionSheet({
    required this.options,
    required this.values,
    required this.selected,
  });

  final List<String> options;
  final List<T> values;
  final List<T> selected;

  @override
  Widget build(BuildContext context) {
    return OpaqueSheet(
      initialHeight: options.length * Consts.tapTargetSize + 20,
      builder: (context, scrollCtrl) => ListView.builder(
        controller: scrollCtrl,
        padding: Consts.padding,
        itemCount: options.length,
        itemExtent: Consts.tapTargetSize,
        itemBuilder: (_, index) => CheckBoxField(
          title: options[index],
          initial: selected.contains(values[index]),
          onChanged: (val) => val
              ? selected.add(values[index])
              : selected.remove(values[index]),
        ),
      ),
    );
  }
}

class TagSheetBody extends ConsumerStatefulWidget {
  const TagSheetBody({
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
  TagSheetBodyState createState() => TagSheetBodyState();
}

class TagSheetBodyState extends ConsumerState<TagSheetBody> {
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
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 10,
              top: 90,
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
            filter: Consts.filter,
            child: Container(
              height: 95,
              color: Theme.of(context).bottomAppBarColor,
              padding: const EdgeInsets.only(top: 10, bottom: 5),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 5,
                    ),
                    child: SearchField(
                      hint: 'Tag',
                      value: _filter,
                      onChange: (val) {
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
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      scrollDirection: Axis.horizontal,
                      itemCount: _categoryIndices.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: ChipOptionField(
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
