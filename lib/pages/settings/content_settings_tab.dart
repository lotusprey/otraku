import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/controllers/settings.dart';
import 'package:otraku/enums/list_sort.dart';
import 'package:otraku/enums/score_format.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/widgets/fields/drop_down_field.dart';
import 'package:otraku/widgets/fields/switch_tile.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';

class ContentSettingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = Get.find<Settings>();
    return ListView(
      physics: Config.PHYSICS,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      children: [
        DropDownField<String>(
          title: 'Title Language',
          initialValue: settings.model!.titleLanguage,
          items: {
            'Romaji': 'ROMAJI',
            'English': 'ENGLISH',
            'Native': 'NATIVE',
          },
          onChanged: (value) {
            const key = 'titleLanguage';
            if (value == settings.model!.titleLanguage)
              settings.changes.remove(key);
            else
              settings.changes[key] = value;
          },
        ),
        SwitchTile(
          title: 'Airing Anime Notifications',
          initialValue: settings.model!.airingNotifications,
          onChanged: (value) {
            const notifications = 'airingNotifications';
            if (settings.changes.containsKey(notifications))
              settings.changes.remove(notifications);
            else
              settings.changes[notifications] = value;
          },
        ),
        SwitchTile(
          title: '18+ Content',
          initialValue: settings.model!.displayAdultContent,
          onChanged: (value) {
            const adultContent = 'displayAdultContent';
            if (settings.changes.containsKey(adultContent))
              settings.changes.remove(adultContent);
            else
              settings.changes[adultContent] = value;
          },
        ),
        DropDownField<ScoreFormat>(
          title: 'Scoring System',
          initialValue: settings.model!.scoreFormat,
          items: Map.fromIterable(
            ScoreFormat.values,
            key: (v) => Convert.clarifyEnum(describeEnum(v))!,
            value: (v) => v,
          ),
          onChanged: (value) {
            const key = 'scoreFormat';
            if (value == settings.model!.scoreFormat)
              settings.changes.remove(key);
            else
              settings.changes[key] = describeEnum(value);
          },
        ),
        const SizedBox(height: 10),
        DropDownField<ListSort>(
          title: 'Default List Order',
          initialValue: settings.model!.defaultSort,
          items: Map.fromIterables(
            ListSortHelper.defaultStrings,
            ListSortHelper.defaultEnums,
          ),
          onChanged: (value) {
            const key = 'rowOrder';
            if (value == settings.model!.defaultSort)
              settings.changes.remove(key);
            else
              settings.changes[key] = value.string;
          },
        ),
        SwitchTile(
          title: 'Split Completed Anime',
          initialValue: settings.model!.splitCompletedAnime,
          onChanged: (value) {
            const splitAnime = 'splitCompletedAnime';
            if (settings.changes.containsKey(splitAnime))
              settings.changes.remove(splitAnime);
            else
              settings.changes[splitAnime] = value;
          },
        ),
        SwitchTile(
          title: 'Split Completed Manga',
          initialValue: settings.model!.splitCompletedManga,
          onChanged: (value) {
            const splitManga = 'splitCompletedManga';
            if (settings.changes.containsKey(splitManga))
              settings.changes.remove(splitManga);
            else
              settings.changes[splitManga] = value;
          },
        ),
        SwitchTile(
          title: 'Advanced Scoring',
          initialValue: settings.model!.advancedScoringEnabled,
          onChanged: (value) {
            const advancedScoring = 'advancedScoringEnabled';
            if (settings.changes.containsKey(advancedScoring))
              settings.changes.remove(advancedScoring);
            else
              settings.changes[advancedScoring] = value;
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
