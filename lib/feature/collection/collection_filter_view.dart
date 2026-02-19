import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/collection/collection_filter_model.dart';
import 'package:otraku/feature/collection/collection_models.dart';
import 'package:otraku/localizations/gen.dart';
import 'package:otraku/widget/dialogs.dart';
import 'package:otraku/widget/input/chip_selector.dart';
import 'package:otraku/feature/tag/tag_picker.dart';
import 'package:otraku/widget/input/year_range_picker.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/layout/navigation_tool.dart';
import 'package:otraku/widget/sheets.dart';

class CollectionFilterView extends ConsumerStatefulWidget {
  const CollectionFilterView({required this.tag, required this.filter, required this.onChanged});

  final CollectionTag tag;
  final CollectionMediaFilter filter;
  final void Function(CollectionMediaFilter) onChanged;

  @override
  ConsumerState<CollectionFilterView> createState() => _FilterCollectionViewState();
}

class _FilterCollectionViewState extends ConsumerState<CollectionFilterView> {
  late final _filter = widget.filter.copy();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final options = ref.watch(persistenceProvider.select((s) => s.options));
    final ofViewer = ref.watch(viewerIdProvider) == widget.tag.userId;

    final applyButton = BottomBarButton(
      text: l10n.actionApply,
      icon: Icons.done_rounded,
      onTap: () {
        widget.onChanged(_filter);
        Navigator.pop(context);
      },
    );

    final revertToDefaultButton = BottomBarButton(
      text: l10n.actionReset,
      icon: Icons.restore_rounded,
      foregroundColor: ColorScheme.of(context).secondary,
      onTap: () {
        final persistence = ref.read(persistenceProvider);
        if (widget.tag.ofAnime) {
          widget.onChanged(persistence.animeCollectionMediaFilter);
        } else {
          widget.onChanged(persistence.mangaCollectionMediaFilter);
        }

        Navigator.pop(context);
      },
    );

    final saveButton = BottomBarButton(
      text: l10n.actionSave,
      icon: Icons.save_outlined,
      foregroundColor: ColorScheme.of(context).secondary,
      onTap: () => ConfirmationDialog.show(
        context,
        title: l10n.filterDefaultQuestion,
        content: l10n.filterDefaultWarning,
        primaryAction: l10n.actionConfirm,
        secondaryAction: l10n.actionGoBack,
        onConfirm: () {
          final notifier = ref.read(persistenceProvider.notifier);
          if (widget.tag.ofAnime) {
            notifier.setAnimeCollectionMediaFilter(_filter);
          } else {
            notifier.setMangaCollectionMediaFilter(_filter);
          }

          widget.onChanged(_filter);
          Navigator.pop(context);
        },
      ),
    );

    Widget? previewSortPicker;
    if (ofViewer &&
        (widget.tag.ofAnime && options.animeCollectionPreview ||
            !widget.tag.ofAnime && options.mangaCollectionPreview)) {
      previewSortPicker = EntrySortChipSelector(
        title: l10n.filterSortPreview,
        value: _filter.previewSort,
        onChanged: (v) => _filter.previewSort = v,
        highContrast: options.highContrast,
        l10n: l10n,
      );
    }

    return SheetWithButtonRow(
      buttons: BottomBar(
        Theming.of(context).rightButtonOrientation
            ? [saveButton, revertToDefaultButton, applyButton]
            : [applyButton, revertToDefaultButton, saveButton],
      ),
      builder: (context, scrollCtrl) => Padding(
        padding: const .symmetric(horizontal: Theming.offset),
        child: ListView(
          controller: scrollCtrl,
          padding: const .only(top: 20),
          children: [
            EntrySortChipSelector(
              title: l10n.filterSort,
              value: _filter.sort,
              onChanged: (v) => _filter.sort = v,
              highContrast: options.highContrast,
              l10n: l10n,
            ),
            ?previewSortPicker,
            ChipMultiSelector(
              title: l10n.mediaStatus(ReleaseStatus.values.length),
              items: ReleaseStatus.values.map((v) => (v.localize(l10n), v)).toList(),
              values: _filter.statuses,
              highContrast: options.highContrast,
            ),
            ChipMultiSelector(
              title: l10n.mediaFormat,
              items: (widget.tag.ofAnime ? MediaFormat.animeFormats : MediaFormat.mangaFormats)
                  .map((v) => (v.localize(l10n), v))
                  .toList(),
              values: _filter.formats,
              highContrast: options.highContrast,
            ),
            const SizedBox(height: 5),
            const Divider(),
            TagPicker(
              includedGenres: _filter.genreIn,
              excludedGenres: _filter.genreNotIn,
              includedTags: _filter.tagIn,
              excludedTags: _filter.tagNotIn,
            ),
            const Divider(),
            const SizedBox(height: Theming.offset),
            YearRangePicker(
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
              title: l10n.country,
              items: OriginCountry.values.map((v) => (v.localize(l10n), v)).toList(),
              value: _filter.country,
              onChanged: (v) => _filter.country = v,
              highContrast: options.highContrast,
            ),
            if (ofViewer)
              ChipSelector(
                title: l10n.filterVisibility,
                items: [(l10n.filterVisibilityPrivate, true), (l10n.filterVisibilityPublic, false)],
                value: _filter.isPrivate,
                onChanged: (v) => _filter.isPrivate = v,
                highContrast: options.highContrast,
              ),
            ChipSelector(
              title: l10n.filterNotes,
              items: [(l10n.filterNotesWith, true), (l10n.filterNotesWithout, false)],
              value: _filter.hasNotes,
              onChanged: (v) => _filter.hasNotes = v,
              highContrast: options.highContrast,
            ),
            SizedBox(
              height: MediaQuery.paddingOf(context).bottom + BottomBar.height + Theming.offset,
            ),
          ],
        ),
      ),
    );
  }
}
