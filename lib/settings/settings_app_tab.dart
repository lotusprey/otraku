import 'package:flutter/material.dart';
import 'package:otraku/constants/entry_sort.dart';
import 'package:otraku/constants/discover_type.dart';
import 'package:otraku/constants/media_sort.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/views/home_view.dart';
import 'package:otraku/widgets/fields/checkbox_field.dart';
import 'package:otraku/widgets/fields/drop_down_field.dart';
import 'package:otraku/widgets/grids/sliver_grid_delegates.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';
import 'package:otraku/settings/theme_preview.dart';

class SettingsAppTab extends StatelessWidget {
  SettingsAppTab(this.scrollCtrl);

  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollCtrl,
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(height: PageLayout.of(context).topOffset + 10),
        ),
        const ThemePreview(isDark: false),
        const ThemePreview(isDark: true),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
              minWidth: 160,
              height: 75,
            ),
            delegate: SliverChildListDelegate.fixed([
              DropDownField<ThemeMode>(
                title: 'Theme Mode',
                value: Settings().themeMode,
                items: const {
                  'Auto': ThemeMode.system,
                  'Light': ThemeMode.light,
                  'Dark': ThemeMode.dark,
                },
                onChanged: (val) => Settings().themeMode = val,
              ),
              DropDownField<int>(
                title: 'Startup Page',
                value: Settings().defaultHomeTab,
                items: const {
                  'Feed': HomeView.INBOX,
                  'Anime': HomeView.ANIME_LIST,
                  'Manga': HomeView.MANGA_LIST,
                  'Discover': HomeView.DISCOVER,
                  'Profile': HomeView.USER,
                },
                onChanged: (val) => Settings().defaultHomeTab = val,
              ),
              DropDownField<EntrySort>(
                title: 'Default Anime Sort',
                value: Settings().defaultAnimeSort,
                items: Map.fromIterable(
                  EntrySort.values,
                  key: (v) => Convert.clarifyEnum((v as EntrySort).name)!,
                ),
                onChanged: (val) => Settings().defaultAnimeSort = val,
              ),
              DropDownField<EntrySort>(
                title: 'Default Manga Sort',
                value: Settings().defaultMangaSort,
                items: Map.fromIterable(
                  EntrySort.values,
                  key: (v) => Convert.clarifyEnum((v as EntrySort).name)!,
                ),
                onChanged: (val) => Settings().defaultMangaSort = val,
              ),
              DropDownField<MediaSort>(
                title: 'Default Discover Sort',
                value: Settings().defaultDiscoverSort,
                items: Map.fromIterable(
                  MediaSort.values,
                  key: (v) => Convert.clarifyEnum((v as MediaSort).name)!,
                ),
                onChanged: (val) => Settings().defaultDiscoverSort = val,
              ),
              DropDownField<DiscoverType>(
                title: 'Default Discover Type',
                value: Settings().defaultDiscoverType,
                items: Map.fromIterable(
                  DiscoverType.values,
                  key: (v) => Convert.clarifyEnum((v as DiscoverType).name)!,
                ),
                onChanged: (val) => Settings().defaultDiscoverType = val,
              ),
              DropDownField<String>(
                title: 'Image Quality',
                value: Settings().imageQuality,
                items: const {
                  'Very High': 'extraLarge',
                  'High': 'large',
                  'Medium': 'medium',
                },
                onChanged: (val) => Settings().imageQuality = val,
              ),
            ]),
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
                initial: Settings().leftHanded,
                onChanged: (val) => Settings().leftHanded = val,
              ),
              CheckBoxField(
                title: '12 Hour Clock',
                initial: Settings().analogueClock,
                onChanged: (val) => Settings().analogueClock = val,
              ),
              CheckBoxField(
                title: 'Confirm Exit',
                initial: Settings().confirmExit,
                onChanged: (val) => Settings().confirmExit = val,
              ),
            ]),
          ),
        ),
        const SliverFooter(),
      ],
    );
  }
}
