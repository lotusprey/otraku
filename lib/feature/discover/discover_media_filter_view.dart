import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/discover/discover_filter_model.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/localizations/gen.dart';
import 'package:otraku/widget/dialogs.dart';
import 'package:otraku/widget/input/chip_selector.dart';
import 'package:otraku/feature/tag/tag_picker.dart';
import 'package:otraku/widget/input/year_range_picker.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/layout/navigation_tool.dart';
import 'package:otraku/widget/sheets.dart';

class DiscoverMediaFilterView extends ConsumerStatefulWidget {
  const DiscoverMediaFilterView({
    required this.ofAnime,
    required this.filter,
    required this.onChanged,
  });

  final bool ofAnime;
  final DiscoverMediaFilter filter;
  final void Function(DiscoverMediaFilter) onChanged;

  @override
  ConsumerState<DiscoverMediaFilterView> createState() => _DiscoverFilterViewState();
}

class _DiscoverFilterViewState extends ConsumerState<DiscoverMediaFilterView> {
  late final _filter = widget.filter.copy();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final highContrast = ref.watch(persistenceProvider.select((s) => s.options.highContrast));

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
        widget.onChanged(ref.read(persistenceProvider).discoverMediaFilter);
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
          ref.read(persistenceProvider.notifier).setDiscoverMediaFilter(_filter);

          widget.onChanged(_filter);
          Navigator.pop(context);
        },
      ),
    );

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
            ChipSelector.ensureSelected(
              title: l10n.filterSort,
              items: MediaSort.values.map((v) => (v.localize(l10n), v)).toList(),
              value: _filter.sort,
              onChanged: (v) => _filter.sort = v,
              highContrast: highContrast,
            ),
            ChipMultiSelector(
              title: l10n.mediaStatus(ReleaseStatus.values.length),
              items: ReleaseStatus.values.map((v) => (v.localize(l10n), v)).toList(),
              values: _filter.statuses,
              highContrast: highContrast,
            ),
            if (widget.ofAnime)
              ChipMultiSelector(
                title: l10n.mediaFormat,
                items: MediaFormat.animeFormats.map((v) => (v.localize(l10n), v)).toList(),
                values: _filter.animeFormats,
                highContrast: highContrast,
              )
            else
              ChipMultiSelector(
                title: l10n.mediaFormat,
                items: MediaFormat.mangaFormats.map((v) => (v.localize(l10n), v)).toList(),
                values: _filter.mangaFormats,
                highContrast: highContrast,
              ),
            if (widget.ofAnime)
              ChipSelector(
                title: l10n.mediaSeason,
                items: MediaSeason.values.map((v) => (v.localize(l10n), v)).toList(),
                value: _filter.season,
                onChanged: (v) => _filter.season = v,
                highContrast: highContrast,
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
              highContrast: highContrast,
            ),
            ChipMultiSelector(
              title: l10n.mediaSource(MediaSource.values.length),
              items: MediaSource.values.map((v) => (v.localize(l10n), v)).toList(),
              values: _filter.sources,
              highContrast: highContrast,
            ),
            ChipSelector(
              title: l10n.filterListPresence,
              items: [(l10n.filterListPresenceIn, true), (l10n.filterListPresenceNotIn, false)],
              value: _filter.inLists,
              onChanged: (v) => _filter.inLists = v,
              highContrast: highContrast,
            ),
            ChipSelector(
              title: l10n.filterAge,
              items: [(l10n.filterAgeAdult, true), (l10n.filterAgeNonAdult, false)],
              value: _filter.isAdult,
              onChanged: (v) => _filter.isAdult = v,
              highContrast: highContrast,
            ),
            ChipSelector(
              title: l10n.filterLicensing,
              items: [(l10n.filterLicensingLicensed, true), (l10n.filterLicensingDoujin, false)],
              value: _filter.isLicensed,
              onChanged: (v) => _filter.isLicensed = v,
              highContrast: highContrast,
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
