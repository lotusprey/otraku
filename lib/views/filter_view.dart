import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/enums/anime_format.dart';
import 'package:otraku/enums/entry_sort.dart';
import 'package:otraku/enums/explorable.dart';
import 'package:otraku/enums/media_sort.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/enums/manga_format.dart';
import 'package:otraku/enums/media_status.dart';
import 'package:otraku/controllers/explore_controller.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/utils/filterable.dart';
import 'package:otraku/widgets/fields/drop_down_field.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/layouts/chip_grids.dart';
import 'package:otraku/widgets/overlays/drag_sheets.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class FilterView extends StatelessWidget {
  static const COLLECTION_SHOUD_SORT_KEY = 'COLLECTION_SHOUD_SORT';

  FilterView(this.collectionTag, this.isDefinitelyInactive);

  final String? collectionTag;
  final void Function(bool) isDefinitelyInactive;

  @override
  Widget build(BuildContext context) {
    final explorer = Get.find<ExploreController>();
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
    changes[Filterable.SORT] = filterable.getFilterWithKey(Filterable.SORT);
    changes[Filterable.ON_LIST] =
        filterable.getFilterWithKey(Filterable.ON_LIST);
    changes[Filterable.COUNTRY] =
        filterable.getFilterWithKey(Filterable.COUNTRY);
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

    // Collection has to manually be forced to sort itself.
    changes[COLLECTION_SHOUD_SORT_KEY] = false;

    // Countries.
    final countries = <String, String?>{'All': null};
    for (final e in Convert.COUNTRY_CODES.entries) countries[e.value] = e.key;

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
            tooltip: 'Sort',
            icon: Ionicons.filter_outline,
            onTap: () => DragSheet.show(
              context,
              DragSheet(
                itemExtent: 35,
                children: collectionTag != null
                    ? _collectionSortOptions(changes)
                    : _exploreSortOptions(changes),
                ctx: context,
              ),
            ),
          ),
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

              if (filterable is ExploreController) filterable.fetch();
              if (filterable is CollectionController) {
                if (changes[COLLECTION_SHOUD_SORT_KEY])
                  filterable.sort();
                else
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
              value: changes[Filterable.ON_LIST],
              items: {
                'All': null,
                'In My List': true,
                'Not In My List': false,
              },
              onChanged: (val) => changes[Filterable.ON_LIST] = val,
            ),
          const SizedBox(height: 10),
          DropDownField(
            title: 'Country',
            value: changes[Filterable.COUNTRY],
            items: countries,
            onChanged: (val) => changes[Filterable.COUNTRY] = val,
          ),
          const SizedBox(height: 10),
          ChipGrid(
            title: 'Status',
            placeholder: 'statuses',
            names: changes[Filterable.STATUS_IN],
            edit: (names, onDone) => Sheet.show(
              ctx: context,
              sheet: SelectionSheet(
                options: statusOptions,
                values: statusValues,
                names: names,
                fixHeight: statusOptions.length <= 10,
                onDone: onDone,
              ),
              isScrollControlled: statusOptions.length <= 10,
            ),
          ),
          ChipGrid(
            title: 'Format',
            placeholder: 'formats',
            names: changes[Filterable.FORMAT_IN],
            edit: (names, onDone) => Sheet.show(
              ctx: context,
              sheet: SelectionSheet(
                options: formatOptions,
                values: formatValues,
                names: names,
                fixHeight: formatOptions.length <= 10,
                onDone: onDone,
              ),
              isScrollControlled: formatOptions.length <= 10,
            ),
          ),
          ChipToggleGrid(
            title: 'Genres',
            placeholder: 'genres',
            inclusive: changes[Filterable.GENRE_IN],
            exclusive: changes[Filterable.GENRE_NOT_IN],
            edit: (inclusive, exclusive, onDone) => Sheet.show(
              ctx: context,
              sheet: SelectionToggleSheet(
                options: explorer.genres,
                values: explorer.genres,
                inclusive: inclusive,
                exclusive: exclusive,
                fixHeight: explorer.genres.length <= 10,
                onDone: onDone,
              ),
              isScrollControlled: false,
            ),
          ),
          if (collectionTag == null)
            ChipToggleGrid(
              title: 'Tags',
              placeholder: 'tags',
              inclusive: changes[Filterable.TAG_IN],
              exclusive: changes[Filterable.TAG_NOT_IN],
              edit: (inclusive, exclusive, onDone) => Sheet.show(
                ctx: context,
                sheet: TagSelectionSheet(
                  tags: explorer.tags,
                  inclusive: inclusive,
                  exclusive: exclusive,
                  onDone: onDone,
                ),
                isScrollControlled: false,
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _collectionSortOptions(Map<String, dynamic> changes) =>
      EntrySort.values
          .map((v) => DragSheetListTile(
              text: Convert.clarifyEnum(describeEnum(v))!,
              onTap: () {
                changes[Filterable.SORT] = v;
                changes[COLLECTION_SHOUD_SORT_KEY] = true;
              },
              selected: v == changes[Filterable.SORT]))
          .toList();

  List<Widget> _exploreSortOptions(Map<String, dynamic> changes) => MediaSort
      .values
      .map((v) => DragSheetListTile(
          text: Convert.clarifyEnum(describeEnum(v))!,
          onTap: () => changes[Filterable.SORT] = describeEnum(v),
          selected: describeEnum(v) == changes[Filterable.SORT]))
      .toList();
}
