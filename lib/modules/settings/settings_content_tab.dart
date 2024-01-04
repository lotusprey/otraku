import 'package:flutter/material.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/common/utils/extensions.dart';
import 'package:otraku/common/widgets/layouts/top_bar.dart';
import 'package:otraku/modules/media/media_constants.dart';
import 'package:otraku/modules/settings/settings_model.dart';
import 'package:otraku/common/widgets/fields/checkbox_field.dart';
import 'package:otraku/common/widgets/fields/drop_down_field.dart';
import 'package:otraku/common/widgets/grids/chip_grids.dart';
import 'package:otraku/common/widgets/grids/sliver_grid_delegates.dart';
import 'package:otraku/common/widgets/loaders/loaders.dart';

class SettingsContentTab extends StatelessWidget {
  const SettingsContentTab(this.scrollCtrl, this.settings, this.scheduleUpdate);

  final ScrollController scrollCtrl;
  final Settings settings;
  final void Function() scheduleUpdate;

  @override
  Widget build(BuildContext context) {
    const dropDownGridDelegate = SliverGridDelegateWithMinWidthAndFixedHeight(
      minWidth: 170,
      height: 75,
    );
    const checkBoxGridDelegate = SliverGridDelegateWithMinWidthAndFixedHeight(
      minWidth: 220,
      mainAxisSpacing: 0,
      height: Consts.tapTargetSize,
    );
    const smallGridDelegate = SliverGridDelegateWithMinWidthAndFixedHeight(
      minWidth: 140,
      mainAxisSpacing: 0,
      height: Consts.tapTargetSize,
    );

    return CustomScrollView(
      controller: scrollCtrl,
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: MediaQuery.of(context).padding.top + TopBar.height + 10,
          ),
        ),
        SliverToBoxAdapter(
          child: CheckBoxField(
            title: 'Restrict Messages to Following',
            initial: settings.restrictMessagesToFollowing,
            onChanged: (val) {
              settings.restrictMessagesToFollowing = val;
              scheduleUpdate();
            },
          ),
        ),
        SliverGrid(
          gridDelegate: dropDownGridDelegate,
          delegate: SliverChildListDelegate.fixed([
            DropDownField(
              title: 'Title Language',
              value: settings.titleLanguage,
              items: const {
                'Romaji': 'ROMAJI',
                'English': 'ENGLISH',
                'Native': 'NATIVE',
              },
              onChanged: (String val) {
                settings.titleLanguage = val;
                scheduleUpdate();
              },
            ),
            DropDownField(
              title: 'Character & Staff Name',
              value: settings.staffNameLanguage,
              items: const {
                'Romaji, Western Order': 'ROMAJI_WESTERN',
                'Romaji': 'ROMAJI',
                'Native': 'NATIVE',
              },
              onChanged: (String val) {
                settings.staffNameLanguage = val;
                scheduleUpdate();
              },
            ),
            DropDownField(
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
              onChanged: (int val) {
                settings.activityMergeTime = val;
                scheduleUpdate();
              },
            ),
          ]),
        ),
        SliverGrid(
          gridDelegate: checkBoxGridDelegate,
          delegate: SliverChildListDelegate.fixed([
            CheckBoxField(
              title: 'Airing Anime Notifications',
              initial: settings.airingNotifications,
              onChanged: (val) {
                settings.airingNotifications = val;
                scheduleUpdate();
              },
            ),
            CheckBoxField(
              title: '18+ Content',
              initial: settings.displayAdultContent,
              onChanged: (val) {
                settings.displayAdultContent = val;
                scheduleUpdate();
              },
            ),
          ]),
        ),
        SliverGrid(
          gridDelegate: dropDownGridDelegate,
          delegate: SliverChildListDelegate.fixed([
            DropDownField<ScoreFormat>(
              title: 'Scoring System',
              value: settings.scoreFormat,
              items: Map.fromIterable(
                ScoreFormat.values,
                key: (v) => (v as ScoreFormat).name.noScreamingSnakeCase,
              ),
              onChanged: (val) {
                settings.scoreFormat = val;
                scheduleUpdate();
              },
            ),
            DropDownField<EntrySort>(
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
          ]),
        ),
        SliverGrid(
          gridDelegate: checkBoxGridDelegate,
          delegate: SliverChildListDelegate.fixed([
            CheckBoxField(
              title: 'Split Completed Anime',
              initial: settings.splitCompletedAnime,
              onChanged: (val) {
                settings.splitCompletedAnime = val;
                scheduleUpdate();
              },
            ),
            CheckBoxField(
              title: 'Split Completed Manga',
              initial: settings.splitCompletedManga,
              onChanged: (val) {
                settings.splitCompletedManga = val;
                scheduleUpdate();
              },
            ),
            CheckBoxField(
              title: 'Advanced Scoring',
              initial: settings.advancedScoringEnabled,
              onChanged: (val) {
                settings.advancedScoringEnabled = val;
                scheduleUpdate();
              },
            ),
          ]),
        ),
        SliverToBoxAdapter(
          child: ChipNamingGrid(
            title: 'Advanced Scores',
            placeholder: 'advanced scores',
            names: settings.advancedScores,
            onChanged: scheduleUpdate,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 10)),
        const SliverToBoxAdapter(
          child: Text('Disable List Activity Creation of:'),
        ),
        SliverGrid(
          gridDelegate: smallGridDelegate,
          delegate: SliverChildListDelegate.fixed([
            for (final e in settings.disabledListActivity.entries)
              CheckBoxField(
                title: e.key.name.noScreamingSnakeCase,
                initial: e.value,
                onChanged: (val) {
                  settings.disabledListActivity[e.key] = val;
                  scheduleUpdate();
                },
              ),
          ]),
        ),
        const SliverFooter(),
      ],
    );
  }
}
