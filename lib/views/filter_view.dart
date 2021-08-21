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
import 'package:otraku/widgets/overlays/sheets.dart';

class FilterView extends StatelessWidget {
  final String? collectionTag;
  final void Function(bool) isDefinitelyInactive;

  FilterView(this.collectionTag, this.isDefinitelyInactive);

  @override
  Widget build(BuildContext context) {
    final explorer = Get.find<ExplorerController>();
    Filterable filterable;

    if (collectionTag != null)
      filterable = Get.find<CollectionController>(tag: collectionTag);
    else
      filterable = explorer;

    final explorable = collectionTag != null
        ? (filterable as CollectionController).ofAnime
            ? Explorable.anime
            : Explorable.manga
        : explorer.type;

    // Track filter changes.
    final changes = <String, dynamic>{};
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

    // Statuses.
    final statusOptions = <String>[];
    final statusValues = <String>[];
    for (final s in MediaStatus.values) {
      statusValues.add(describeEnum(s));
      statusOptions.add(Convert.clarifyEnum(statusValues.last)!);
    }

    // Formats.
    final formatOptions = <String>[];
    final formatValues = <String>[];
    final iterable = explorable == Explorable.anime
        ? AnimeFormat.values
        : MangaFormat.values;
    for (final f in iterable) {
      formatValues.add(describeEnum(f));
      formatOptions.add(Convert.clarifyEnum(formatValues.last)!);
    }

    // Tags.
    final tags = <String>[];
    if (collectionTag == null)
      for (final v in explorer.tags.values) for (final t in v) tags.add(t.name);

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
          ChipG(
            title: 'Status',
            placeholder: 'statuses',
            options: statusOptions,
            values: statusValues,
            inclusive: changes[Filterable.STATUS_IN],
            sheet: ({
              required List<String> inclusive,
              required List<String>? exclusive,
              required void Function(List<String>, List<String>?) onDone,
            }) =>
                SelectionSheet(
              options: statusOptions,
              values: statusValues,
              inclusive: inclusive,
              exclusive: exclusive != null ? exclusive : null,
              fixHeight: statusOptions.length <= 10,
              onDone: onDone,
            ),
          ),
          ChipG(
            title: 'Format',
            placeholder: 'formats',
            options: formatOptions,
            values: formatValues,
            inclusive: changes[Filterable.FORMAT_IN],
            sheet: ({
              required List<String> inclusive,
              required List<String>? exclusive,
              required void Function(List<String>, List<String>?) onDone,
            }) =>
                SelectionSheet(
              options: formatOptions,
              values: formatValues,
              inclusive: inclusive,
              exclusive: exclusive != null ? exclusive : null,
              fixHeight: formatOptions.length <= 10,
              onDone: onDone,
            ),
          ),
          ChipG(
            title: 'Genres',
            placeholder: 'genres',
            options: explorer.genres,
            values: explorer.genres,
            inclusive: changes[Filterable.GENRE_IN],
            exclusive: changes[Filterable.GENRE_NOT_IN],
            sheet: ({
              required List<String> inclusive,
              required List<String>? exclusive,
              required void Function(List<String>, List<String>?) onDone,
            }) =>
                SelectionSheet(
              options: explorer.genres,
              values: explorer.genres,
              inclusive: inclusive,
              exclusive: exclusive != null ? exclusive : null,
              fixHeight: explorer.genres.length <= 10,
              onDone: onDone,
            ),
          ),
          if (collectionTag == null)
            ChipG(
              title: 'Tags',
              placeholder: 'tags',
              options: tags,
              values: tags,
              inclusive: changes[Filterable.TAG_IN],
              exclusive: changes[Filterable.TAG_NOT_IN],
              sheet: ({
                required List<String> inclusive,
                required List<String>? exclusive,
                required void Function(List<String>, List<String>?) onDone,
              }) =>
                  TagSelectionSheet(
                tags: explorer.tags,
                inclusive: inclusive,
                exclusive: exclusive!,
                onDone: onDone,
              ),
            ),
        ],
      ),
    );
  }
}
