import 'package:flutter/material.dart';
import 'package:otraku/discover/discover_models.dart';
import 'package:otraku/filter/chip_selector.dart';
import 'package:otraku/utils/consts.dart';
import 'package:otraku/media/media_constants.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/options.dart';
import 'package:otraku/home/home_view.dart';
import 'package:otraku/widgets/fields/checkbox_field.dart';
import 'package:otraku/widgets/fields/drop_down_field.dart';
import 'package:otraku/widgets/grids/sliver_grid_delegates.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/layouts/segment_switcher.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';
import 'package:otraku/settings/theme_preview.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class SettingsAppTab extends StatelessWidget {
  const SettingsAppTab(this.scrollCtrl);

  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollCtrl,
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(height: PageLayout.topPadding(context)),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(left: 10, top: 10),
          sliver: SliverToBoxAdapter(
            child:
                Text('Theme', style: Theme.of(context).textTheme.labelMedium),
          ),
        ),
        SliverPadding(
          padding: Consts.padding,
          sliver: SliverToBoxAdapter(
            child: SegmentSwitcher(
              current: Options().themeMode.index,
              items: const ['System', 'Light', 'Dark'],
              onChanged: (i) =>
                  Options().themeMode = ThemeMode.values.elementAt(i),
            ),
          ),
        ),
        const ThemePreview(),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: CheckBoxField(
              title: 'Pure Black Dark Theme',
              initial: Options().pureBlackDarkTheme,
              onChanged: (v) => Options().pureBlackDarkTheme = v,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
              minWidth: 160,
              height: 75,
            ),
            delegate: SliverChildListDelegate.fixed([
              DropDownField<int>(
                title: 'Startup Page',
                value: Options().defaultHomeTab,
                items: const {
                  'Feed': HomeView.INBOX,
                  'Anime': HomeView.ANIME_LIST,
                  'Manga': HomeView.MANGA_LIST,
                  'Discover': HomeView.DISCOVER,
                  'Profile': HomeView.USER,
                },
                onChanged: (val) => Options().defaultHomeTab = val,
              ),
              DropDownField<EntrySort>(
                title: 'Default Anime Sort',
                value: Options().defaultAnimeSort,
                items: Map.fromIterable(EntrySort.values, key: (s) => s.label),
                onChanged: (val) => Options().defaultAnimeSort = val,
              ),
              DropDownField<EntrySort>(
                title: 'Default Manga Sort',
                value: Options().defaultMangaSort,
                items: Map.fromIterable(EntrySort.values, key: (s) => s.label),
                onChanged: (val) => Options().defaultMangaSort = val,
              ),
              DropDownField<MediaSort>(
                title: 'Default Discover Sort',
                value: Options().defaultDiscoverSort,
                items: Map.fromIterable(MediaSort.values, key: (s) => s.label),
                onChanged: (val) => Options().defaultDiscoverSort = val,
              ),
              DropDownField<DiscoverType>(
                title: 'Default Discover Type',
                value: Options().defaultDiscoverType,
                items: Map.fromIterable(
                  DiscoverType.values,
                  key: (v) => Convert.clarifyEnum((v as DiscoverType).name)!,
                ),
                onChanged: (val) => Options().defaultDiscoverType = val,
              ),
              DropDownField<ImageQuality>(
                title: 'Image Quality',
                value: Options().imageQuality,
                items: const {
                  'Very High': ImageQuality.VeryHigh,
                  'High': ImageQuality.High,
                  'Medium': ImageQuality.Medium,
                },
                onChanged: (val) => Options().imageQuality = val,
              ),
            ]),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 5)),
        _SheetExpandButton(
          title: 'Grid Views',
          initialSheetHeight: 250,
          sheetContentBuilder: (context, scrollCtrl) => ListView(
            controller: scrollCtrl,
            padding: const EdgeInsets.symmetric(vertical: 10),
            children: [
              ChipSelector(
                title: 'Discover View',
                options: const ['Detailed List', 'Simple Grid'],
                selected: Options().discoverItemView,
                onChanged: (val) => Options().discoverItemView = val!,
                mustHaveSelected: true,
              ),
              ChipSelector(
                title: 'Collection View',
                options: const ['Detailed List', 'Simple Grid'],
                selected: Options().collectionItemView,
                onChanged: (val) => Options().collectionItemView = val!,
                mustHaveSelected: true,
              ),
              ChipSelector(
                title: 'Collection Preview View',
                options: const ['Detailed List', 'Simple Grid'],
                selected: Options().collectionPreviewItemView,
                onChanged: (val) => Options().collectionPreviewItemView = val!,
                mustHaveSelected: true,
              ),
            ],
          ),
        ),
        _SheetExpandButton(
          title: 'Collection Previews',
          initialSheetHeight: Consts.tapTargetSize * 3 + 150,
          sheetContentBuilder: (context, scrollCtrl) => ListView(
            controller: scrollCtrl,
            padding: Consts.padding,
            children: [
              CheckBoxField(
                title: 'Anime Collection Preview',
                initial: Options().animeCollectionPreview,
                onChanged: (v) => Options().animeCollectionPreview = v,
              ),
              CheckBoxField(
                title: 'Manga Collection Preview',
                initial: Options().mangaCollectionPreview,
                onChanged: (v) => Options().mangaCollectionPreview = v,
              ),
              const SizedBox(height: 5),
              Text(
                'Collection previews only load your current and repeated '
                'media, which results in faster loading times. Disabling '
                'a preview means the whole collection will be loaded at once.',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              CheckBoxField(
                title: 'Exclusive Airing Sort for Anime Preview',
                initial: Options().airingSortForPreview,
                onChanged: (v) => Options().airingSortForPreview = v,
              ),
              const SizedBox(height: 5),
              Text(
                'Anime collection preview will sort anime by '
                'airing time, instead of the default sort.',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
              minWidth: 200,
              mainAxisSpacing: 0,
              crossAxisSpacing: 20,
              height: Consts.tapTargetSize,
            ),
            delegate: SliverChildListDelegate.fixed([
              CheckBoxField(
                title: 'Left-Handed Mode',
                initial: Options().leftHanded,
                onChanged: (val) => Options().leftHanded = val,
              ),
              CheckBoxField(
                title: '12 Hour Clock',
                initial: Options().analogueClock,
                onChanged: (val) => Options().analogueClock = val,
              ),
              CheckBoxField(
                title: 'Confirm Exit',
                initial: Options().confirmExit,
                onChanged: (val) => Options().confirmExit = val,
              ),
            ]),
          ),
        ),
        const SliverFooter(),
      ],
    );
  }
}

class _SheetExpandButton extends StatelessWidget {
  const _SheetExpandButton({
    required this.title,
    required this.initialSheetHeight,
    required this.sheetContentBuilder,
  });

  final String title;
  final double initialSheetHeight;
  final Widget Function(BuildContext, ScrollController) sheetContentBuilder;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.chevron_right_outlined),
        textColor: Theme.of(context).colorScheme.onBackground,
        iconColor: Theme.of(context).colorScheme.onBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        visualDensity: VisualDensity.compact,
        onTap: () => showSheet(
          context,
          OpaqueSheet(
            builder: sheetContentBuilder,
            initialHeight: initialSheetHeight,
          ),
        ),
      ),
    );
  }
}
