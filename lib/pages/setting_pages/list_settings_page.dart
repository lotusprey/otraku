import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/controllers/user_settings.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/enums/list_sort.dart';
import 'package:otraku/enums/score_format.dart';
import 'package:otraku/tools/fields/drop_down_field.dart';
import 'package:otraku/tools/fields/switch_tile.dart';

class ListSettingsPage extends StatelessWidget {
  final Map<String, dynamic> changes;

  ListSettingsPage(this.changes);

  @override
  Widget build(BuildContext context) => ListView(
        physics: Config.PHYSICS,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        children: [
          DropDownField(
            title: 'Scoring System',
            initialValue: Get.find<UserSettings>().settings.scoreFormat,
            items: Map.fromIterable(
              ScoreFormat.values,
              key: (v) => clarifyEnum(describeEnum(v)),
              value: (v) => v,
            ),
            onChanged: (value) {
              const key = 'scoreFormat';
              if (value == Get.find<UserSettings>().settings.scoreFormat) {
                changes.remove(key);
              } else {
                changes[key] = describeEnum(value);
              }
            },
          ),
          const SizedBox(height: 10),
          DropDownField(
            title: 'Default List Order',
            initialValue: Get.find<UserSettings>().settings.defaultSort,
            items: Map.fromIterables(
              ListSortHelper.defaultStrings,
              ListSortHelper.defaultEnums,
            ),
            onChanged: (value) {
              const key = 'rowOrder';
              if (value == Get.find<UserSettings>().settings.defaultSort) {
                changes.remove(key);
              } else {
                changes[key] = (value as ListSort).string;
              }
            },
          ),
          SwitchTile(
            title: 'Split Completed Anime',
            initialValue: Get.find<UserSettings>().settings.splitCompletedAnime,
            onChanged: (value) {
              const splitAnime = 'splitCompletedAnime';
              if (changes.containsKey(splitAnime)) {
                changes.remove(splitAnime);
              } else {
                changes[splitAnime] = value;
              }
            },
          ),
          SwitchTile(
            title: 'Split Completed Manga',
            initialValue: Get.find<UserSettings>().settings.splitCompletedManga,
            onChanged: (value) {
              const splitManga = 'splitCompletedManga';
              if (changes.containsKey(splitManga)) {
                changes.remove(splitManga);
              } else {
                changes[splitManga] = value;
              }
            },
          ),
          const SizedBox(height: 50),
        ],
      );
}
