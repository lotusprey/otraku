import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/controllers/settings_controller.dart';
import 'package:otraku/enums/entry_sort.dart';
import 'package:otraku/enums/score_format.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/widgets/fields/drop_down_field.dart';
import 'package:otraku/widgets/fields/switch_tile.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';

class SettingsContentView extends StatelessWidget {
  const SettingsContentView();

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    return ListView(
      physics: Config.PHYSICS,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      children: [
        Row(
          children: [
            Flexible(
              child: DropDownField<String>(
                title: 'Title Language',
                value: settings.model.titleLanguage,
                items: const {
                  'Romaji': 'ROMAJI',
                  'English': 'ENGLISH',
                  'Native': 'NATIVE',
                },
                onChanged: (val) {
                  const key = 'titleLanguage';
                  if (val == settings.model.titleLanguage)
                    settings.changes.remove(key);
                  else
                    settings.changes[key] = val;
                },
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: DropDownField<int>(
                title: 'Activity Merge Time',
                value: settings.model.activityMergeTime,
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
                  const key = 'activityMergeTime';
                  if (val == settings.model.activityMergeTime)
                    settings.changes.remove(key);
                  else
                    settings.changes[key] = val;
                },
              ),
            ),
          ],
        ),
        SwitchTile(
          title: 'Airing Anime Notifications',
          initialValue: settings.model.airingNotifications,
          onChanged: (val) {
            const notifications = 'airingNotifications';
            if (settings.changes.containsKey(notifications))
              settings.changes.remove(notifications);
            else
              settings.changes[notifications] = val;
          },
        ),
        SwitchTile(
          title: '18+ Content',
          initialValue: settings.model.displayAdultContent,
          onChanged: (val) {
            const adultContent = 'displayAdultContent';
            if (settings.changes.containsKey(adultContent))
              settings.changes.remove(adultContent);
            else
              settings.changes[adultContent] = val;
          },
        ),
        Row(
          children: [
            Flexible(
              child: DropDownField<ScoreFormat>(
                title: 'Scoring System',
                value: settings.model.scoreFormat,
                items: Map.fromIterable(
                  ScoreFormat.values,
                  key: (v) => Convert.clarifyEnum(describeEnum(v))!,
                  value: (v) => v,
                ),
                onChanged: (val) {
                  const key = 'scoreFormat';
                  if (val == settings.model.scoreFormat)
                    settings.changes.remove(key);
                  else
                    settings.changes[key] = describeEnum(val);
                },
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: DropDownField<EntrySort>(
                title: 'Default List Order',
                value: settings.model.defaultSort,
                items: Map.fromIterables(
                  EntrySortHelper.defaultStrings,
                  EntrySortHelper.defaultEnums,
                ),
                onChanged: (val) {
                  const key = 'rowOrder';
                  if (val == settings.model.defaultSort)
                    settings.changes.remove(key);
                  else
                    settings.changes[key] = val.string;
                },
              ),
            ),
          ],
        ),
        SwitchTile(
          title: 'Split Completed Anime',
          initialValue: settings.model.splitCompletedAnime,
          onChanged: (val) {
            const splitAnime = 'splitCompletedAnime';
            if (settings.changes.containsKey(splitAnime))
              settings.changes.remove(splitAnime);
            else
              settings.changes[splitAnime] = val;
          },
        ),
        SwitchTile(
          title: 'Split Completed Manga',
          initialValue: settings.model.splitCompletedManga,
          onChanged: (val) {
            const splitManga = 'splitCompletedManga';
            if (settings.changes.containsKey(splitManga))
              settings.changes.remove(splitManga);
            else
              settings.changes[splitManga] = val;
          },
        ),
        SwitchTile(
          title: 'Advanced Scoring',
          initialValue: settings.model.advancedScoringEnabled,
          onChanged: (val) {
            const advancedScoring = 'advancedScoringEnabled';
            if (settings.changes.containsKey(advancedScoring))
              settings.changes.remove(advancedScoring);
            else
              settings.changes[advancedScoring] = val;
          },
        ),
        Padding(
          padding: Config.PADDING,
          child: Text(
            'Note: Advanced scoring works only with POINT 100 and POINT 10 Decimal scoring systems',
            style: Theme.of(context).textTheme.subtitle2,
          ),
        ),
        SizedBox(height: NavBar.offset(context)),
      ],
    );
  }
}
