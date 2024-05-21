import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/modules/filter/chip_selector.dart';
import 'package:otraku/modules/filter/filter_models.dart';
import 'package:otraku/modules/filter/tag_selector.dart';
import 'package:otraku/modules/filter/year_range_picker.dart';
import 'package:otraku/modules/media/media_models.dart';
import 'package:otraku/modules/tag/tag_provider.dart';
import 'package:otraku/common/widgets/layouts/bottom_bar.dart';
import 'package:otraku/common/widgets/loaders/loaders.dart';
import 'package:otraku/common/widgets/overlays/sheets.dart';

class _FilterView<T> extends StatelessWidget {
  const _FilterView({
    required this.filter,
    required this.onCleared,
    required this.onChanged,
    required this.builder,
  });

  final T filter;
  final void Function() onCleared;
  final void Function(T) onChanged;
  final Widget Function(BuildContext, ScrollController, T) builder;

  @override
  Widget build(BuildContext context) {
    final applyButton = BottomBarButton(
      text: 'Apply',
      icon: Icons.done_rounded,
      onTap: () {
        onChanged(filter);
        Navigator.pop(context);
      },
    );

    final clearButton = BottomBarButton(
      text: 'Clear',
      icon: Icons.close,
      warning: true,
      onTap: () {
        onCleared();
        Navigator.pop(context);
      },
    );

    return OpaqueSheetView(
      buttons: BottomBar(
        Persistence().leftHanded
            ? [applyButton, clearButton]
            : [clearButton, applyButton],
      ),
      builder: (context, scrollCtrl) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: builder(context, scrollCtrl, filter),
      ),
    );
  }
}

class CollectionFilterView extends StatefulWidget {
  const CollectionFilterView({
    required this.ofAnime,
    required this.filter,
    required this.onChanged,
    required this.ofViewer,
  });

  final bool ofAnime;
  final CollectionMediaFilter filter;
  final void Function(CollectionMediaFilter) onChanged;
  final bool ofViewer;

  @override
  State<CollectionFilterView> createState() => _CollectionFilterViewState();
}

class _CollectionFilterViewState extends State<CollectionFilterView> {
  late final _filter = widget.filter.copy();

  @override
  Widget build(BuildContext context) {
    return _FilterView(
      filter: _filter,
      onChanged: widget.onChanged,
      onCleared: () => widget.onChanged(CollectionMediaFilter(widget.ofAnime)),
      builder: (context, scrollCtrl, filter) => ListView(
        controller: scrollCtrl,
        padding: const EdgeInsets.only(top: 20),
        children: [
          EntrySortChipSelector(
            title: 'Sorting',
            current: filter.sort,
            onChanged: (v) => filter.sort = v,
          ),
          ChipMultiSelector(
            title: 'Statuses',
            items: MediaStatus.values.map((v) => (v.label, v)).toList(),
            values: filter.statuses,
          ),
          ChipMultiSelector(
            title: 'Formats',
            items: (widget.ofAnime
                    ? MediaFormat.animeFormats
                    : MediaFormat.mangaFormats)
                .map((v) => (v.label, v))
                .toList(),
            values: filter.formats,
          ),
          const SizedBox(height: 5),
          const Divider(),
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
          const Divider(),
          const SizedBox(height: 10),
          YearRangePicker(
            title: 'Release Year Range',
            from: filter.startYearFrom,
            to: filter.startYearTo,
            onChanged: (from, to) {
              filter.startYearFrom = from;
              filter.startYearTo = to;
            },
          ),
          const SizedBox(height: 10),
          const Divider(),
          ChipSelector(
            title: 'Country',
            items: OriginCountry.values.map((v) => (v.label, v)).toList(),
            value: filter.country,
            onChanged: (v) => filter.country = v,
          ),
          if (widget.ofViewer)
            ChipSelector(
              title: 'Visibility',
              items: const [('Private', true), ('Public', false)],
              value: filter.isPrivate,
              onChanged: (v) => filter.isPrivate = v,
            ),
          ChipSelector(
            title: 'Notes',
            items: const [('With Notes', true), ('Without Notes', false)],
            value: filter.hasNotes,
            onChanged: (v) => filter.hasNotes = v,
          ),
          SizedBox(
            height:
                MediaQuery.paddingOf(context).bottom + BottomBar.height + 10,
          ),
        ],
      ),
    );
  }
}

class DiscoverFilterView extends StatefulWidget {
  const DiscoverFilterView({
    required this.ofAnime,
    required this.filter,
    required this.onChanged,
  });

  final bool ofAnime;
  final DiscoverMediaFilter filter;
  final void Function(DiscoverMediaFilter) onChanged;

  @override
  State<DiscoverFilterView> createState() => _DiscoverFilterViewState();
}

class _DiscoverFilterViewState extends State<DiscoverFilterView> {
  late final _filter = widget.filter.copy();

  @override
  Widget build(BuildContext context) {
    return _FilterView(
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
            items: MediaStatus.values.map((v) => (v.label, v)).toList(),
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
          const SizedBox(height: 10),
          YearRangePicker(
            title: 'Release Year Range',
            from: filter.startYearFrom,
            to: filter.startYearTo,
            onChanged: (from, to) {
              filter.startYearFrom = from;
              filter.startYearTo = to;
            },
          ),
          const SizedBox(height: 10),
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
            height:
                MediaQuery.paddingOf(context).bottom + BottomBar.height + 10,
          ),
        ],
      ),
    );
  }
}
