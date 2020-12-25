import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/collection.dart';
import 'package:otraku/enums/anime_format_enum.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/enums/list_sort_enum.dart';
import 'package:otraku/enums/manga_format_enum.dart';
import 'package:otraku/enums/media_sort_enum.dart';
import 'package:otraku/enums/media_status_enum.dart';
import 'package:otraku/controllers/explorer.dart';
import 'package:otraku/services/config.dart';
import 'package:otraku/services/filterable.dart';
import 'package:otraku/tools/fields/drop_down_field.dart';
import 'package:otraku/tools/navigators/custom_app_bar.dart';
import 'package:otraku/tools/layouts/chip_grid.dart';

class FilterPage extends StatelessWidget {
  final String collectionTag;
  final Function(bool) onUpdate;
  final Map<String, dynamic> changes = {};

  FilterPage(this.collectionTag, this.onUpdate);

  @override
  Widget build(BuildContext context) {
    final explorable = Get.find<Explorer>();

    Filterable filterable;
    if (collectionTag != null)
      filterable = Get.find<Collection>(tag: collectionTag);
    else
      filterable = explorable;

    final browsable = collectionTag != null
        ? (filterable as Collection).ofAnime
            ? Browsable.anime
            : Browsable.manga
        : explorable.type;

    changes[Filterable.STATUS_IN] = List<String>.from(
      filterable.getFilterWithKey(Filterable.STATUS_IN) ?? [],
    );
    changes[Filterable.STATUS_NOT_IN] = List<String>.from(
      filterable.getFilterWithKey(Filterable.STATUS_NOT_IN) ?? [],
    );
    changes[Filterable.FORMAT_IN] = List<String>.from(
      filterable.getFilterWithKey(Filterable.FORMAT_IN) ?? [],
    );
    changes[Filterable.FORMAT_NOT_IN] = List<String>.from(
      filterable.getFilterWithKey(Filterable.FORMAT_NOT_IN) ?? [],
    );
    changes[Filterable.GENRE_IN] = List<String>.from(
      filterable.getFilterWithKey(Filterable.GENRE_IN) ?? [],
    );
    changes[Filterable.GENRE_NOT_IN] = List<String>.from(
      filterable.getFilterWithKey(Filterable.GENRE_NOT_IN) ?? [],
    );
    changes[Filterable.TAG_IN] = List<String>.from(
      filterable.getFilterWithKey(Filterable.TAG_IN) ?? [],
    );
    changes[Filterable.TAG_NOT_IN] = List<String>.from(
      filterable.getFilterWithKey(Filterable.TAG_NOT_IN) ?? [],
    );
    changes[Filterable.SORT] = filterable.getFilterWithKey(Filterable.SORT);
    changes[Filterable.ON_LIST] =
        filterable.getFilterWithKey(Filterable.ON_LIST);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Filters',
        trailing: [
          IconButton(
            icon: const Icon(Icons.close),
            color: Theme.of(context).accentColor,
            onPressed: () {
              filterable.clearAllFilters();
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
              for (final key in changes.keys)
                filterable.setFilterWithKey(key, value: changes[key]);

              if (filterable is Collection) filterable.fetch();
              if (filterable is Explorer) filterable.fetchData();

              //TODO sort
              // if (collectionTag != null)
              //   (filterable as Collection).sort();

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
          Row(
            children: [
              if (collectionTag != null)
                Expanded(
                  child: DropDownField(
                    title: 'Sort',
                    initialValue: changes[Filterable.SORT],
                    items: Map.fromIterable(
                      ListSort.values,
                      key: (v) => clarifyEnum(describeEnum(v)),
                      value: (v) => v,
                    ),
                    onChanged: (value) => changes[Filterable.SORT] = value,
                  ),
                )
              else ...[
                Expanded(
                  child: DropDownField(
                    title: 'Sort',
                    initialValue: changes[Filterable.SORT],
                    items: Map.fromIterable(
                      MediaSort.values,
                      key: (v) => clarifyEnum(describeEnum(v)),
                      value: (v) => describeEnum(v),
                    ),
                    onChanged: (value) => changes[Filterable.SORT] = value,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropDownField(
                    title: 'List Filter',
                    initialValue: changes[Filterable.ON_LIST],
                    items: {
                      'Everything': null,
                      'In My List': true,
                      'Not In My List': false,
                    },
                    onChanged: (value) => changes[Filterable.ON_LIST] = value,
                  ),
                ),
              ],
            ],
          ),
          ChipGrid(
            title: 'Status',
            placeholder: 'statuses',
            options: MediaStatus.values
                .map((s) => clarifyEnum(describeEnum(s)))
                .toList(),
            values: MediaStatus.values.map((s) => describeEnum(s)).toList(),
            inclusive: changes[Filterable.STATUS_IN],
            exclusive: changes[Filterable.STATUS_NOT_IN],
          ),
          ChipGrid(
            title: 'Format',
            placeholder: 'formats',
            options: browsable == Browsable.anime
                ? AnimeFormat.values
                    .map((f) => clarifyEnum(describeEnum(f)))
                    .toList()
                : MangaFormat.values
                    .map((f) => clarifyEnum(describeEnum(f)))
                    .toList(),
            values: browsable == Browsable.anime
                ? AnimeFormat.values.map((f) => describeEnum(f)).toList()
                : MangaFormat.values.map((f) => describeEnum(f)).toList(),
            inclusive: changes[Filterable.FORMAT_IN],
            exclusive: changes[Filterable.FORMAT_NOT_IN],
          ),
          ChipGrid(
            title: 'Genres',
            placeholder: 'genres',
            options: explorable.genres,
            values: explorable.genres,
            inclusive: changes[Filterable.GENRE_IN],
            exclusive: changes[Filterable.GENRE_NOT_IN],
          ),
          if (collectionTag == null)
            ChipGrid(
              title: 'Tags',
              placeholder: 'tags',
              options: explorable.tags.item1,
              values: explorable.tags.item1,
              inclusive: changes[Filterable.TAG_IN],
              exclusive: changes[Filterable.TAG_NOT_IN],
            ),
        ],
      ),
    );
  }
}
