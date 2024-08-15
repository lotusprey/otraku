import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/filter/chip_selector.dart';
import 'package:otraku/feature/filter/filter_discover_model.dart';
import 'package:otraku/feature/filter/filter_edit_sheet.dart';
import 'package:otraku/feature/filter/tag_selector.dart';
import 'package:otraku/feature/filter/year_range_picker.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/feature/tag/tag_provider.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/layout/navigation_tool.dart';
import 'package:otraku/widget/loaders.dart';

class FilterDiscoverView extends StatefulWidget {
  const FilterDiscoverView({
    required this.ofAnime,
    required this.filter,
    required this.onChanged,
  });

  final bool ofAnime;
  final DiscoverMediaFilter filter;
  final void Function(DiscoverMediaFilter) onChanged;

  @override
  State<FilterDiscoverView> createState() => _FilterDiscoverViewState();
}

class _FilterDiscoverViewState extends State<FilterDiscoverView> {
  late final _filter = widget.filter.copy();

  @override
  Widget build(BuildContext context) {
    return FilterEditSheet(
      filter: _filter,
      onChanged: widget.onChanged,
      onCleared: () => widget.onChanged(DiscoverMediaFilter()),
      builder: (context, scrollCtrl, filter) => ListView(
        controller: scrollCtrl,
        padding: const EdgeInsets.only(top: 20),
        children: [
          ChipSelector.ensureSelected(
            title: 'Sorting',
            items: MediaSort.values.map((v) => (v.label, v)).toList(),
            value: filter.sort,
            onChanged: (v) => filter.sort = v,
          ),
          ChipMultiSelector(
            title: 'Statuses',
            items: ReleaseStatus.values.map((v) => (v.label, v)).toList(),
            values: filter.statuses,
          ),
          if (widget.ofAnime)
            ChipMultiSelector(
              title: 'Formats',
              items: MediaFormat.animeFormats.map((v) => (v.label, v)).toList(),
              values: filter.animeFormats,
            )
          else
            ChipMultiSelector(
              title: 'Formats',
              items: MediaFormat.mangaFormats.map((v) => (v.label, v)).toList(),
              values: filter.mangaFormats,
            ),
          if (widget.ofAnime)
            ChipSelector(
              title: 'Season',
              items: MediaSeason.values.map((v) => (v.label, v)).toList(),
              value: filter.season,
              onChanged: (v) => filter.season = v,
            ),
          const SizedBox(height: 5),
          const Divider(),
          Consumer(
            builder: (context, ref, _) => ref.watch(tagsProvider).when(
                  loading: () => const Center(child: Loader()),
                  error: (_, __) => const Center(
                    child: Text('Failed to load tags'),
                  ),
                  data: (tags) => TagSelector(
                    inclusiveGenres: filter.genreIn,
                    exclusiveGenres: filter.genreNotIn,
                    inclusiveTags: filter.tagIn,
                    exclusiveTags: filter.tagNotIn,
                  ),
                ),
          ),
          const Divider(),
          const SizedBox(height: Theming.offset),
          YearRangePicker(
            title: 'Release Year Range',
            from: filter.startYearFrom,
            to: filter.startYearTo,
            onChanged: (from, to) {
              filter.startYearFrom = from;
              filter.startYearTo = to;
            },
          ),
          const SizedBox(height: Theming.offset),
          const Divider(),
          ChipSelector(
            title: 'Country',
            items: OriginCountry.values.map((v) => (v.label, v)).toList(),
            value: filter.country,
            onChanged: (v) => filter.country = v,
          ),
          ChipMultiSelector(
            title: 'Sources',
            items: MediaSource.values.map((v) => (v.label, v)).toList(),
            values: filter.sources,
          ),
          ChipSelector(
            title: 'List Presence',
            items: const [
              ('In Lists', true),
              ('Not in Lists', false),
            ],
            value: filter.inLists,
            onChanged: (v) => filter.inLists = v,
          ),
          ChipSelector(
            title: 'Age Restriction',
            items: const [('Adult', true), ('Non-Adult', false)],
            value: filter.isAdult,
            onChanged: (v) => filter.isAdult = v,
          ),
          SizedBox(
            height: MediaQuery.paddingOf(context).bottom +
                BottomBar.height +
                Theming.offset,
          ),
        ],
      ),
    );
  }
}
