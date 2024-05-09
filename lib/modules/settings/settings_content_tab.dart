import 'package:flutter/material.dart';
import 'package:otraku/common/utils/extensions.dart';
import 'package:otraku/common/widgets/fields/stateful_tiles.dart';
import 'package:otraku/common/widgets/layouts/top_bar.dart';
import 'package:otraku/modules/filter/chip_selector.dart';
import 'package:otraku/modules/media/media_constants.dart';
import 'package:otraku/modules/settings/settings_model.dart';
import 'package:otraku/common/widgets/grids/chip_grids.dart';

class SettingsContentTab extends StatelessWidget {
  const SettingsContentTab(this.scrollCtrl, this.settings);

  final ScrollController scrollCtrl;
  final Settings settings;

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
          title: const Text('Media'),
          initiallyExpanded: true,
          children: [
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: 'Title Language',
                items: TitleLanguage.values.map((v) => (v.label, v)).toList(),
                value: settings.titleLanguage,
                onChanged: (v) => settings.titleLanguage = v,
              ),
            ),
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: 'Character & Staff Names',
                items: PersonNaming.values.map((v) => (v.label, v)).toList(),
                value: settings.personNaming,
                onChanged: (v) => settings.personNaming = v,
              ),
            ),
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: 'Activity Merge Time',
                items: const [
                  ('Never', 0),
                  ('30 Minutes', 30),
                  ('1 Hour', 60),
                  ('2 Hours', 120),
                  ('3 Hours', 180),
                  ('6 Hours', 360),
                  ('12 Hours', 720),
                  ('1 Day', 1440),
                  ('2 Days', 2880),
                  ('3 Days', 4320),
                  ('1 Week', 10080),
                  ('2 Weeks', 20160),
                  ('Always', 29160),
                ],
                value: settings.activityMergeTime,
                onChanged: (v) => settings.activityMergeTime = v,
              ),
            ),
            StatefulSwitchListTile(
              title: const Text('18+ Content'),
              value: settings.displayAdultContent,
              onChanged: (val) => settings.displayAdultContent = val,
            ),
            StatefulSwitchListTile(
              title: const Text('Airing Anime Notifications'),
              value: settings.airingNotifications,
              onChanged: (val) => settings.airingNotifications = val,
            ),
          ],
        ),
        ExpansionTile(
          title: const Text('Lists'),
          initiallyExpanded: true,
          children: [
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: 'Scoring System',
                items: ScoreFormat.values.map((v) => (v.label, v)).toList(),
                value: settings.scoreFormat,
                onChanged: (v) => settings.scoreFormat = v,
              ),
            ),
            Padding(
              padding: tilePadding,
              child: ChipSelector.ensureSelected(
                title: 'Default Site List Sort',
                items: EntrySort.rowOrders.map((v) => (v.label, v)).toList(),
                value: settings.defaultSort,
                onChanged: (v) => settings.defaultSort = v,
              ),
            ),
            StatefulCheckboxListTile(
              title: const Text('Split Completed Anime'),
              value: settings.splitCompletedAnime,
              onChanged: (val) => settings.splitCompletedAnime = val!,
            ),
            StatefulCheckboxListTile(
              title: const Text('Split Completed Manga'),
              value: settings.splitCompletedManga,
              onChanged: (val) => settings.splitCompletedManga = val!,
            ),
            StatefulSwitchListTile(
              title: const Text('Advanced Scoring'),
              value: settings.advancedScoringEnabled,
              onChanged: (val) => settings.advancedScoringEnabled = val,
            ),
            Padding(
              padding: tilePadding,
              child: ChipNamingGrid(
                title: 'Advanced Scores',
                placeholder: 'advanced scores',
                names: settings.advancedScores,
                onChanged: () {},
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
                onChanged: (val) =>
                    settings.disabledListActivity[e.key] = !val!,
              ),
            StatefulSwitchListTile(
              title: const Text('Limit Messages'),
              subtitle: const Text('Only users I follow can message me'),
              value: settings.restrictMessagesToFollowing,
              onChanged: (val) => settings.restrictMessagesToFollowing = val,
            ),
          ],
        ),
      ],
    );
  }
}
