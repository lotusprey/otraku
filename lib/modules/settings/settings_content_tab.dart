import 'package:flutter/material.dart';
import 'package:otraku/common/utils/extensions.dart';
import 'package:otraku/common/widgets/fields/stateful_tiles.dart';
import 'package:otraku/common/widgets/layouts/top_bar.dart';
import 'package:otraku/modules/media/media_constants.dart';
import 'package:otraku/modules/settings/settings_model.dart';
import 'package:otraku/common/widgets/fields/drop_down_field.dart';
import 'package:otraku/common/widgets/grids/chip_grids.dart';

class SettingsContentTab extends StatelessWidget {
  const SettingsContentTab(this.scrollCtrl, this.settings, this.scheduleUpdate);

  final ScrollController scrollCtrl;
  final Settings settings;
  final void Function() scheduleUpdate;

  @override
  Widget build(BuildContext context) {
    const tilePadding = EdgeInsets.only(bottom: 10, left: 10, right: 10);

    return ListView(
      controller: scrollCtrl,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + TopBar.height + 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      children: [
        ExpansionTile(
          title: const Text('Media'),
          initiallyExpanded: true,
          children: [
            Padding(
              padding: tilePadding,
              child: DropDownField(
                title: 'Title Language',
                value: settings.titleLanguage,
                items: const {
                  'Romaji': 'ROMAJI',
                  'English': 'ENGLISH',
                  'Native': 'NATIVE',
                },
                onChanged: (val) {
                  settings.titleLanguage = val;
                  scheduleUpdate();
                },
              ),
            ),
            Padding(
              padding: tilePadding,
              child: DropDownField(
                title: 'Character & Staff Names',
                value: settings.personNaming,
                items: const {
                  'Romaji, Western Order': PersonNaming.ROMAJI_WESTERN,
                  'Romaji': PersonNaming.ROMAJI,
                  'Native': PersonNaming.NATIVE,
                },
                onChanged: (val) {
                  settings.personNaming = val;
                  scheduleUpdate();
                },
              ),
            ),
            Padding(
              padding: tilePadding,
              child: DropDownField(
                title: 'Activity Merge Time',
                value: settings.activityMergeTime,
                items: const {
                  'Never': 0,
                  '30 Minutes': 30,
                  '1 Hour': 60,
                  '2 Hours': 120,
                  '3 Hours': 180,
                  '6 Hours': 360,
                  '12 Hours': 720,
                  '1 Day': 1440,
                  '2 Days': 2880,
                  '3 Days': 4320,
                  '1 Week': 10080,
                  '2 Weeks': 20160,
                  'Always': 29160,
                },
                onChanged: (val) {
                  settings.activityMergeTime = val;
                  scheduleUpdate();
                },
              ),
            ),
            StatefulSwitchListTile(
              title: const Text('18+ Content'),
              value: settings.displayAdultContent,
              onChanged: (val) {
                settings.displayAdultContent = val;
                scheduleUpdate();
              },
            ),
            StatefulSwitchListTile(
              title: const Text('Airing Anime Notifications'),
              value: settings.airingNotifications,
              onChanged: (val) {
                settings.airingNotifications = val;
                scheduleUpdate();
              },
            ),
          ],
        ),
        ExpansionTile(
          title: const Text('Lists'),
          initiallyExpanded: true,
          children: [
            Padding(
              padding: tilePadding,
              child: DropDownField<ScoreFormat>(
                title: 'Scoring System',
                value: settings.scoreFormat,
                items: Map.fromIterable(
                  ScoreFormat.values,
                  key: (v) => (v as ScoreFormat).label,
                ),
                onChanged: (val) {
                  settings.scoreFormat = val;
                  scheduleUpdate();
                },
              ),
            ),
            Padding(
              padding: tilePadding,
              child: DropDownField<EntrySort>(
                title: 'Default Site List Sort',
                value: settings.defaultSort,
                items: Map.fromIterable(
                  EntrySort.rowOrders,
                  key: (s) => s.label,
                ),
                onChanged: (val) {
                  settings.defaultSort = val;
                  scheduleUpdate();
                },
              ),
            ),
            StatefulCheckboxListTile(
              title: const Text('Split Completed Anime'),
              value: settings.splitCompletedAnime,
              onChanged: (val) {
                settings.splitCompletedAnime = val!;
                scheduleUpdate();
              },
            ),
            StatefulCheckboxListTile(
              title: const Text('Split Completed Manga'),
              value: settings.splitCompletedManga,
              onChanged: (val) {
                settings.splitCompletedManga = val!;
                scheduleUpdate();
              },
            ),
            StatefulSwitchListTile(
              title: const Text('Advanced Scoring'),
              value: settings.advancedScoringEnabled,
              onChanged: (val) {
                settings.advancedScoringEnabled = val;
                scheduleUpdate();
              },
            ),
            Padding(
              padding: tilePadding,
              child: ChipNamingGrid(
                title: 'Advanced Scores',
                placeholder: 'advanced scores',
                names: settings.advancedScores,
                onChanged: scheduleUpdate,
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: const Text('Social'),
          initiallyExpanded: true,
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text('List Activity Creation'),
            ),
            for (final e in settings.disabledListActivity.entries)
              StatefulCheckboxListTile(
                title: Text(e.key.name.noScreamingSnakeCase),
                value: !e.value,
                onChanged: (val) {
                  settings.disabledListActivity[e.key] = !val!;
                  scheduleUpdate();
                },
              ),
            StatefulSwitchListTile(
              title: const Text('Limit Messages'),
              subtitle: const Text('Only users I follow can message me'),
              value: settings.restrictMessagesToFollowing,
              onChanged: (val) {
                settings.restrictMessagesToFollowing = val;
                scheduleUpdate();
              },
            ),
          ],
        ),
      ],
    );
  }
}
