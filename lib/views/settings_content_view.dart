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
import 'package:otraku/widgets/layouts/chip_grids.dart';
import 'package:otraku/widgets/layouts/sliver_grid_delegates.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';

class SettingsContentView extends StatelessWidget {
  const SettingsContentView();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SettingsController>();

    const dropDownGridDelegate = SliverGridDelegateWithMinWidthAndFixedHeight(
      minWidth: 170,
      height: 75,
    );
    const checkBoxGridDelegate = SliverGridDelegateWithMinWidthAndFixedHeight(
      minWidth: 220,
      mainAxisSpacing: 0,
      height: Config.MATERIAL_TAP_TARGET_SIZE,
    );

    return Padding(
      padding: const EdgeInsets.only(left: 10),
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
          SliverPadding(
            padding: const EdgeInsets.only(right: 10),
            sliver: SliverGrid(
              gridDelegate: dropDownGridDelegate,
              delegate: SliverChildListDelegate.fixed([
                DropDownField(
                  title: 'Title Language',
                  value: ctrl.model.titleLanguage,
                  items: const {
                    'Romaji': 'ROMAJI',
                    'English': 'ENGLISH',
                    'Native': 'NATIVE',
                  },
                  onChanged: (val) {
                    const key = 'titleLanguage';
                    if (val == ctrl.model.titleLanguage)
                      ctrl.changes.remove(key);
                    else
                      ctrl.changes[key] = val;
                  },
                ),
                DropDownField(
                  title: 'Character & Staff Name',
                  value: ctrl.model.staffNameLanguage,
                  items: const {
                    'Romaji, Western Order': 'ROMAJI_WESTERN',
                    'Romaji': 'ROMAJI',
                    'Native': 'NATIVE',
                  },
                  onChanged: (val) {
                    const key = 'staffNameLanguage';
                    if (val == ctrl.model.staffNameLanguage)
                      ctrl.changes.remove(key);
                    else
                      ctrl.changes[key] = val;
                  },
                ),
                DropDownField(
                  title: 'Activity Merge Time',
                  value: ctrl.model.activityMergeTime,
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
                    if (val == ctrl.model.activityMergeTime)
                      ctrl.changes.remove(key);
                    else
                      ctrl.changes[key] = val;
                  },
                ),
              ]),
            ),
          ),
          SliverGrid(
            gridDelegate: checkBoxGridDelegate,
            delegate: SliverChildListDelegate.fixed([
              CheckBoxField(
                title: 'Airing Anime Notifications',
                initial: ctrl.model.airingNotifications,
                onChanged: (val) {
                  const notifications = 'airingNotifications';
                  if (ctrl.changes.containsKey(notifications))
                    ctrl.changes.remove(notifications);
                  else
                    ctrl.changes[notifications] = val;
                },
              ),
              CheckBoxField(
                title: '18+ Content',
                initial: ctrl.model.displayAdultContent,
                onChanged: (val) {
                  const adultContent = 'displayAdultContent';
                  if (ctrl.changes.containsKey(adultContent))
                    ctrl.changes.remove(adultContent);
                  else
                    ctrl.changes[adultContent] = val;
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
          SliverPadding(
            padding: const EdgeInsets.only(right: 10),
            sliver: SliverGrid(
              gridDelegate: dropDownGridDelegate,
              delegate: SliverChildListDelegate.fixed([
                DropDownField<ScoreFormat>(
                  title: 'Scoring System',
                  value: ctrl.model.scoreFormat,
                  items: Map.fromIterable(
                    ScoreFormat.values,
                    key: (v) => Convert.clarifyEnum(describeEnum(v))!,
                    value: (v) => v,
                  ),
                  onChanged: (val) {
                    const key = 'scoreFormat';
                    if (val == ctrl.model.scoreFormat)
                      ctrl.changes.remove(key);
                    else
                      ctrl.changes[key] = describeEnum(val);
                  },
                ),
                DropDownField<EntrySort>(
                  title: 'Default Site List Sort',
                  value: ctrl.model.defaultSort,
                  items: Map.fromIterables(
                    EntrySortHelper.defaultStrings,
                    EntrySortHelper.defaultEnums,
                  ),
                  onChanged: (val) {
                    const key = 'rowOrder';
                    if (val == ctrl.model.defaultSort)
                      ctrl.changes.remove(key);
                    else
                      ctrl.changes[key] = val.string;
                  },
                ),
              ]),
            ),
          ),
          SliverGrid(
            gridDelegate: checkBoxGridDelegate,
            delegate: SliverChildListDelegate.fixed([
              CheckBoxField(
                title: 'Split Completed Anime',
                initial: ctrl.model.splitCompletedAnime,
                onChanged: (val) {
                  const splitAnime = 'splitCompletedAnime';
                  if (ctrl.changes.containsKey(splitAnime))
                    ctrl.changes.remove(splitAnime);
                  else
                    ctrl.changes[splitAnime] = val;
                },
              ),
              CheckBoxField(
                title: 'Split Completed Manga',
                initial: ctrl.model.splitCompletedManga,
                onChanged: (val) {
                  const splitManga = 'splitCompletedManga';
                  if (ctrl.changes.containsKey(splitManga))
                    ctrl.changes.remove(splitManga);
                  else
                    ctrl.changes[splitManga] = val;
                },
              ),
              CheckBoxField(
                title: 'Advanced Scoring',
                initial: ctrl.model.advancedScoringEnabled,
                onChanged: (val) {
                  const advancedScoring = 'advancedScoringEnabled';
                  if (ctrl.changes.containsKey(advancedScoring))
                    ctrl.changes.remove(advancedScoring);
                  else
                    ctrl.changes[advancedScoring] = val;
                },
              ),
            ]),
          ),
          SliverToBoxAdapter(
            child: ChipNamingGrid(
              title: 'Advanced Scores',
              placeholder: 'advanced scores',
              names: ctrl.model.advancedScores,
              onChanged: () =>
                  ctrl.changes['advancedScoring'] = ctrl.model.advancedScores,
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: NavBar.offset(context))),
        ],
      ),
    );
  }
}
