import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/controllers/settings.dart';
import 'package:otraku/controllers/viewer.dart';
import 'package:otraku/helpers/enum_helper.dart';
import 'package:otraku/enums/list_sort.dart';
import 'package:otraku/enums/score_format.dart';
import 'package:otraku/tools/fields/drop_down_field.dart';
import 'package:otraku/tools/fields/switch_tile.dart';

class ListSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = Get.find<Settings>();
    return ListView(
      physics: Config.PHYSICS,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      children: [
        DropDownField(
          title: 'Scoring System',
          initialValue: Get.find<Viewer>().settings.scoreFormat,
          items: Map.fromIterable(
            ScoreFormat.values,
            key: (v) => EnumHelper.clarifyEnum(describeEnum(v)),
            value: (v) => v,
          ),
          onChanged: (value) {
            const key = 'scoreFormat';
            if (value == Get.find<Viewer>().settings.scoreFormat) {
              settings.changes.remove(key);
            } else {
              settings.changes[key] = describeEnum(value);
            }
          },
        ),
        const SizedBox(height: 10),
        DropDownField(
          title: 'Default List Order',
          initialValue: Get.find<Viewer>().settings.defaultSort,
          items: Map.fromIterables(
            ListSortHelper.defaultStrings,
            ListSortHelper.defaultEnums,
          ),
          onChanged: (value) {
            const key = 'rowOrder';
            if (value == Get.find<Viewer>().settings.defaultSort) {
              settings.changes.remove(key);
            } else {
              settings.changes[key] = (value as ListSort).string;
            }
          },
        ),
        SwitchTile(
          title: 'Split Completed Anime',
          initialValue: Get.find<Viewer>().settings.splitCompletedAnime,
          onChanged: (value) {
            const splitAnime = 'splitCompletedAnime';
            if (settings.changes.containsKey(splitAnime)) {
              settings.changes.remove(splitAnime);
            } else {
              settings.changes[splitAnime] = value;
            }
          },
        ),
        SwitchTile(
          title: 'Split Completed Manga',
          initialValue: Get.find<Viewer>().settings.splitCompletedManga,
          onChanged: (value) {
            const splitManga = 'splitCompletedManga';
            if (settings.changes.containsKey(splitManga)) {
              settings.changes.remove(splitManga);
            } else {
              settings.changes[splitManga] = value;
            }
          },
        ),
        const SizedBox(height: 50),
      ],
    );
  }
}
