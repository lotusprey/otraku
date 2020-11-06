import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/enums/list_sort_enum.dart';
import 'package:otraku/enums/score_format_enum.dart';
import 'package:otraku/providers/users.dart';
import 'package:otraku/tools/fields/drop_down_field.dart';
import 'package:otraku/tools/fields/switch_tile.dart';
import 'package:otraku/tools/headers/custom_app_bar.dart';
import 'package:provider/provider.dart';

class ListSettingsPage extends StatelessWidget {
  final Map<String, dynamic> changes;

  ListSettingsPage(this.changes);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: CustomAppBar(
          title: 'Lists',
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          children: [
            DropDownField(
              title: 'Scoring System',
              initialValue: Provider.of<Users>(context, listen: false)
                  .settings
                  .scoreFormat,
              items: Map.fromIterable(
                ScoreFormat.values,
                key: (v) => clarifyEnum(describeEnum(v)),
                value: (v) => v,
              ),
              onChange: (value) {
                const key = 'scoreFormat';
                if (value ==
                    Provider.of<Users>(context, listen: false)
                        .settings
                        .scoreFormat) {
                  changes.remove(key);
                } else {
                  changes[key] = describeEnum(value);
                }
              },
            ),
            DropDownField(
              title: 'Default List Order',
              initialValue: Provider.of<Users>(context, listen: false)
                  .settings
                  .defaultSort,
              items: Map.fromIterables(
                ListSortHelper.defaultStrings,
                ListSortHelper.defaultEnums,
              ),
              onChange: (value) {
                const key = 'rowOrder';
                if (value ==
                    Provider.of<Users>(context, listen: false)
                        .settings
                        .defaultSort) {
                  changes.remove(key);
                } else {
                  changes[key] = (value as ListSort).string;
                }
              },
            ),
            SwitchTile(
              label: 'Split Completed Anime',
              initialValue: Provider.of<Users>(context, listen: false)
                  .settings
                  .splitCompletedAnime,
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
              label: 'Split Completed Manga',
              initialValue: Provider.of<Users>(context, listen: false)
                  .settings
                  .splitCompletedManga,
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
