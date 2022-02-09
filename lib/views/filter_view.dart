import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/constants/entry_sort.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/constants/anime_format.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/constants/media_sort.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/constants/manga_format.dart';
import 'package:otraku/constants/media_status.dart';
import 'package:otraku/controllers/explore_controller.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/utils/filterable.dart';
import 'package:otraku/widgets/fields/drop_down_field.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/layouts/chip_grids.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class FiltersView extends StatelessWidget {
  FiltersView(this.collectionTag, this.isDefinitelyInactive);

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

    if (collectionTag == null)
      changes[Filterable.SORT] = filterable.getFilterWithKey(Filterable.SORT);

    // Statuses.
    final statusOptions = <String>[];
    final statusValues = <String>[];
    for (final v in MediaStatus.values) {
      statusValues.add(v.name);
      statusOptions.add(Convert.clarifyEnum(statusValues.last)!);
    }

    // Formats.
    final formatOptions = <String>[];
    final formatValues = <String>[];
    final iterable = explorable == Explorable.anime
        ? AnimeFormat.values
        : MangaFormat.values;
    for (final v in iterable) {
      formatValues.add(v.name);
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
              isDefinitelyInactive(false);
              Navigator.pop(context);

              if (changes.isEmpty) return;

              for (int i = 0; i < changes.length - 1; i++) {
                final key = changes.keys.elementAt(i);
                filterable.setFilterWithKey(key, value: changes[key]);
              }

              filterable.setFilterWithKey(
                changes.keys.last,
                value: changes[changes.keys.last],
                update: true,
              );
            },
          ),
        ],
      ),
      body: ListView(
        physics: Consts.PHYSICS,
        padding: Consts.PADDING,
        children: [
          if (collectionTag == null)
            _ExploreSorting(changes)
          else
            _CollectionSorting(collectionTag!),
          _DropDownRow(changes, collectionTag == null),
          ChipGrid(
            title: 'Status',
            placeholder: 'statuses',
            names: changes[Filterable.STATUS_IN],
            onEdit: (selected) => Sheet.show(
              ctx: context,
              isScrollControlled: statusOptions.length <= 10,
              sheet: SelectionSheet(
                options: statusOptions,
                values: statusValues,
                selected: selected,
                fixHeight: statusOptions.length <= 10,
              ),
            ),
          ),
          ChipGrid(
            title: 'Format',
            placeholder: 'formats',
            names: changes[Filterable.FORMAT_IN],
            onEdit: (selected) => Sheet.show(
              ctx: context,
              isScrollControlled: formatOptions.length <= 10,
              sheet: SelectionSheet(
                options: formatOptions,
                values: formatValues,
                selected: selected,
                fixHeight: formatOptions.length <= 10,
              ),
            ),
          ),
          ChipToggleGrid(
            title: 'Genres',
            placeholder: 'genres',
            inclusive: changes[Filterable.GENRE_IN],
            exclusive: changes[Filterable.GENRE_NOT_IN],
            onEdit: (inclusive, exclusive) => Sheet.show(
              ctx: context,
              isScrollControlled: false,
              sheet: SelectionToggleSheet(
                options: explorer.genres,
                values: explorer.genres,
                inclusive: inclusive,
                exclusive: exclusive,
                fixHeight: explorer.genres.length <= 10,
              ),
            ),
          ),
          if (collectionTag == null)
            ChipToggleGrid(
              title: 'Tags',
              placeholder: 'tags',
              inclusive: changes[Filterable.TAG_IN],
              exclusive: changes[Filterable.TAG_NOT_IN],
              onEdit: (inclusive, exclusive) => Sheet.show(
                ctx: context,
                isScrollControlled: false,
                sheet: TagSelectionSheet(
                  tags: explorer.tags,
                  inclusive: inclusive,
                  exclusive: exclusive,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CollectionSorting extends StatefulWidget {
  const _CollectionSorting(this.ctrlTag);

  final String ctrlTag;

  @override
  __CollectionSortingState createState() => __CollectionSortingState();
}

class __CollectionSortingState extends State<_CollectionSorting> {
  final _sortItems = <String, int>{};
  late CollectionController _ctrl;
  late EntrySort _sort;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<CollectionController>(tag: widget.ctrlTag);
    _sort = _ctrl.getFilterWithKey(Filterable.SORT);
    for (int i = 0; i < EntrySort.values.length; i += 2) {
      String key = Convert.clarifyEnum(EntrySort.values[i].name)!;
      _sortItems[key] = i ~/ 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: DropDownField<int>(
              title: 'Sort',
              value: _sort.index ~/ 2,
              items: _sortItems,
              onChanged: (val) {
                int index = val * 2;
                if (_sort.index % 2 != 0) index++;

                _sort = EntrySort.values[index];
                _ctrl.setFilterWithKey(Filterable.SORT, value: _sort);
                _ctrl.sort();
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DropDownField<bool>(
              title: 'Order',
              value: _sort.index % 2 == 0,
              items: const {'Ascending': true, 'Descending': false},
              onChanged: (val) {
                int index = _sort.index;
                if (!val) index++;

                _sort = EntrySort.values[index];
                _ctrl.setFilterWithKey(Filterable.SORT, value: _sort);
                _ctrl.sort();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ExploreSorting extends StatefulWidget {
  const _ExploreSorting(this.changes);

  final Map<String, dynamic> changes;

  @override
  __ExploreSortingState createState() => __ExploreSortingState();
}

class __ExploreSortingState extends State<_ExploreSorting> {
  final _sortItems = <String, int>{};
  late MediaSort _sort;

  @override
  void initState() {
    super.initState();
    _sort = MediaSort.values.byName(widget.changes[Filterable.SORT]);
    for (int i = 0; i < MediaSort.values.length; i += 2) {
      String key = Convert.clarifyEnum(MediaSort.values[i].name)!;
      _sortItems[key] = i ~/ 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: DropDownField<int>(
              title: 'Sort',
              value: _sort.index ~/ 2,
              items: _sortItems,
              onChanged: (val) {
                int index = val * 2;
                if (_sort.index % 2 != 0) index++;

                _sort = MediaSort.values[index];
                widget.changes[Filterable.SORT] = _sort.name;
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DropDownField<bool>(
              title: 'Order',
              value: _sort.index % 2 == 0,
              items: const {'Ascending': true, 'Descending': false},
              onChanged: (val) {
                int index = _sort.index;
                if (index % 2 == 0 && !val) index++;
                if (index % 2 != 0 && val) index--;

                _sort = MediaSort.values[index];
                widget.changes[Filterable.SORT] = _sort.name;
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DropDownRow extends StatelessWidget {
  const _DropDownRow(this.changes, this.withListFilter);

  final Map<String, dynamic> changes;
  final bool withListFilter;

  @override
  Widget build(BuildContext context) {
    // Countries.
    final countries = <String, String?>{'All': null};
    for (final e in Convert.COUNTRY_CODES.entries) countries[e.value] = e.key;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: DropDownField(
              title: 'Country',
              value: changes[Filterable.COUNTRY],
              items: countries,
              onChanged: (val) => changes[Filterable.COUNTRY] = val,
            ),
          ),
          const SizedBox(width: 10),
          if (withListFilter)
            Expanded(
              child: DropDownField(
                title: 'List Filter',
                value: changes[Filterable.ON_LIST],
                items: const {
                  'Everything': null,
                  'On List': true,
                  'Not On List': false,
                },
                onChanged: (val) => changes[Filterable.ON_LIST] = val,
              ),
            )
          else
            const Spacer(),
        ],
      ),
    );
  }
}
