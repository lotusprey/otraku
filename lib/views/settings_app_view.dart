import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otraku/controllers/home_controller.dart';
import 'package:otraku/enums/entry_sort.dart';
import 'package:otraku/enums/explorable.dart';
import 'package:otraku/enums/media_sort.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/theming.dart';
import 'package:otraku/views/home_view.dart';
import 'package:otraku/widgets/fields/checkbox_field.dart';
import 'package:otraku/widgets/fields/drop_down_field.dart';
import 'package:otraku/widgets/layouts/sliver_grid_delegates.dart';
import 'package:otraku/widgets/layouts/nav_layout.dart';

class SettingsAppView extends StatelessWidget {
  const SettingsAppView();

  @override
  Widget build(BuildContext context) {
    final settings = HomeController.localSettings;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: CustomScrollView(
        physics: Config.PHYSICS,
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
              minWidth: 160,
              height: 75,
            ),
            delegate: SliverChildListDelegate.fixed([
              DropDownField<int>(
                title: 'Light Theme',
                value: settings.lightTheme,
                items: Theming.themes,
                onChanged: (val) => settings.lightTheme = val,
              ),
              DropDownField<int>(
                title: 'Dark Theme',
                value: settings.darkTheme,
                items: Theming.themes,
                onChanged: (val) => settings.darkTheme = val,
              ),
              DropDownField<ThemeMode>(
                title: 'Theme Mode',
                value: settings.themeMode,
                items: const {
                  'Auto': ThemeMode.system,
                  'Light': ThemeMode.light,
                  'Dark': ThemeMode.dark,
                },
                onChanged: (val) => settings.themeMode = val,
              ),
              DropDownField<int>(
                title: 'Startup Page',
                value: settings.defaultHomeTab,
                items: {
                  'Feed': HomeView.FEED,
                  'Anime List': HomeView.ANIME_LIST,
                  'Manga List': HomeView.MANGA_LIST,
                  'Explore': HomeView.EXPLORE,
                  'Profile': HomeView.PROFILE,
                },
                onChanged: (val) => settings.defaultHomeTab = val,
              ),
              DropDownField<EntrySort>(
                title: 'Default Anime Sort',
                value: settings.defaultAnimeSort,
                items: Map.fromIterable(
                  EntrySort.values,
                  key: (v) => Convert.clarifyEnum(describeEnum(v))!,
                ),
                onChanged: (val) => settings.defaultAnimeSort = val,
              ),
              DropDownField<EntrySort>(
                title: 'Default Manga Sort',
                value: settings.defaultMangaSort,
                items: Map.fromIterable(
                  EntrySort.values,
                  key: (v) => Convert.clarifyEnum(describeEnum(v))!,
                ),
                onChanged: (val) => settings.defaultMangaSort = val,
              ),
              DropDownField<MediaSort>(
                title: 'Default Explore Sort',
                value: settings.defaultExploreSort,
                items: Map.fromIterable(
                  MediaSort.values,
                  key: (v) => Convert.clarifyEnum(describeEnum(v))!,
                ),
                onChanged: (val) => settings.defaultExploreSort = val,
              ),
              DropDownField<Explorable>(
                title: 'Default Explorable',
                value: settings.defaultExplorable,
                items: Map.fromIterable(
                  Explorable.values,
                  key: (e) => Convert.clarifyEnum(describeEnum(e))!,
                ),
                onChanged: (val) => settings.defaultExplorable = val,
              ),
            ]),
          ),
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
              minWidth: 200,
              mainAxisSpacing: 0,
              crossAxisSpacing: 20,
              height: Config.MATERIAL_TAP_TARGET_SIZE,
            ),
            delegate: SliverChildListDelegate.fixed([
              CheckBoxField(
                title: 'Left-Handed Mode',
                initial: settings.leftHanded,
                onChanged: (val) => settings.leftHanded = val,
              ),
              CheckBoxField(
                title: '12 Hour Clock',
                initial: settings.analogueClock,
                onChanged: (val) => settings.analogueClock = val,
              ),
              CheckBoxField(
                title: 'Confirm Exit',
                initial: settings.confirmExit,
                onChanged: (val) => settings.confirmExit = val,
              ),
            ]),
          ),
          SliverToBoxAdapter(
              child: SizedBox(height: NavLayout.offset(context))),
        ],
      ),
    );
  }
}
