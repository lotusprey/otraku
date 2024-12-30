import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/discover/discover_filter_model.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/widget/dialogs.dart';
import 'package:otraku/widget/input/chip_selector.dart';
import 'package:otraku/feature/tag/tag_picker.dart';
import 'package:otraku/widget/input/year_range_picker.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/feature/tag/tag_provider.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/layout/navigation_tool.dart';
import 'package:otraku/widget/loaders.dart';
import 'package:otraku/widget/sheets.dart';

class DiscoverFilterView extends ConsumerStatefulWidget {
  const DiscoverFilterView({
    required this.ofAnime,
    required this.filter,
    required this.onChanged,
    required this.leftHanded,
  });

  final bool ofAnime;
  final DiscoverMediaFilter filter;
  final void Function(DiscoverMediaFilter) onChanged;
  final bool leftHanded;

  @override
  ConsumerState<DiscoverFilterView> createState() => _DiscoverFilterViewState();
}

class _DiscoverFilterViewState extends ConsumerState<DiscoverFilterView> {
  late final _filter = widget.filter.copy();

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

    final revertToDefaultButton = BottomBarButton(
      text: 'Reset',
      icon: Icons.restore_rounded,
      foregroundColor: ColorScheme.of(context).secondary,
      onTap: () {
        widget.onChanged(ref.read(persistenceProvider).discoverMediaFilter);
        Navigator.pop(context);
      },
    );

    final saveButton = BottomBarButton(
      text: 'Save',
      icon: Icons.save_outlined,
      foregroundColor: ColorScheme.of(context).secondary,
      onTap: () => ConfirmationDialog.show(
        context,
        title: 'Make default?',
        content: 'The current filters and sorting will become the default.',
        primaryAction: 'Yes',
        secondaryAction: 'No',
        onConfirm: () {
          ref
              .read(persistenceProvider.notifier)
              .setDiscoverMediaFilter(_filter);

          widget.onChanged(_filter);
          Navigator.pop(context);
        },
      ),
    );

    return SheetWithButtonRow(
      buttons: BottomBar(
        widget.leftHanded
            ? [applyButton, revertToDefaultButton, saveButton]
            : [saveButton, revertToDefaultButton, applyButton],
      ),
      builder: (context, scrollCtrl) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: Theming.offset),
        child: ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.only(top: 20),
          children: [
            ChipSelector.ensureSelected(
              title: 'Sorting',
              items: MediaSort.values.map((v) => (v.label, v)).toList(),
              value: _filter.sort,
              onChanged: (v) => _filter.sort = v,
            ),
            ChipMultiSelector(
              title: 'Statuses',
              items: ReleaseStatus.values.map((v) => (v.label, v)).toList(),
              values: _filter.statuses,
            ),
            if (widget.ofAnime)
              ChipMultiSelector(
                title: 'Formats',
                items:
                    MediaFormat.animeFormats.map((v) => (v.label, v)).toList(),
                values: _filter.animeFormats,
              )
            else
              ChipMultiSelector(
                title: 'Formats',
                items:
                    MediaFormat.mangaFormats.map((v) => (v.label, v)).toList(),
                values: _filter.mangaFormats,
              ),
            if (widget.ofAnime)
              ChipSelector(
                title: 'Season',
                items: MediaSeason.values.map((v) => (v.label, v)).toList(),
                value: _filter.season,
                onChanged: (v) => _filter.season = v,
              ),
            const SizedBox(height: 5),
            const Divider(),
            Consumer(
              builder: (context, ref, _) => ref.watch(tagsProvider).when(
                    loading: () => const Center(child: Loader()),
                    error: (_, __) => const Center(
                      child: Text('Failed to load tags'),
                    ),
                    data: (tags) => TagPicker(
                      includedGenres: _filter.genreIn,
                      excludedGenres: _filter.genreNotIn,
                      includedTags: _filter.tagIn,
                      excludedTags: _filter.tagNotIn,
                    ),
                  ),
            ),
            const Divider(),
            const SizedBox(height: Theming.offset),
            YearRangePicker(
              title: 'Release Year Range',
              from: _filter.startYearFrom,
              to: _filter.startYearTo,
              onChanged: (from, to) {
                _filter.startYearFrom = from;
                _filter.startYearTo = to;
              },
            ),
            const SizedBox(height: Theming.offset),
            const Divider(),
            ChipSelector(
              title: 'Country',
              items: OriginCountry.values.map((v) => (v.label, v)).toList(),
              value: _filter.country,
              onChanged: (v) => _filter.country = v,
            ),
            ChipMultiSelector(
              title: 'Sources',
              items: MediaSource.values.map((v) => (v.label, v)).toList(),
              values: _filter.sources,
            ),
            ChipSelector(
              title: 'List Presence',
              items: const [
                ('In Lists', true),
                ('Not in Lists', false),
              ],
              value: _filter.inLists,
              onChanged: (v) => _filter.inLists = v,
            ),
            ChipSelector(
              title: 'Age Restriction',
              items: const [('Adult', true), ('Non-Adult', false)],
              value: _filter.isAdult,
              onChanged: (v) => _filter.isAdult = v,
            ),
            SizedBox(
              height: MediaQuery.paddingOf(context).bottom +
                  BottomBar.height +
                  Theming.offset,
            ),
          ],
        ),
      ),
    );
  }
}
