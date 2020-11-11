import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/enums/anime_format_enum.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/enums/manga_format_enum.dart';
import 'package:otraku/enums/media_status_enum.dart';
import 'package:otraku/controllers/explorable.dart';
import 'package:otraku/controllers/app_config.dart';
import 'package:otraku/tools/headers/custom_app_bar.dart';
import 'package:otraku/tools/multichild_layouts/filter_grid.dart';

// TODO fix
class FilterPage extends StatelessWidget {
  List<Widget> _gridSection({
    @required BuildContext context,
    @required String name,
    @required FilterGrid grid,
  }) {
    if (grid == null) {
      return [];
    }

    final result = [
      Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(name, style: Theme.of(context).textTheme.subtitle1),
      ),
      grid,
    ];

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final explorable = Get.find<Explorable>();

    List<String> statusIn = [
      ...(explorable.getFilterWithKey(Explorable.STATUS_IN) ?? []),
    ];
    List<String> statusNotIn = [
      ...(explorable.getFilterWithKey(Explorable.STATUS_NOT_IN) ?? []),
    ];
    List<String> formatIn = [
      ...(explorable.getFilterWithKey(Explorable.FORMAT_IN) ?? []),
    ];
    List<String> formatNotIn = [
      ...(explorable.getFilterWithKey(Explorable.FORMAT_NOT_IN) ?? []),
    ];
    List<String> genreIn = [
      ...(explorable.getFilterWithKey(Explorable.GENRE_IN) ?? []),
    ];
    List<String> genreNotIn = [
      ...(explorable.getFilterWithKey(Explorable.GENRE_NOT_IN) ?? []),
    ];
    List<String> tagIn = [
      ...(explorable.getFilterWithKey(Explorable.TAG_IN) ?? []),
    ];
    List<String> tagNotIn = [
      ...(explorable.getFilterWithKey(Explorable.TAG_NOT_IN) ?? []),
    ];

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Filters',
        trailing: [
          IconButton(
            icon: Icon(
              FluentSystemIcons.ic_fluent_checkmark_filled,
              color: Theme.of(context).accentColor,
            ),
            onPressed: () {
              explorable.setFilterWithKey(Explorable.STATUS_IN,
                  value: statusIn);
              explorable.setFilterWithKey(Explorable.STATUS_NOT_IN,
                  value: statusNotIn);
              explorable.setFilterWithKey(Explorable.FORMAT_IN,
                  value: formatIn);
              explorable.setFilterWithKey(Explorable.FORMAT_NOT_IN,
                  value: formatNotIn);
              explorable.setFilterWithKey(Explorable.GENRE_IN, value: genreIn);
              explorable.setFilterWithKey(Explorable.GENRE_NOT_IN,
                  value: genreNotIn);
              explorable.setFilterWithKey(Explorable.TAG_IN, value: tagIn);
              explorable.setFilterWithKey(Explorable.TAG_NOT_IN,
                  value: tagNotIn, notify: true, refetch: true);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: AppConfig.PADDING,
        children: <Widget>[
          ..._gridSection(
            context: context,
            name: 'Status',
            grid: FilterGrid(
              options: MediaStatus.values
                  .map((s) => clarifyEnum(describeEnum(s)))
                  .toList(),
              values: MediaStatus.values.map((s) => describeEnum(s)).toList(),
              optionIn: statusIn,
              optionNotIn: statusNotIn,
              rows: 1,
              whRatio: 0.2,
            ),
          ),
          ..._gridSection(
            context: context,
            name: 'Format',
            grid: FilterGrid(
              options: explorable.type == Browsable.anime
                  ? AnimeFormat.values
                      .map((f) => clarifyEnum(describeEnum(f)))
                      .toList()
                  : MangaFormat.values
                      .map((f) => clarifyEnum(describeEnum(f)))
                      .toList(),
              values: explorable.type == Browsable.anime
                  ? AnimeFormat.values.map((f) => describeEnum(f)).toList()
                  : MangaFormat.values.map((f) => describeEnum(f)).toList(),
              optionIn: formatIn,
              optionNotIn: formatNotIn,
              rows: 1,
              whRatio: 0.3,
            ),
          ),
          // ..._gridSection(
          //   context: context,
          //   name: 'Genres',
          //   grid: FilterGrid(
          //     options: explorable.genres,
          //     values: explorable.genres,
          //     optionIn: genreIn,
          //     optionNotIn: genreNotIn,
          //     rows: 2,
          //     whRatio: 0.24,
          //   ),
          // ),
          ..._gridSection(
            context: context,
            name: 'Tags',
            grid: FilterGrid(
              options: explorable.tags.item1,
              values: explorable.tags.item1,
              descriptions: explorable.tags.item2,
              optionIn: tagIn,
              optionNotIn: tagNotIn,
              rows: 7,
              whRatio: 0.13,
            ),
          ),
        ],
      ),
    );
  }
}
