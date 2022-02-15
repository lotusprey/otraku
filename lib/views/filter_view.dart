import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/constants/entry_sort.dart';
import 'package:otraku/constants/anime_format.dart';
import 'package:otraku/constants/media_sort.dart';
import 'package:otraku/controllers/tag_group_controller.dart';
import 'package:otraku/models/filter_model.dart';
import 'package:otraku/models/tag_group_model.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/constants/manga_format.dart';
import 'package:otraku/constants/media_status.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/widgets/fields/checkbox_field.dart';
import 'package:otraku/widgets/fields/chip_fields.dart';
import 'package:otraku/widgets/fields/drop_down_field.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/layouts/chip_grids.dart';
import 'package:otraku/widgets/overlays/gradient_sheets.dart';
import 'package:otraku/widgets/overlays/opaque_sheets.dart';

class FilterView extends StatelessWidget {
  FilterView(this.model);

  final FilterModel model;

  @override
  Widget build(BuildContext context) {
    final copy = model.copy();

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
    final formatEnum = model.ofAnime ? AnimeFormat.values : MangaFormat.values;
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
              Navigator.pop(context);
            },
          ),
          AppBarIcon(
            tooltip: 'Apply',
            icon: Icons.done_rounded,
            onTap: () {
              model.assign(copy);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: ListView(
        physics: Consts.PHYSICS,
        padding: Consts.PADDING,
        children: [
          if (copy.ofCollection)
            _CollectionSorting(copy.collectionFilter!)
          else
            _ExploreSorting(copy.exploreFilter!),
          _DropDownRow(copy),
          ChipGrid(
            title: 'Status',
            placeholder: 'statuses',
            names: copy.ofCollection
                ? copy.collectionFilter!.statuses
                : copy.exploreFilter!.statuses,
            onEdit: (selected) => showDragSheet(
              context,
              SelectionOpaqueSheet(
                options: statusOptions,
                values: statusValues,
                selected: selected,
              ),
            ),
          ),
          ChipGrid(
            title: 'Format',
            placeholder: 'formats',
            names: copy.ofCollection
                ? copy.collectionFilter!.formats
                : copy.exploreFilter!.formats,
            onEdit: (selected) => showDragSheet(
              context,
              SelectionOpaqueSheet(
                options: formatOptions,
                values: formatValues,
                selected: selected,
              ),
            ),
          ),
          GetBuilder<TagGroupController>(
            builder: (ctrl) {
              if (ctrl.model == null)
                const SizedBox(height: 30, child: Loader());

              return ChipTagGrid(
                title: 'Tags',
                placeholder: 'tags',
                inclusiveGenres: copy.ofCollection
                    ? copy.collectionFilter!.genreIn
                    : copy.exploreFilter!.genreIn,
                exclusiveGenres: copy.ofCollection
                    ? copy.collectionFilter!.genreNotIn
                    : copy.exploreFilter!.genreNotIn,
                inclusiveTags: copy.ofCollection
                    ? copy.collectionFilter!.tagIn
                    : copy.exploreFilter!.tagIn,
                exclusiveTags: copy.ofCollection
                    ? copy.collectionFilter!.tagNotIn
                    : copy.exploreFilter!.tagNotIn,
              );
            },
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
          if (model.ofCollection) ...[
            Expanded(
              child: DropDownField<String?>(
                title: 'Country',
                value: model.collectionFilter!.country,
                items: countries,
                onChanged: (val) => model.collectionFilter!.country = val,
              ),
            ),
            const Spacer(),
          ] else ...[
            Expanded(
              child: DropDownField<String?>(
                title: 'Country',
                value: model.exploreFilter!.country,
                items: countries,
                onChanged: (val) => model.exploreFilter!.country = val,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropDownField<bool?>(
                title: 'List Filter',
                value: model.exploreFilter!.onList,
                items: const {
                  'Everything': null,
                  'On List': true,
                  'Not On List': false,
                },
                onChanged: (val) => model.exploreFilter!.onList = val,
              ),
            )
          ],
        ],
      ),
    );
  }
}

class TagSheetBody extends StatefulWidget {
  TagSheetBody({
    required this.inclusiveGenres,
    required this.exclusiveGenres,
    required this.inclusiveTags,
    required this.exclusiveTags,
    required this.scrollCtrl,
  });

  final List<String> inclusiveGenres;
  final List<String> exclusiveGenres;
  final List<String> inclusiveTags;
  final List<String> exclusiveTags;
  final ScrollController scrollCtrl;

  @override
  _TagSheetBodyState createState() => _TagSheetBodyState();
}

class _TagSheetBodyState extends State<TagSheetBody> {
  late final TagGroupModel _tags;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _tags = Get.find<TagGroupController>().model!;
  }

  @override
  Widget build(BuildContext context) {
    final listItems = _tags.categoryItems[_index];
    late final List<String> inclusive;
    late final List<String> exclusive;
    if (_index > 0) {
      inclusive = widget.inclusiveTags;
      exclusive = widget.exclusiveTags;
    } else {
      inclusive = widget.inclusiveGenres;
      exclusive = widget.exclusiveGenres;
    }

    return Stack(
      children: [
        ListView.builder(
          physics: Consts.PHYSICS,
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 10,
            top: 60,
          ),
          controller: widget.scrollCtrl,
          itemExtent: Consts.MATERIAL_TAP_TARGET_SIZE,
          itemCount: listItems.length,
          itemBuilder: (_, i) {
            final name = _tags.names[listItems[i]];
            return CheckBoxTriField(
              key: UniqueKey(),
              title: name,
              initial: inclusive.contains(name)
                  ? 1
                  : exclusive.contains(name)
                      ? -1
                      : 0,
              onChanged: (state) {
                if (state == 0)
                  exclusive.remove(name);
                else if (state == 1)
                  inclusive.add(name);
                else {
                  inclusive.remove(name);
                  exclusive.add(name);
                }
              },
            );
          },
        ),
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Consts.RADIUS_MAX),
          child: BackdropFilter(
            filter: Consts.filter,
            child: Container(
              height: 60,
              color: Theme.of(context).cardColor,
              child: ListView.builder(
                physics: Consts.PHYSICS,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                scrollDirection: Axis.horizontal,
                itemCount: _tags.categoryNames.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ChipOptionField(
                    name: _tags.categoryNames[i],
                    selected: i == _index,
                    onTap: () => setState(() => _index = i),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
