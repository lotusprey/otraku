import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/modules/filter/chip_selector.dart';
import 'package:otraku/modules/filter/filter_models.dart';
import 'package:otraku/modules/filter/tag_selector.dart';
import 'package:otraku/modules/filter/year_range_picker.dart';
import 'package:otraku/modules/media/media_constants.dart';
import 'package:otraku/modules/tag/tag_provider.dart';
import 'package:otraku/common/utils/convert.dart';
import 'package:otraku/common/widgets/layouts/bottom_bar.dart';
import 'package:otraku/common/widgets/loaders.dart/loaders.dart';
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
      builder: (context, scrollCtrl) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: widget.builder(context, scrollCtrl, _filter),
      ),
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
          const Divider(indent: 10, endIndent: 10),
          Consumer(
            builder: (context, ref, _) => ref.watch(tagsProvider).when(
                  loading: () => const Loader(),
                  error: (_, __) => const Text('Failed to load tags'),
                  data: (tags) => TagSelector(
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
          const Divider(indent: 10, endIndent: 10, height: 30),
          YearRangePicker(
            title: 'Start Year',
            from: filter.startYearFrom,
            to: filter.startYearTo,
            onChanged: (from, to) {
              filter.startYearFrom = from;
              filter.startYearTo = to;
            },
          ),
          const Divider(indent: 10, endIndent: 10),
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
          const Divider(indent: 10, endIndent: 10),
          Consumer(
            builder: (context, ref, _) => ref.watch(tagsProvider).when(
                  loading: () => const Loader(),
                  error: (_, __) => const Text('Failed to load tags'),
                  data: (tags) => TagSelector(
                    inclusiveGenres: filter.genreIn,
                    exclusiveGenres: filter.genreNotIn,
                    inclusiveTags: filter.tagIn,
                    exclusiveTags: filter.tagNotIn,
                  ),
                ),
          ),
          const Divider(indent: 10, endIndent: 10, height: 30),
          YearRangePicker(
            title: 'Start Year',
            from: filter.startYearFrom,
            to: filter.startYearTo,
            onChanged: (from, to) {
              filter.startYearFrom = from;
              filter.startYearTo = to;
            },
          ),
          const Divider(indent: 10, endIndent: 10),
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
