import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/enums/anime_format.dart';
import 'package:otraku/enums/explorable.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/enums/manga_format.dart';
import 'package:otraku/enums/media_status.dart';
import 'package:otraku/controllers/explorer_controller.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/utils/filterable.dart';
import 'package:otraku/widgets/fields/drop_down_field.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/layouts/chip_grid.dart';

class FilterView extends StatelessWidget {
  final String? collectionTag;
  final void Function(bool) isDefinitelyInactive;

  FilterView(this.collectionTag, this.isDefinitelyInactive);

  @override
  Widget build(BuildContext context) {
    final changes = <String, dynamic>{};
    final explorer = Get.find<ExplorerController>();
    Filterable filterable;
    if (collectionTag != null)
      filterable = Get.find<CollectionController>(tag: collectionTag);
    else
      filterable = explorer;

    final browsable = collectionTag != null
        ? (filterable as CollectionController).ofAnime
            ? Explorable.anime
            : Explorable.manga
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
      appBar: ShadowAppBar(
        title: 'Filters',
        actions: [
          AppBarIcon(
            tooltip: 'Clear',
            icon: Icons.close,
            onTap: () {
              filterable.clearAllFilters();
              isDefinitelyInactive(true);
              Navigator.pop(context);
            },
          ),
          AppBarIcon(
            tooltip: 'Apply',
            icon: Icons.done_rounded,
            onTap: () {
              for (final key in changes.keys)
                filterable.setFilterWithKey(key, value: changes[key]);

              if (filterable is ExplorerController) filterable.fetch();
              if (filterable is CollectionController) {
                filterable.scrollTo(0);
                filterable.filter();
              }

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
              hint: 'Everything',
              value: changes[Filterable.ON_LIST],
              items: {
                'In My List': true,
                'Not In My List': false,
              },
              onChanged: (val) => changes[Filterable.ON_LIST] = val,
            ),
          const SizedBox(height: 10),
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
            options: browsable == Explorable.anime
                ? AnimeFormat.values
                    .map((f) => Convert.clarifyEnum(describeEnum(f))!)
                    .toList()
                : MangaFormat.values
                    .map((f) => Convert.clarifyEnum(describeEnum(f))!)
                    .toList(),
            values: browsable == Explorable.anime
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
              inclusive: changes[Filterable.TAG_IN],
              exclusive: changes[Filterable.TAG_NOT_IN],
              tags: explorer.tags,
            ),
        ],
      ),
    );
  }
}
