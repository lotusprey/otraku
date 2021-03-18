import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/collection.dart';
import 'package:otraku/enums/anime_format.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/enums/manga_format.dart';
import 'package:otraku/enums/media_status.dart';
import 'package:otraku/controllers/explorer.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/utils/filterable.dart';
import 'package:otraku/widgets/fields/drop_down_field.dart';
import 'package:otraku/widgets/navigation/custom_app_bar.dart';
import 'package:otraku/widgets/layouts/chip_grid.dart';

class FilterPage extends StatelessWidget {
  static const ROUTE = '/filters';

  final String? collectionTag;
  final Function(bool) isDefinitelyInactive;

  FilterPage(this.collectionTag, this.isDefinitelyInactive);

  @override
  Widget build(BuildContext context) {
    final changes = <String, dynamic>{};
    final explorer = Get.find<Explorer>();
    Filterable filterable;
    if (collectionTag != null)
      filterable = Get.find<Collection>(tag: collectionTag);
    else
      filterable = explorer;

    final browsable = collectionTag != null
        ? (filterable as Collection).ofAnime
            ? Browsable.anime
            : Browsable.manga
        : explorer.type;

    changes[Filterable.STATUS_IN] = List<String>.from(
      filterable.getFilterWithKey(Filterable.STATUS_IN) ?? [],
    );
    changes[Filterable.FORMAT_IN] = List<String>.from(
      filterable.getFilterWithKey(Filterable.FORMAT_IN) ?? [],
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
    changes[Filterable.ON_LIST] =
        filterable.getFilterWithKey(Filterable.ON_LIST);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Filters',
        trailing: [
          IconButton(
            tooltip: 'Clear Filters',
            icon: const Icon(Icons.close),
            color: Theme.of(context).dividerColor,
            onPressed: () {
              filterable.clearAllFilters();
              isDefinitelyInactive(true);
              Navigator.pop(context);
            },
          ),
          IconButton(
            tooltip: 'Apply Filters',
            icon: Icon(
              FluentIcons.checkmark_24_filled,
              color: Theme.of(context).dividerColor,
            ),
            onPressed: () {
              for (final key in changes.keys)
                filterable.setFilterWithKey(key, value: changes[key]);

              if (filterable is Collection) filterable.filter();
              if (filterable is Explorer) filterable.fetch();

              isDefinitelyInactive(false);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: ListView(
        physics: Config.PHYSICS,
        padding: Config.PADDING,
        children: [
          if (collectionTag == null)
            DropDownField(
              title: 'List Filter',
              initialValue: changes[Filterable.ON_LIST],
              items: {
                'Everything': null,
                'In My List': true,
                'Not In My List': false,
              },
              onChanged: (dynamic value) => changes[Filterable.ON_LIST] = value,
            ),
          ChipGrid(
            title: 'Status',
            placeholder: 'statuses',
            options: MediaStatus.values
                .map((s) => Convert.clarifyEnum(describeEnum(s))!)
                .toList(),
            values: MediaStatus.values.map((s) => describeEnum(s)).toList(),
            inclusive: changes[Filterable.STATUS_IN],
          ),
          ChipGrid(
            title: 'Format',
            placeholder: 'formats',
            options: browsable == Browsable.anime
                ? AnimeFormat.values
                    .map((f) => Convert.clarifyEnum(describeEnum(f))!)
                    .toList()
                : MangaFormat.values
                    .map((f) => Convert.clarifyEnum(describeEnum(f))!)
                    .toList(),
            values: browsable == Browsable.anime
                ? AnimeFormat.values.map((f) => describeEnum(f)).toList()
                : MangaFormat.values.map((f) => describeEnum(f)).toList(),
            inclusive: changes[Filterable.FORMAT_IN],
          ),
          ChipGrid(
            title: 'Genres',
            placeholder: 'genres',
            options: explorer.genres,
            values: explorer.genres,
            inclusive: changes[Filterable.GENRE_IN],
            exclusive: changes[Filterable.GENRE_NOT_IN],
          ),
          if (collectionTag == null)
            ChipGrid(
              title: 'Tags',
              placeholder: 'tags',
              options: explorer.tags.keys.toList(),
              values: explorer.tags.keys.toList(),
              inclusive: changes[Filterable.TAG_IN],
              exclusive: changes[Filterable.TAG_NOT_IN],
            ),
        ],
      ),
    );
  }
}
