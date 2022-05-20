import 'package:flutter/material.dart';
import 'package:otraku/constants/entry_sort.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/constants/media_sort.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/utils/theming.dart';
import 'package:otraku/views/home_view.dart';
import 'package:otraku/widgets/fields/checkbox_field.dart';
import 'package:otraku/widgets/fields/drop_down_field.dart';
import 'package:otraku/widgets/grids/sliver_grid_delegates.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';

class SettingsAppTab extends StatelessWidget {
  SettingsAppTab(this.scrollCtrl);

  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    final colorSchemeMap = <String, int>{};
    for (int i = 0; i < Theming.schemes.length; i++)
      colorSchemeMap[Theming.schemes.keys.elementAt(i)] = i;

    final offset = PageOffset.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: CustomScrollView(
        controller: scrollCtrl,
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: offset.top + 10)),
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
              minWidth: 160,
              height: 75,
            ),
            delegate: SliverChildListDelegate.fixed([
              DropDownField<int>(
                title: 'Light Theme',
                value: Settings().lightTheme,
                items: colorSchemeMap,
                onChanged: (val) => Settings().lightTheme = val,
              ),
              DropDownField<int>(
                title: 'Dark Theme',
                value: Settings().darkTheme,
                items: colorSchemeMap,
                onChanged: (val) => Settings().darkTheme = val,
              ),
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
                  'Inbox': HomeView.INBOX,
                  'Anime List': HomeView.ANIME_LIST,
                  'Manga List': HomeView.MANGA_LIST,
                  'Explore': HomeView.EXPLORE,
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
                title: 'Default Explore Sort',
                value: Settings().defaultExploreSort,
                items: Map.fromIterable(
                  MediaSort.values,
                  key: (v) => Convert.clarifyEnum((v as MediaSort).name)!,
                ),
                onChanged: (val) => Settings().defaultExploreSort = val,
              ),
              DropDownField<Explorable>(
                title: 'Default Explorable',
                value: Settings().defaultExplorable,
                items: Map.fromIterable(
                  Explorable.values,
                  key: (v) => Convert.clarifyEnum((v as Explorable).name)!,
                ),
                onChanged: (val) => Settings().defaultExplorable = val,
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
          SliverGrid(
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
          SliverToBoxAdapter(child: SizedBox(height: offset.bottom)),
        ],
      ),
    );
  }
}
