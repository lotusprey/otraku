import 'package:flutter/material.dart';
import 'package:otraku/common/widgets/fields/stateful_tiles.dart';
import 'package:otraku/common/widgets/layouts/top_bar.dart';
import 'package:otraku/modules/discover/discover_models.dart';
import 'package:otraku/modules/filter/chip_selector.dart';
import 'package:otraku/modules/home/home_model.dart';
import 'package:otraku/modules/media/media_constants.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/modules/settings/theme_preview.dart';

class SettingsAppTab extends StatelessWidget {
  const SettingsAppTab(this.scrollCtrl);

  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    const tilePadding = EdgeInsets.only(bottom: 10, left: 10, right: 10);
    final listPadding = MediaQuery.paddingOf(context);

    return ListView(
      controller: scrollCtrl,
      padding: EdgeInsets.only(
        top: listPadding.top + TopBar.height + 10,
        bottom: listPadding.bottom + 10,
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
              value: Options().pureWhiteOrBlackTheme,
              onChanged: (v) => Options().pureWhiteOrBlackTheme = v,
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
                current: Options().defaultAnimeSort,
                onChanged: (v) => Options().defaultAnimeSort = v,
              ),
            ),
            Padding(
              padding: tilePadding,
              child: EntrySortChipSelector(
                title: 'Collection Manga Sorting',
                current: Options().defaultMangaSort,
                onChanged: (v) => Options().defaultMangaSort = v,
              ),
            ),
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: 'Discover Media Sorting',
                items: MediaSort.values.map((e) => (e.label, e)).toList(),
                value: Options().defaultDiscoverSort,
                onChanged: (v) => Options().defaultDiscoverSort = v,
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
              value: Options().animeCollectionPreview,
              onChanged: (v) => Options().animeCollectionPreview = v,
            ),
            StatefulSwitchListTile(
              title: const Text('Manga Collection Preview'),
              subtitle: const Text(
                'Only load your read/reread manga '
                'and expand to full collection with the floating button',
              ),
              value: Options().mangaCollectionPreview,
              onChanged: (v) => Options().mangaCollectionPreview = v,
            ),
            StatefulSwitchListTile(
              title: const Text('Exclusive Airing Sort for Anime Preview'),
              subtitle: const Text(
                'Sort by airing time, instead of the default',
              ),
              value: Options().airingSortForPreview,
              onChanged: (v) => Options().airingSortForPreview = v,
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
                value: Options().defaultHomeTab,
                onChanged: (v) => Options().defaultHomeTab = v,
              ),
            ),
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: 'Default Discover Type',
                items: DiscoverType.values.map((v) => (v.label, v)).toList(),
                value: Options().defaultDiscoverType,
                onChanged: (v) => Options().defaultDiscoverType = v,
              ),
            ),
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: 'Image Quality',
                items: ImageQuality.values.map((v) => (v.label, v)).toList(),
                value: Options().imageQuality,
                onChanged: (v) => Options().imageQuality = v,
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
                value: Options().discoverItemView,
                onChanged: (val) => Options().discoverItemView = val,
              ),
            ),
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: 'Collection View',
                items: const [('Detailed List', 0), ('Simple Grid', 1)],
                value: Options().collectionItemView,
                onChanged: (val) => Options().collectionItemView = val,
              ),
            ),
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: 'Collection Preview View',
                items: const [('Detailed List', 0), ('Simple Grid', 1)],
                value: Options().collectionPreviewItemView,
                onChanged: (val) => Options().collectionPreviewItemView = val,
              ),
            ),
          ],
        ),
        StatefulSwitchListTile(
          title: const Text('Left-Handed Mode'),
          value: Options().leftHanded,
          onChanged: (v) => Options().leftHanded = v,
        ),
        StatefulSwitchListTile(
          title: const Text('12 Hour Clock'),
          value: Options().analogueClock,
          onChanged: (v) => Options().analogueClock = v,
        ),
        StatefulSwitchListTile(
          title: const Text('Confirm Exit'),
          value: Options().confirmExit,
          onChanged: (v) => Options().confirmExit = v,
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
      padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
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
        selected: {Options().themeMode},
        onSelectionChanged: (v) => setState(
          () => Options().themeMode = v.first,
        ),
      ),
    );
  }
}
