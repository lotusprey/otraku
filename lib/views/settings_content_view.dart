import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/controllers/settings_controller.dart';
import 'package:otraku/enums/entry_sort.dart';
import 'package:otraku/enums/score_format.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/widgets/fields/checkbox_field.dart';
import 'package:otraku/widgets/fields/drop_down_field.dart';
import 'package:otraku/widgets/layouts/sliver_grid_delegates.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';

class SettingsContentView extends StatelessWidget {
  const SettingsContentView();

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    const dropDownGridDelegate = SliverGridDelegateWithMinWidthAndFixedHeight(
      minWidth: 170,
      height: 75,
    );
    const checkBoxGridDelegate = SliverGridDelegateWithMinWidthAndFixedHeight(
      minWidth: 225,
      mainAxisSpacing: 0,
      crossAxisSpacing: 20,
      height: Config.MATERIAL_TAP_TARGET_SIZE,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: CustomScrollView(
        physics: Config.PHYSICS,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Media',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
          ),
          SliverGrid(
            gridDelegate: dropDownGridDelegate,
            delegate: SliverChildListDelegate.fixed([
              DropDownField(
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
              DropDownField(
                title: 'Character & Staff Name',
                value: settings.model.staffNameLanguage,
                items: const {
                  'Romaji, Western Order': 'ROMAJI_WESTERN',
                  'Romaji': 'ROMAJI',
                  'Native': 'NATIVE',
                },
                onChanged: (val) {
                  const key = 'staffNameLanguage';
                  if (val == settings.model.staffNameLanguage)
                    settings.changes.remove(key);
                  else
                    settings.changes[key] = val;
                },
              ),
              DropDownField(
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
            ]),
          ),
          SliverGrid(
            gridDelegate: checkBoxGridDelegate,
            delegate: SliverChildListDelegate.fixed([
              CheckBoxField(
                title: 'Airing Anime Notifications',
                initial: settings.model.airingNotifications,
                onChanged: (val) {
                  const notifications = 'airingNotifications';
                  if (settings.changes.containsKey(notifications))
                    settings.changes.remove(notifications);
                  else
                    settings.changes[notifications] = val;
                },
              ),
              CheckBoxField(
                title: '18+ Content',
                initial: settings.model.displayAdultContent,
                onChanged: (val) {
                  const adultContent = 'displayAdultContent';
                  if (settings.changes.containsKey(adultContent))
                    settings.changes.remove(adultContent);
                  else
                    settings.changes[adultContent] = val;
                },
              ),
            ]),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Lists',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
          ),
          SliverGrid(
            gridDelegate: dropDownGridDelegate,
            delegate: SliverChildListDelegate.fixed([
              DropDownField<ScoreFormat>(
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
              DropDownField<EntrySort>(
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
            ]),
          ),
          SliverGrid(
            gridDelegate: checkBoxGridDelegate,
            delegate: SliverChildListDelegate.fixed([
              CheckBoxField(
                title: 'Split Completed Anime',
                initial: settings.model.splitCompletedAnime,
                onChanged: (val) {
                  const splitAnime = 'splitCompletedAnime';
                  if (settings.changes.containsKey(splitAnime))
                    settings.changes.remove(splitAnime);
                  else
                    settings.changes[splitAnime] = val;
                },
              ),
              CheckBoxField(
                title: 'Split Completed Manga',
                initial: settings.model.splitCompletedManga,
                onChanged: (val) {
                  const splitManga = 'splitCompletedManga';
                  if (settings.changes.containsKey(splitManga))
                    settings.changes.remove(splitManga);
                  else
                    settings.changes[splitManga] = val;
                },
              ),
              CheckBoxField(
                title: 'Advanced Scoring',
                initial: settings.model.advancedScoringEnabled,
                onChanged: (val) {
                  const advancedScoring = 'advancedScoringEnabled';
                  if (settings.changes.containsKey(advancedScoring))
                    settings.changes.remove(advancedScoring);
                  else
                    settings.changes[advancedScoring] = val;
                },
              ),
            ]),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: Config.PADDING,
              child: Text(
                'Note: Advanced scoring works only with POINT 100 and POINT 10 Decimal scoring systems',
                style: Theme.of(context).textTheme.subtitle2,
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: NavBar.offset(context))),
        ],
      ),
    );
  }
}
