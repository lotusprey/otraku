import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/modules/filter/chip_selector.dart';
import 'package:otraku/modules/filter/filter_models.dart';
import 'package:otraku/modules/filter/year_range_picker.dart';
import 'package:otraku/modules/media/media_constants.dart';
import 'package:otraku/modules/tag/tag_models.dart';
import 'package:otraku/modules/tag/tag_provider.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/common/utils/convert.dart';
import 'package:otraku/common/widgets/fields/checkbox_field.dart';
import 'package:otraku/common/widgets/fields/search_field.dart';
import 'package:otraku/common/widgets/layouts/bottom_bar.dart';
import 'package:otraku/common/widgets/loaders.dart/loaders.dart';
import 'package:otraku/common/widgets/grids/chip_grids.dart';
import 'package:otraku/common/widgets/overlays/sheets.dart';

class _FilterView<T extends MediaFilter<T>> extends StatefulWidget {
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

class __FilterViewState<T extends MediaFilter<T>>
    extends State<_FilterView<T>> {
  late final T _filter = widget.filter.copy();

  @override
  Widget build(BuildContext context) {
    final applyButton = BottomBarButton(
      text: 'Apply',
      icon: Icons.done_rounded,
      onTap: () {
        widget.onChanged(_filter);
        Navigator.pop(context);
      },
    );

    final clearButton = BottomBarButton(
      text: 'Clear',
      icon: Icons.close,
      warning: true,
      onTap: () {
        widget.onChanged(_filter.clear());
        Navigator.pop(context);
      },
    );

    return OpaqueSheetView(
      buttons: BottomBar(
        Options().leftHanded
            ? [applyButton, clearButton]
            : [clearButton, applyButton],
      ),
      builder: (context, scrollCtrl) =>
          widget.builder(context, scrollCtrl, _filter),
    );
  }
}

class CollectionFilterView extends StatelessWidget {
  const CollectionFilterView({required this.filter, required this.onChanged});

  final CollectionMediaFilter filter;
  final void Function(CollectionMediaFilter) onChanged;

  @override
  Widget build(BuildContext context) {
    return _FilterView<CollectionMediaFilter>(
      filter: filter,
      onChanged: onChanged,
      builder: (context, scrollCtrl, filter) => ListView(
        controller: scrollCtrl,
        padding: const EdgeInsets.only(top: 20),
        children: [
          EntrySortChipSelector(
            title: 'Sorting',
            current: filter.sort,
            onChanged: (v) => filter.sort = v,
          ),
          ChipEnumMultiSelector(
            title: 'Statuses',
            options: MediaStatus.values,
            current: filter.statuses,
          ),
          ChipEnumMultiSelector(
            title: 'Formats',
            options: filter.ofAnime ? AnimeFormat.values : MangaFormat.values,
            current: filter.formats,
          ),
          const Divider(indent: 15, endIndent: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Consumer(
              builder: (context, ref, _) => ref.watch(tagsProvider).when(
                    loading: () => const Loader(),
                    error: (_, __) => const Text('Failed to load tags'),
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
          ),
          YearRangePicker(
            title: 'Start Year',
            from: filter.startYearFrom,
            to: filter.startYearTo,
            onChanged: (from, to) {
              filter.startYearFrom = from;
              filter.startYearTo = to;
            },
          ),
          const Divider(indent: 15, endIndent: 15),
          ChipSelector(
            title: 'Country',
            options: OriginCountry.values
                .map((v) => Convert.clarifyEnum(v.name)!)
                .toList(),
            current: filter.country?.index,
            onChanged: (val) => filter.country =
                val == null ? null : OriginCountry.values.elementAt(val),
          ),
          SizedBox(height: BottomBar.offset(context)),
        ],
      ),
    );
  }
}

class DiscoverFilterView extends StatelessWidget {
  const DiscoverFilterView({required this.filter, required this.onChanged});

  final DiscoverMediaFilter filter;
  final void Function(DiscoverMediaFilter) onChanged;

  @override
  Widget build(BuildContext context) {
    return _FilterView<DiscoverMediaFilter>(
      filter: filter,
      onChanged: onChanged,
      builder: (context, scrollCtrl, filter) => ListView(
        controller: scrollCtrl,
        padding: const EdgeInsets.only(top: 20),
        children: [
          ChipSelector(
            title: 'Sorting',
            options: MediaSort.values.map((s) => s.label).toList(),
            current: filter.sort.index,
            mustHaveSelected: true,
            onChanged: (i) => filter.sort = MediaSort.values.elementAt(i!),
          ),
          ChipEnumMultiSelector(
            title: 'Statuses',
            options: MediaStatus.values,
            current: filter.statuses,
          ),
          ChipEnumMultiSelector(
            title: 'Formats',
            options: filter.ofAnime ? AnimeFormat.values : MangaFormat.values,
            current: filter.formats,
          ),
          if (filter.ofAnime)
            ChipSelector(
              title: 'Season',
              options: MediaSeason.values
                  .map((v) => Convert.clarifyEnum(v.name)!)
                  .toList(),
              current: filter.season?.index,
              onChanged: (selected) => filter.season = selected != null
                  ? MediaSeason.values.elementAt(selected)
                  : null,
            ),
          const Divider(indent: 15, endIndent: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Consumer(
              builder: (context, ref, _) => ref.watch(tagsProvider).when(
                    loading: () => const Loader(),
                    error: (_, __) => const Text('Failed to load tags'),
                    data: (tags) => ChipTagGrid(
                      inclusiveGenres: filter.genreIn,
                      exclusiveGenres: filter.genreNotIn,
                      inclusiveTags: filter.tagIn,
                      exclusiveTags: filter.tagNotIn,
                    ),
                  ),
            ),
          ),
          YearRangePicker(
            title: 'Start Year',
            from: filter.startYearFrom,
            to: filter.startYearTo,
            onChanged: (from, to) {
              filter.startYearFrom = from;
              filter.startYearTo = to;
            },
          ),
          const Divider(indent: 15, endIndent: 15),
          ChipSelector(
            title: 'Country',
            options: OriginCountry.values
                .map((v) => Convert.clarifyEnum(v.name)!)
                .toList(),
            current: filter.country?.index,
            onChanged: (val) => filter.country =
                val == null ? null : OriginCountry.values.elementAt(val),
          ),
          ChipEnumMultiSelector(
            title: 'Sources',
            options: MediaSource.values,
            current: filter.sources,
          ),
          ChipSelector(
            title: 'List Presence',
            options: const ['On List', 'Not on List'],
            current: filter.onList == null
                ? null
                : filter.onList!
                    ? 0
                    : 1,
            onChanged: (val) => filter.onList = val == null
                ? null
                : val == 0
                    ? true
                    : false,
          ),
          ChipSelector(
            title: 'Age Restriction',
            options: const ['Adult', 'Non-Adult'],
            current: filter.isAdult == null
                ? null
                : filter.isAdult!
                    ? 0
                    : 1,
            onChanged: (val) => filter.isAdult = val == null
                ? null
                : val == 0
                    ? true
                    : false,
          ),
          SizedBox(height: BottomBar.offset(context)),
        ],
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
            padding: EdgeInsets.only(
              top: 90,
              left: 20,
              right: 20,
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
              height: 95,
              color: Theme.of(context).navigationBarTheme.backgroundColor,
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
