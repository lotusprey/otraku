import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/constants/entry_sort.dart';
import 'package:otraku/constants/anime_format.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/constants/media_sort.dart';
import 'package:otraku/controllers/explore_controller.dart';
import 'package:otraku/models/filter_model.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/constants/manga_format.dart';
import 'package:otraku/constants/media_status.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/widgets/fields/drop_down_field.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/layouts/chip_grids.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class FiltersView extends StatelessWidget {
  FiltersView(this.model);

  final FilterModel model;

  @override
  Widget build(BuildContext context) {
    CollectionFilterModel? collectionFilters;
    ExploreFilterModel? exploreFilters;
    if (model is CollectionFilterModel)
      collectionFilters = (model as CollectionFilterModel).copy();
    if (model is ExploreFilterModel)
      exploreFilters = (model as ExploreFilterModel).copy();
    final FilterModel filters = collectionFilters ?? exploreFilters!;

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
    final formatEnum = model.type == Explorable.anime
        ? AnimeFormat.values
        : MangaFormat.values;
    for (final v in formatEnum) {
      formatValues.add(v.name);
      formatOptions.add(Convert.clarifyEnum(formatValues.last)!);
    }

    return Scaffold(
      appBar: ShadowAppBar(
        title: 'Filters',
        actions: [
          AppBarIcon(
            tooltip: 'Clear',
            icon: Icons.close,
            onTap: () {
              model.clear();
              model.refresh();
              Navigator.pop(context);
            },
          ),
          AppBarIcon(
            tooltip: 'Apply',
            icon: Icons.done_rounded,
            onTap: () {
              model.assign(
                filters,
                Get.find<ExploreController>().tagCollection,
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: ListView(
        physics: Consts.PHYSICS,
        padding: Consts.PADDING,
        children: [
          if (collectionFilters != null) _CollectionSorting(collectionFilters),
          if (exploreFilters != null) _ExploreSorting(exploreFilters),
          _DropDownRow(filters),
          ChipGrid(
            title: 'Status',
            placeholder: 'statuses',
            names: filters.statuses,
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
            names: filters.formats,
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
          ChipTagGrid(
            title: 'Tags',
            placeholder: 'tags',
            inclusiveGenres: filters.genreIn,
            exclusiveGenres: filters.genreNotIn,
            inclusiveTags: filters.tagIn,
            exclusiveTags: filters.tagNotIn,
          ),
        ],
      ),
    );
  }
}

class _CollectionSorting extends StatefulWidget {
  const _CollectionSorting(this.model);

  final CollectionFilterModel model;

  @override
  __CollectionSortingState createState() => __CollectionSortingState();
}

class __CollectionSortingState extends State<_CollectionSorting> {
  final _sortItems = <String, int>{};

  @override
  void initState() {
    super.initState();
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
              value: widget.model.sort.index ~/ 2,
              items: _sortItems,
              onChanged: (val) {
                int index = val * 2;
                if (widget.model.sort.index % 2 != 0) index++;
                widget.model.sort = EntrySort.values[index];
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DropDownField<bool>(
              title: 'Order',
              value: widget.model.sort.index % 2 == 0,
              items: const {'Ascending': true, 'Descending': false},
              onChanged: (val) {
                int index = widget.model.sort.index;
                if (!val) index++;
                widget.model.sort = EntrySort.values[index];
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ExploreSorting extends StatefulWidget {
  const _ExploreSorting(this.model);

  final ExploreFilterModel model;

  @override
  __ExploreSortingState createState() => __ExploreSortingState();
}

class __ExploreSortingState extends State<_ExploreSorting> {
  final _sortItems = <String, int>{};
  late MediaSort _sort;

  @override
  void initState() {
    super.initState();
    _sort = MediaSort.values.byName(widget.model.sort);
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
                widget.model.sort = _sort.name;
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
                widget.model.sort = _sort.name;
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DropDownRow extends StatelessWidget {
  const _DropDownRow(this.model);

  final FilterModel model;

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
            child: DropDownField<String?>(
              title: 'Country',
              value: model.country,
              items: countries,
              onChanged: (val) => model.country = val,
            ),
          ),
          if (model is ExploreFilterModel) ...[
            const SizedBox(width: 10),
            Expanded(
              child: DropDownField<bool?>(
                title: 'List Filter',
                value: (model as ExploreFilterModel).onList,
                items: const {
                  'Everything': null,
                  'On List': true,
                  'Not On List': false,
                },
                onChanged: (val) => (model as ExploreFilterModel).onList = val,
              ),
            ),
          ] else
            const Spacer(),
        ],
      ),
    );
  }
}
