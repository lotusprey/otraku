import 'package:flutter/material.dart';
import 'package:otraku/common/widgets/fields/stateful_tiles.dart';
import 'package:otraku/common/widgets/layouts/top_bar.dart';
import 'package:otraku/modules/discover/discover_models.dart';
import 'package:otraku/modules/filter/chip_selector.dart';
import 'package:otraku/modules/home/home_provider.dart';
import 'package:otraku/modules/media/media_constants.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/common/widgets/fields/drop_down_field.dart';
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
            Padding(
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
                onSelectionChanged: (v) => Options().themeMode = v.first,
              ),
            ),
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
              child: ChipSelector(
                title: 'Discover Media Sorting',
                options: MediaSort.values.map((s) => s.label).toList(),
                current: Options().defaultDiscoverSort.index,
                mustHaveSelected: true,
                onChanged: (i) => Options().defaultDiscoverSort =
                    MediaSort.values.elementAt(i!),
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
              child: DropDownField<int>(
                title: 'Home Tab',
                value: Options().defaultHomeTab.index,
                items: {
                  for (final t in HomeTab.values) t.title: t.index,
                },
                onChanged: (v) => Options().defaultHomeTab = HomeTab.values[v],
              ),
            ),
            Padding(
              padding: tilePadding,
              child: DropDownField<DiscoverType>(
                title: 'Default Discover Type',
                value: Options().defaultDiscoverType,
                items: Map.fromIterable(
                  DiscoverType.values,
                  key: (v) => (v as DiscoverType).name,
                ),
                onChanged: (v) => Options().defaultDiscoverType = v,
              ),
            ),
            Padding(
              padding: tilePadding,
              child: DropDownField<ImageQuality>(
                title: 'Image Quality',
                value: Options().imageQuality,
                items: const {
                  'Very High': ImageQuality.VeryHigh,
                  'High': ImageQuality.High,
                  'Medium': ImageQuality.Medium,
                },
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
              child: ChipSelector(
                title: 'Discover View',
                options: const ['Detailed List', 'Simple Grid'],
                current: Options().discoverItemView,
                onChanged: (val) => Options().discoverItemView = val!,
                mustHaveSelected: true,
              ),
            ),
            Padding(
              padding: tilePadding,
              child: ChipSelector(
                title: 'Collection View',
                options: const ['Detailed List', 'Simple Grid'],
                current: Options().collectionItemView,
                onChanged: (val) => Options().collectionItemView = val!,
                mustHaveSelected: true,
              ),
            ),
            Padding(
              padding: tilePadding,
              child: ChipSelector(
                title: 'Collection Preview View',
                options: const ['Detailed List', 'Simple Grid'],
                current: Options().collectionPreviewItemView,
                onChanged: (val) => Options().collectionPreviewItemView = val!,
                mustHaveSelected: true,
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
