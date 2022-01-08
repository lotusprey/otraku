import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/home_controller.dart';
import 'package:otraku/models/settings_model.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/constants/entry_sort.dart';
import 'package:otraku/constants/score_format.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/widgets/fields/checkbox_field.dart';
import 'package:otraku/widgets/fields/drop_down_field.dart';
import 'package:otraku/widgets/layouts/chip_grids.dart';
import 'package:otraku/widgets/layouts/sliver_grid_delegates.dart';
import 'package:otraku/widgets/layouts/nav_layout.dart';

class SettingsContentView extends StatelessWidget {
  SettingsContentView(this.model, this.changes);

  final SettingsModel model;
  final Map<String, dynamic> changes;

  @override
  Widget build(BuildContext context) {
    const dropDownGridDelegate = SliverGridDelegateWithMinWidthAndFixedHeight(
      minWidth: 170,
      height: 75,
    );
    const checkBoxGridDelegate = SliverGridDelegateWithMinWidthAndFixedHeight(
      minWidth: 220,
      mainAxisSpacing: 0,
      height: Consts.MATERIAL_TAP_TARGET_SIZE,
    );

    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: CustomScrollView(
        controller: Get.find<HomeController>().scrollCtrl,
        physics: Consts.PHYSICS,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Media',
                style: Theme.of(context).textTheme.headline3,
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
                  value: model.titleLanguage,
                  items: const {
                    'Romaji': 'ROMAJI',
                    'English': 'ENGLISH',
                    'Native': 'NATIVE',
                  },
                  onChanged: (val) {
                    const key = 'titleLanguage';
                    if (val == model.titleLanguage)
                      changes.remove(key);
                    else
                      changes[key] = val;
                  },
                ),
                DropDownField(
                  title: 'Character & Staff Name',
                  value: model.staffNameLanguage,
                  items: const {
                    'Romaji, Western Order': 'ROMAJI_WESTERN',
                    'Romaji': 'ROMAJI',
                    'Native': 'NATIVE',
                  },
                  onChanged: (val) {
                    const key = 'staffNameLanguage';
                    if (val == model.staffNameLanguage)
                      changes.remove(key);
                    else
                      changes[key] = val;
                  },
                ),
                DropDownField(
                  title: 'Activity Merge Time',
                  value: model.activityMergeTime,
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
                    if (val == model.activityMergeTime)
                      changes.remove(key);
                    else
                      changes[key] = val;
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
                initial: model.airingNotifications,
                onChanged: (val) {
                  const notifications = 'airingNotifications';
                  if (changes.containsKey(notifications))
                    changes.remove(notifications);
                  else
                    changes[notifications] = val;
                },
              ),
              CheckBoxField(
                title: '18+ Content',
                initial: model.displayAdultContent,
                onChanged: (val) {
                  const adultContent = 'displayAdultContent';
                  if (changes.containsKey(adultContent))
                    changes.remove(adultContent);
                  else
                    changes[adultContent] = val;
                },
              ),
            ]),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Lists',
                style: Theme.of(context).textTheme.headline3,
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
                  value: model.scoreFormat,
                  items: Map.fromIterable(
                    ScoreFormat.values,
                    key: (v) => Convert.clarifyEnum((v as ScoreFormat).name)!,
                  ),
                  onChanged: (v) {
                    const key = 'scoreFormat';
                    if (v == model.scoreFormat)
                      changes.remove(key);
                    else
                      changes[key] = v.name;
                  },
                ),
                DropDownField<EntrySort>(
                  title: 'Default Site List Sort',
                  value: model.defaultSort,
                  items: Map.fromIterables(
                    EntrySortHelper.defaultStrings,
                    EntrySortHelper.defaultEnums,
                  ),
                  onChanged: (val) {
                    const key = 'rowOrder';
                    if (val == model.defaultSort)
                      changes.remove(key);
                    else
                      changes[key] = val.string;
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
                initial: model.splitCompletedAnime,
                onChanged: (val) {
                  const splitAnime = 'splitCompletedAnime';
                  if (changes.containsKey(splitAnime))
                    changes.remove(splitAnime);
                  else
                    changes[splitAnime] = val;
                },
              ),
              CheckBoxField(
                title: 'Split Completed Manga',
                initial: model.splitCompletedManga,
                onChanged: (val) {
                  const splitManga = 'splitCompletedManga';
                  if (changes.containsKey(splitManga))
                    changes.remove(splitManga);
                  else
                    changes[splitManga] = val;
                },
              ),
              CheckBoxField(
                title: 'Advanced Scoring',
                initial: model.advancedScoringEnabled,
                onChanged: (val) {
                  const advancedScoring = 'advancedScoringEnabled';
                  if (changes.containsKey(advancedScoring))
                    changes.remove(advancedScoring);
                  else
                    changes[advancedScoring] = val;
                },
              ),
            ]),
          ),
          SliverToBoxAdapter(
            child: ChipNamingGrid(
              title: 'Advanced Scores',
              placeholder: 'advanced scores',
              names: model.advancedScores,
              onChanged: () =>
                  changes['advancedScoring'] = model.advancedScores,
            ),
          ),
          SliverToBoxAdapter(
              child: SizedBox(height: NavLayout.offset(context))),
        ],
      ),
    );
  }
}
