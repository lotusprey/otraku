import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otraku/enums/entry_sort.dart';
import 'package:otraku/enums/explorable.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/theming.dart';
import 'package:otraku/views/home_view.dart';
import 'package:otraku/widgets/fields/checkbox_field.dart';
import 'package:otraku/widgets/fields/drop_down_field.dart';
import 'package:otraku/widgets/layouts/sliver_grid_delegates.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';

class SettingsAppView extends StatelessWidget {
  const SettingsAppView();

  @override
  Widget build(BuildContext context) => Padding(
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
                  value: Theming.it.light,
                  items: Theming.themes,
                  onChanged: (val) => Theming.it.light = val,
                ),
                DropDownField<int>(
                  title: 'Dark Theme',
                  value: Theming.it.dark,
                  items: Theming.themes,
                  onChanged: (val) => Theming.it.dark = val,
                ),
                DropDownField<ThemeMode>(
                  title: 'Theme Mode',
                  value: Theming.it.mode,
                  items: const {
                    'Auto': ThemeMode.system,
                    'Light': ThemeMode.light,
                    'Dark': ThemeMode.dark,
                  },
                  onChanged: (val) => Theming.it.mode = val,
                ),
                DropDownField<int>(
                  title: 'Startup Page',
                  value: Config.storage.read(Config.STARTUP_PAGE) ??
                      HomeView.ANIME_LIST,
                  items: {
                    'Feed': HomeView.FEED,
                    'Anime List': HomeView.ANIME_LIST,
                    'Manga List': HomeView.MANGA_LIST,
                    'Explore': HomeView.EXPLORE,
                    'Profile': HomeView.PROFILE,
                  },
                  onChanged: (val) =>
                      Config.storage.write(Config.STARTUP_PAGE, val),
                ),
                DropDownField<EntrySort>(
                  title: 'Default Anime Sort',
                  value: EntrySort.values.elementAt(
                    Config.storage.read(Config.DEFAULT_ANIME_SORT) ?? 0,
                  ),
                  items: Map.fromIterable(
                    EntrySort.values,
                    key: (v) => Convert.clarifyEnum(describeEnum(v))!,
                    value: (v) => v,
                  ),
                  onChanged: (val) => Config.storage
                      .write(Config.DEFAULT_ANIME_SORT, val.index),
                ),
                DropDownField<EntrySort>(
                  title: 'Default Manga Sort',
                  value: EntrySort.values.elementAt(
                    Config.storage.read(Config.DEFAULT_MANGA_SORT) ?? 0,
                  ),
                  items: Map.fromIterable(
                    EntrySort.values,
                    key: (v) => Convert.clarifyEnum(describeEnum(v))!,
                    value: (v) => v,
                  ),
                  onChanged: (val) => Config.storage
                      .write(Config.DEFAULT_MANGA_SORT, val.index),
                ),
                DropDownField<int>(
                  title: 'Default Explorable',
                  value: Config.storage.read(Config.DEFAULT_EXPLORE) ?? 0,
                  items: Map.fromIterable(
                    Explorable.values,
                    key: (e) => Convert.clarifyEnum(describeEnum(e))!,
                    value: (e) => e.index,
                  ),
                  onChanged: (val) =>
                      Config.storage.write(Config.DEFAULT_EXPLORE, val),
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
                  initial: Config.storage.read(Config.LEFT_HANDED) ?? false,
                  onChanged: (val) =>
                      Config.storage.write(Config.LEFT_HANDED, val),
                ),
                CheckBoxField(
                  title: '12 Hour Clock',
                  initial: Config.storage.read(Config.CLOCK_TYPE) ?? false,
                  onChanged: (val) =>
                      Config.storage.write(Config.CLOCK_TYPE, val),
                ),
                CheckBoxField(
                  title: 'Confirm Exit',
                  initial: Config.storage.read(Config.CONFIRM_EXIT) ?? false,
                  onChanged: (val) =>
                      Config.storage.write(Config.CONFIRM_EXIT, val),
                ),
              ]),
            ),
            SliverToBoxAdapter(child: SizedBox(height: NavBar.offset(context))),
          ],
        ),
      );
}
