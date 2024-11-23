import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/collection/collection_models.dart';
import 'package:otraku/feature/filter/chip_selector.dart';
import 'package:otraku/feature/filter/filter_collection_model.dart';
import 'package:otraku/feature/filter/filter_edit_sheet.dart';
import 'package:otraku/feature/filter/tag_selector.dart';
import 'package:otraku/feature/filter/year_range_picker.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/feature/tag/tag_provider.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/layout/navigation_tool.dart';
import 'package:otraku/widget/loaders.dart';

class FilterCollectionView extends ConsumerStatefulWidget {
  const FilterCollectionView({
    required this.tag,
    required this.filter,
    required this.onChanged,
  });

  final CollectionTag tag;
  final CollectionMediaFilter filter;
  final void Function(CollectionMediaFilter) onChanged;

  @override
  ConsumerState<FilterCollectionView> createState() =>
      _FilterCollectionViewState();
}

class _FilterCollectionViewState extends ConsumerState<FilterCollectionView> {
  late final _filter = widget.filter.copy();

  @override
  Widget build(BuildContext context) {
    final options = ref.watch(persistenceProvider.select((s) => s.options));
    final ofViewer = ref.watch(viewerIdProvider) == widget.tag.userId;

    return FilterEditSheet(
      filter: _filter,
      onChanged: widget.onChanged,
      onCleared: () => widget.onChanged(
        CollectionMediaFilter(widget.filter.sort),
      ),
      leftHanded: options.leftHanded,
      builder: (context, scrollCtrl, filter) => ListView(
        controller: scrollCtrl,
        padding: const EdgeInsets.only(top: 20),
        children: [
          EntrySortChipSelector(
            title: 'Sorting',
            value: filter.sort,
            onChanged: (v) => filter.sort = v,
          ),
          ChipMultiSelector(
            title: 'Statuses',
            items: ReleaseStatus.values.map((v) => (v.label, v)).toList(),
            values: filter.statuses,
          ),
          ChipMultiSelector(
            title: 'Formats',
            items: (widget.tag.ofAnime
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
          if (ofViewer)
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
            height: MediaQuery.paddingOf(context).bottom +
                BottomBar.height +
                Theming.offset,
          ),
        ],
      ),
    );
  }
}
