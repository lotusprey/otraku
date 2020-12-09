import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/enums/anime_format_enum.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/enums/manga_format_enum.dart';
import 'package:otraku/enums/media_status_enum.dart';
import 'package:otraku/controllers/explorable.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/tools/navigators/custom_app_bar.dart';
import 'package:otraku/tools/layouts/chip_grid.dart';

class FilterPage extends StatelessWidget {
  final Function(bool) onUpdate;

  FilterPage(this.onUpdate);

  @override
  Widget build(BuildContext context) {
    final explorable = Get.find<Explorable>();

    List<String> statusIn =
        List.from(explorable.getFilterWithKey(Explorable.STATUS_IN) ?? []);
    List<String> statusNotIn =
        List.from(explorable.getFilterWithKey(Explorable.STATUS_NOT_IN) ?? []);
    List<String> formatIn =
        List.from(explorable.getFilterWithKey(Explorable.FORMAT_IN) ?? []);
    List<String> formatNotIn =
        List.from(explorable.getFilterWithKey(Explorable.FORMAT_NOT_IN) ?? []);
    List<String> genreIn =
        List.from(explorable.getFilterWithKey(Explorable.GENRE_IN) ?? []);
    List<String> genreNotIn =
        List.from(explorable.getFilterWithKey(Explorable.GENRE_NOT_IN) ?? []);
    List<String> tagIn =
        List.from(explorable.getFilterWithKey(Explorable.TAG_IN) ?? []);
    List<String> tagNotIn =
        List.from(explorable.getFilterWithKey(Explorable.TAG_NOT_IN) ?? []);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Filters',
        trailing: [
          IconButton(
            icon: const Icon(Icons.close),
            color: Theme.of(context).accentColor,
            onPressed: () {
              explorable.clearAllFilters();
              onUpdate(false);
              Navigator.of(context).pop();
            },
          ),
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
                  value: tagNotIn, refetch: true);
              onUpdate(null);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: ListView(
        physics: Config.PHYSICS,
        padding: Config.PADDING,
        children: [
          ChipGrid(
            title: 'Status',
            placeholder: 'statuses',
            options: MediaStatus.values
                .map((s) => clarifyEnum(describeEnum(s)))
                .toList(),
            values: MediaStatus.values.map((s) => describeEnum(s)).toList(),
            inclusive: statusIn,
            exclusive: statusNotIn,
          ),
          ChipGrid(
            title: 'Format',
            placeholder: 'formats',
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
            inclusive: formatIn,
            exclusive: formatNotIn,
          ),
          ChipGrid(
            title: 'Genres',
            placeholder: 'genres',
            options: explorable.genres,
            values: explorable.genres,
            inclusive: genreIn,
            exclusive: genreNotIn,
          ),
          ChipGrid(
            title: 'Tags',
            placeholder: 'tags',
            options: explorable.tags.item1,
            values: explorable.tags.item1,
            inclusive: tagIn,
            exclusive: tagNotIn,
          ),
        ],
      ),
    );
  }
}
