import 'package:flutter/material.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/fields/stateful_tiles.dart';
import 'package:otraku/feature/discover/discover_models.dart';
import 'package:otraku/feature/filter/chip_selector.dart';
import 'package:otraku/feature/home/home_model.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/util/persistence.dart';
import 'package:otraku/feature/settings/theme_preview.dart';

class SettingsAppSubview extends StatelessWidget {
  const SettingsAppSubview(this.scrollCtrl);

  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    final listPadding = MediaQuery.paddingOf(context);
    const tilePadding = EdgeInsets.only(
      bottom: Theming.offset,
      left: Theming.offset,
      right: Theming.offset,
    );

    return ListView(
      controller: scrollCtrl,
      padding: EdgeInsets.only(
        top: listPadding.top + Theming.normalTapTarget + Theming.offset,
        bottom: listPadding.bottom + Theming.offset,
      ),
      children: [
        ExpansionTile(
          title: const Text('Appearance'),
          initiallyExpanded: true,
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _ThemeModeSelection(),
            const ThemePreview(),
            StatefulSwitchListTile(
              title: const Text('Pure White/Black Theme'),
              value: Persistence().pureWhiteOrBlackTheme,
              onChanged: (v) => Persistence().pureWhiteOrBlackTheme = v,
            ),
          ],
        ),
        ExpansionTile(
          title: const Text('Default Sortings'),
          children: [
            Padding(
              padding: tilePadding,
              child: EntrySortChipSelector(
                title: 'Collection Anime Sorting',
                value: Persistence().defaultAnimeSort,
                onChanged: (v) => Persistence().defaultAnimeSort = v,
              ),
            ),
            Padding(
              padding: tilePadding,
              child: EntrySortChipSelector(
                title: 'Collection Manga Sorting',
                value: Persistence().defaultMangaSort,
                onChanged: (v) => Persistence().defaultMangaSort = v,
              ),
            ),
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: 'Discover Media Sorting',
                items: MediaSort.values.map((e) => (e.label, e)).toList(),
                value: Persistence().defaultDiscoverSort,
                onChanged: (v) => Persistence().defaultDiscoverSort = v,
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: const Text('Collection Previews'),
          children: [
            StatefulSwitchListTile(
              title: const Text('Anime Collection Preview'),
              subtitle: const Text(
                'Only load your watched/rewatched anime '
                'and expand to full collection with the floating button',
              ),
              value: Persistence().animeCollectionPreview,
              onChanged: (v) => Persistence().animeCollectionPreview = v,
            ),
            StatefulSwitchListTile(
              title: const Text('Manga Collection Preview'),
              subtitle: const Text(
                'Only load your read/reread manga '
                'and expand to full collection with the floating button',
              ),
              value: Persistence().mangaCollectionPreview,
              onChanged: (v) => Persistence().mangaCollectionPreview = v,
            ),
            StatefulSwitchListTile(
              title: const Text('Exclusive Airing Sort for Anime Preview'),
              subtitle: const Text(
                'Sort by soonest airing, instead of the default',
              ),
              value: Persistence().airingSortForPreview,
              onChanged: (v) => Persistence().airingSortForPreview = v,
            ),
            const SizedBox(height: 5),
          ],
        ),
        ExpansionTile(
          title: const Text('Loading & Startup Defaults'),
          children: [
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: 'Home Tab',
                items: HomeTab.values.map((v) => (v.label, v)).toList(),
                value: Persistence().defaultHomeTab,
                onChanged: (v) => Persistence().defaultHomeTab = v,
              ),
            ),
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: 'Default Discover Type',
                items: DiscoverType.values.map((v) => (v.label, v)).toList(),
                value: Persistence().defaultDiscoverType,
                onChanged: (v) => Persistence().defaultDiscoverType = v,
              ),
            ),
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: 'Image Quality',
                items: ImageQuality.values.map((v) => (v.label, v)).toList(),
                value: Persistence().imageQuality,
                onChanged: (v) => Persistence().imageQuality = v,
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: const Text('View Layouts'),
          children: [
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: 'Discover View',
                items: const [('Detailed List', 0), ('Simple Grid', 1)],
                value: Persistence().discoverItemView,
                onChanged: (val) => Persistence().discoverItemView = val,
              ),
            ),
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: 'Collection View',
                items: const [('Detailed List', 0), ('Simple Grid', 1)],
                value: Persistence().collectionItemView,
                onChanged: (val) => Persistence().collectionItemView = val,
              ),
            ),
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: 'Collection Preview View',
                items: const [('Detailed List', 0), ('Simple Grid', 1)],
                value: Persistence().collectionPreviewItemView,
                onChanged: (val) =>
                    Persistence().collectionPreviewItemView = val,
              ),
            ),
          ],
        ),
        StatefulSwitchListTile(
          title: const Text('Left-Handed Mode'),
          value: Persistence().leftHanded,
          onChanged: (v) => Persistence().leftHanded = v,
        ),
        StatefulSwitchListTile(
          title: const Text('12 Hour Clock'),
          value: Persistence().analogueClock,
          onChanged: (v) => Persistence().analogueClock = v,
        ),
        StatefulSwitchListTile(
          title: const Text('Confirm Exit'),
          value: Persistence().confirmExit,
          onChanged: (v) => Persistence().confirmExit = v,
        ),
      ],
    );
  }
}

class _ThemeModeSelection extends StatefulWidget {
  const _ThemeModeSelection();

  @override
  State<_ThemeModeSelection> createState() => __ThemeModeSelectionState();
}

class __ThemeModeSelectionState extends State<_ThemeModeSelection> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: Theming.offset,
        left: Theming.offset,
        right: Theming.offset,
      ),
      child: SegmentedButton(
        segments: const [
          ButtonSegment(
            value: ThemeMode.system,
            label: Text('System'),
            icon: Icon(Icons.sync_outlined),
          ),
          ButtonSegment(
            value: ThemeMode.light,
            label: Text('Light'),
            icon: Icon(Icons.wb_sunny_outlined),
          ),
          ButtonSegment(
            value: ThemeMode.dark,
            label: Text('Dark'),
            icon: Icon(Icons.mode_night_outlined),
          ),
        ],
        selected: {Persistence().themeMode},
        onSelectionChanged: (v) => setState(
          () => Persistence().themeMode = v.first,
        ),
      ),
    );
  }
}
