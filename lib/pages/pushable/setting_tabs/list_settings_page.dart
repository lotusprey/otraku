import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/enums/list_sort_enum.dart';
import 'package:otraku/enums/score_format_enum.dart';
import 'package:otraku/controllers/users.dart';
import 'package:otraku/tools/fields/drop_down_field.dart';
import 'package:otraku/tools/fields/switch_tile.dart';
import 'package:otraku/tools/navigators/custom_app_bar.dart';

class ListSettingsPage extends StatelessWidget {
  final Map<String, dynamic> changes;

  ListSettingsPage(this.changes);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: CustomAppBar(
          title: 'Lists',
        ),
        body: ListView(
          physics: Config.PHYSICS,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          children: [
            DropDownField(
              title: 'Scoring System',
              initialValue: Get.find<Users>().settings.scoreFormat,
              items: Map.fromIterable(
                ScoreFormat.values,
                key: (v) => clarifyEnum(describeEnum(v)),
                value: (v) => v,
              ),
              onChanged: (value) {
                const key = 'scoreFormat';
                if (value == Get.find<Users>().settings.scoreFormat) {
                  changes.remove(key);
                } else {
                  changes[key] = describeEnum(value);
                }
              },
            ),
            DropDownField(
              title: 'Default List Order',
              initialValue: Get.find<Users>().settings.defaultSort,
              items: Map.fromIterables(
                ListSortHelper.defaultStrings,
                ListSortHelper.defaultEnums,
              ),
              onChanged: (value) {
                const key = 'rowOrder';
                if (value == Get.find<Users>().settings.defaultSort) {
                  changes.remove(key);
                } else {
                  changes[key] = (value as ListSort).string;
                }
              },
            ),
            SwitchTile(
              title: 'Split Completed Anime',
              initialValue: Get.find<Users>().settings.splitCompletedAnime,
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
              initialValue: Get.find<Users>().settings.splitCompletedManga,
              onChanged: (value) {
                const splitManga = 'splitCompletedManga';
                if (changes.containsKey(splitManga)) {
                  changes.remove(splitManga);
                } else {
                  changes[splitManga] = value;
                }
              },
            ),
          ],
        ),
      );
}
