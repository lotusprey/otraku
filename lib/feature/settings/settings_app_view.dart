import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/collection/collection_models.dart';
import 'package:otraku/feature/viewer/persistence_model.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/localizations/gen.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/input/stateful_tiles.dart';
import 'package:otraku/feature/discover/discover_model.dart';
import 'package:otraku/widget/input/chip_selector.dart';
import 'package:otraku/feature/home/home_model.dart';
import 'package:otraku/feature/settings/theme_preview.dart';

class SettingsAppSubview extends ConsumerWidget {
  const SettingsAppSubview(this.scrollCtrl);

  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final listPadding = MediaQuery.paddingOf(context);
    const tilePadding = EdgeInsets.only(
      bottom: Theming.offset,
      left: Theming.offset,
      right: Theming.offset,
    );

    final options = ref.watch(persistenceProvider.select((s) => s.options));

    final update = (Options options) => ref.read(persistenceProvider.notifier).setOptions(options);

    return ListView(
      controller: scrollCtrl,
      padding: .only(
        top: listPadding.top + Theming.offset,
        bottom: listPadding.bottom + Theming.offset + 60,
      ),
      children: [
        ExpansionTile(
          title: Text(l10n.settingsAppearance),
          initiallyExpanded: true,
          expandedCrossAxisAlignment: .stretch,
          children: [
            Padding(
              padding: const .only(
                bottom: Theming.offset,
                left: Theming.offset,
                right: Theming.offset,
              ),
              child: StatefulSegmentedButton(
                segments: [
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text(l10n.settingsAppearanceModeSystem),
                    icon: const Icon(Icons.sync_outlined),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text(l10n.settingsAppearanceModeLight),
                    icon: const Icon(Icons.wb_sunny_outlined),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text(l10n.settingsAppearanceModeDark),
                    icon: const Icon(Icons.mode_night_outlined),
                  ),
                ],
                value: options.themeMode,
                onChanged: (themeMode) => update(options.copyWith(themeMode: themeMode)),
              ),
            ),
            ThemePreview(ref: ref, options: options),
            const SizedBox(height: Theming.offset / 2),
            StatefulSwitchListTile(
              title: Text(l10n.settingsHighContrast),
              subtitle: Text(l10n.settingsHighContrastDescription),
              value: options.highContrast,
              onChanged: (v) => update(options.copyWith(highContrast: v)),
            ),
            const SizedBox(height: Theming.offset / 2),
            Padding(
              padding: const .only(
                left: Theming.offset,
                right: Theming.offset,
                bottom: Theming.offset,
              ),
              child: Text(l10n.settingsButtonOrientation),
            ),
            Padding(
              padding: const .only(
                left: Theming.offset,
                right: Theming.offset,
                bottom: Theming.offset,
              ),
              child: StatefulSegmentedButton(
                segments: [
                  ButtonSegment(
                    value: ButtonOrientation.auto,
                    label: Text(l10n.settingsButtonOrientationAuto),
                    icon: const Icon(Icons.align_horizontal_center_rounded),
                  ),
                  ButtonSegment(
                    value: ButtonOrientation.left,
                    label: Text(l10n.settingsButtonOrientationLeft),
                    icon: const Icon(Icons.align_horizontal_left_rounded),
                  ),
                  ButtonSegment(
                    value: ButtonOrientation.right,
                    label: Text(l10n.settingsButtonOrientationRight),
                    icon: const Icon(Icons.align_horizontal_right_rounded),
                  ),
                ],
                value: options.buttonOrientation,
                onChanged: (buttonOrientation) =>
                    update(options.copyWith(buttonOrientation: buttonOrientation)),
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: Text(l10n.settingsCollectionPreviews),
          children: [
            StatefulSwitchListTile(
              title: Text(l10n.settingsCollectionPreviewsAnime),
              subtitle: Text(l10n.settingsCollectionPreviewsAnimeDescription),
              value: options.animeCollectionPreview,
              onChanged: (v) => update(options.copyWith(animeCollectionPreview: v)),
            ),
            StatefulSwitchListTile(
              title: Text(l10n.settingsCollectionPreviewsManga),
              subtitle: Text(l10n.settingsCollectionPreviewsMangaDescription),
              value: options.mangaCollectionPreview,
              onChanged: (v) => update(options.copyWith(mangaCollectionPreview: v)),
            ),
          ],
        ),
        ExpansionTile(
          title: Text(l10n.settingsDefaults),
          children: [
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: l10n.settingsHomeTab,
                items: HomeTab.values.map((v) => (v.localize(l10n), v)).toList(),
                value: options.homeTab,
                onChanged: (v) => update(options.copyWith(homeTab: v)),
                highContrast: options.highContrast,
              ),
            ),
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: l10n.discoverCategories(1),
                items: DiscoverType.values.map((v) => (v.localize(l10n), v)).toList(),
                value: options.discoverType,
                onChanged: (v) => update(options.copyWith(discoverType: v)),
                highContrast: options.highContrast,
              ),
            ),
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: l10n.settingsImageQuality,
                items: ImageQuality.values.map((v) => (v.label, v)).toList(),
                value: options.imageQuality,
                onChanged: (v) => update(options.copyWith(imageQuality: v)),
                highContrast: options.highContrast,
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: Text(l10n.settingsViewLayout),
          children: [
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: l10n.settingsViewLayoutDiscover,
                items: [
                  (l10n.settingsViewLayoutDetailed, DiscoverItemView.detailed),
                  (l10n.settingsViewLayoutSimple, DiscoverItemView.simple),
                ],
                value: options.discoverItemView,
                onChanged: (v) => update(options.copyWith(discoverItemView: v)),
                highContrast: options.highContrast,
              ),
            ),
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: l10n.settingsViewLayoutCollection,
                items: [
                  (l10n.settingsViewLayoutDetailed, CollectionItemView.detailed),
                  (l10n.settingsViewLayoutSimple, CollectionItemView.simple),
                ],
                value: options.collectionItemView,
                onChanged: (v) => update(options.copyWith(collectionItemView: v)),
                highContrast: options.highContrast,
              ),
            ),
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: l10n.settingsViewLayoutCollectionPreview,
                items: [
                  (l10n.settingsViewLayoutDetailed, CollectionItemView.detailed),
                  (l10n.settingsViewLayoutSimple, CollectionItemView.simple),
                ],
                value: options.collectionPreviewItemView,
                onChanged: (v) => update(options.copyWith(collectionPreviewItemView: v)),
                highContrast: options.highContrast,
              ),
            ),
          ],
        ),
        StatefulSwitchListTile(
          title: Text('12 Hour Clock'),
          value: options.analogClock,
          onChanged: (v) => update(options.copyWith(analogClock: v)),
        ),
        StatefulSwitchListTile(
          title: Text(l10n.settingsConfirmExit),
          value: options.confirmExit,
          onChanged: (v) => update(options.copyWith(confirmExit: v)),
        ),
      ],
    );
  }
}
