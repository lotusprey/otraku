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
import 'package:otraku/widgets/fields/search_field.dart';
import 'package:otraku/widgets/grids/sliver_grid_delegates.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';
import 'package:otraku/widgets/grids/chip_grids.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

/// A sheet for collection/explore filtering. Should be opened with [showSheet].
class FilterView extends StatelessWidget {
  FilterView(this.model);

  final FilterModel model;

  @override
  Widget build(BuildContext context) {
    late final FilterModel copy;
    if (model is CollectionFilterModel)
      copy = CollectionFilterModel(model.ofAnime, null);
    else if (model is ExploreFilterModel)
      copy = ExploreFilterModel(model.ofAnime, null);
    copy.copy(model);

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

    return OpaqueSheetView(
      buttons: [
        OpaqueSheetViewButton(
          text: 'Clear',
          icon: Icons.close,
          warning: true,
          onTap: () {
            model.clear(true);
            Navigator.pop(context);
          },
        ),
        OpaqueSheetViewButton(
          text: 'Apply',
          icon: Icons.done_rounded,
          onTap: () {
            model.copy(copy);
            Navigator.pop(context);
          },
        ),
      ],
      builder: (context, scrollCtrl) => ListView(
        controller: scrollCtrl,
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
          top: 20,
          bottom: 60,
        ),
        children: [
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
              minWidth: 140,
              height: 75,
            ),
            children: [
              if (copy is CollectionFilterModel) ...[
                SortDropDown(
                  EntrySort.values,
                  () => copy.sort.index,
                  (EntrySort val) => copy.sort = val,
                ),
                OrderDropDown(
                  EntrySort.values,
                  () => copy.sort.index,
                  (EntrySort val) => copy.sort = val,
                )
              ] else if (copy is ExploreFilterModel) ...[
                SortDropDown(
                  MediaSort.values,
                  () => copy.sort.index,
                  (MediaSort val) => copy.sort = val,
                ),
                OrderDropDown(
                  MediaSort.values,
                  () => copy.sort.index,
                  (MediaSort val) => copy.sort = val,
                )
              ],
              CountryDropDown(copy.country, (val) => copy.country = val),
              if (copy is ExploreFilterModel)
                ListPresenceDropDown(
                  copy.onList,
                  (val) => (copy as ExploreFilterModel).onList = val,
                ),
            ],
          ),
          ChipGrid(
            title: 'Status',
            placeholder: 'statuses',
            names: copy.statuses,
            onEdit: (selected) => showSheet(
              context,
              _SelectionSheet(
                options: statusOptions,
                values: statusValues,
                selected: selected,
              ),
            ),
          ),
          ChipGrid(
            title: 'Format',
            placeholder: 'formats',
            names: copy.formats,
            onEdit: (selected) => showSheet(
              context,
              _SelectionSheet(
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
                inclusiveGenres: copy.genreIn,
                exclusiveGenres: copy.genreNotIn,
                inclusiveTags: copy.tagIn,
                exclusiveTags: copy.tagNotIn,
              );
            },
          ),
        ],
      ),
    );
  }
}

/// [DropDownField] implementations used for filtering.

class SortDropDown<T extends Enum> extends StatelessWidget {
  SortDropDown(this.values, this.index, this.onChange);

  final List<T> values;
  final int Function() index;
  final void Function(T) onChange;

  @override
  Widget build(BuildContext context) {
    final items = <String, int>{};
    for (int i = 0; i < values.length; i += 2) {
      String key = Convert.clarifyEnum(values[i].name)!;
      items[key] = i ~/ 2;
    }

    return DropDownField<int>(
      title: 'Sort',
      value: index() ~/ 2,
      items: items,
      onChanged: (val) {
        int i = val * 2;
        if (index() % 2 != 0) i++;
        onChange(values[i]);
      },
    );
  }
}

class OrderDropDown<T extends Enum> extends StatelessWidget {
  OrderDropDown(this.values, this.index, this.onChange);

  final List<T> values;
  final int Function() index;
  final void Function(T) onChange;

  @override
  Widget build(BuildContext context) {
    return DropDownField<bool>(
      title: 'Order',
      value: index() % 2 == 0,
      items: const {'Ascending': true, 'Descending': false},
      onChanged: (val) {
        int i = index();
        if (!val && i % 2 == 0) {
          i++;
        } else if (val && i % 2 != 0) {
          i--;
        }
        onChange(values[i]);
      },
    );
  }
}

class CountryDropDown extends StatelessWidget {
  CountryDropDown(this.value, this.onChange);

  final String? value;
  final void Function(String?) onChange;

  @override
  Widget build(BuildContext context) {
    final countries = <String, String?>{'All': null};
    for (final e in Convert.COUNTRY_CODES.entries) countries[e.value] = e.key;

    return DropDownField<String?>(
      title: 'Country',
      value: value,
      items: countries,
      onChanged: onChange,
    );
  }
}

class ListPresenceDropDown extends StatelessWidget {
  ListPresenceDropDown(this.value, this.onChange);

  final bool? value;
  final void Function(bool?) onChange;

  @override
  Widget build(BuildContext context) {
    return DropDownField<bool?>(
      title: 'List Filter',
      value: value,
      items: const {'Everything': null, 'On List': true, 'Not On List': false},
      onChanged: onChange,
    );
  }
}

class _SelectionSheet<T> extends StatelessWidget {
  _SelectionSheet({
    required this.options,
    required this.values,
    required this.selected,
  });

  final List<String> options;
  final List<T> values;
  final List<T> selected;

  @override
  Widget build(BuildContext context) {
    return OpaqueSheet(
      initialHeight: options.length * Consts.tapTargetSize + 20,
      builder: (context, scrollCtrl) => ListView.builder(
        controller: scrollCtrl,
        padding: Consts.padding,
        itemCount: options.length,
        itemExtent: Consts.tapTargetSize,
        itemBuilder: (_, index) => CheckBoxField(
          title: options[index],
          initial: selected.contains(values[index]),
          onChanged: (val) => val
              ? selected.add(values[index])
              : selected.remove(values[index]),
        ),
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
  late final List<int> _categoryIndices;
  late final List<int> _itemIndices;
  String _filter = '';
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _tags = Get.find<TagGroupController>().model!;
    _itemIndices = [..._tags.categoryItems[_index]];
    _categoryIndices = [];
    for (int i = 0; i < _tags.categoryNames.length; i++)
      _categoryIndices.add(i);
  }

  @override
  Widget build(BuildContext context) {
    late final List<String> inclusive;
    late final List<String> exclusive;
    if (_categoryIndices.isNotEmpty && _categoryIndices[_index] == 0) {
      inclusive = widget.inclusiveGenres;
      exclusive = widget.exclusiveGenres;
    } else {
      inclusive = widget.inclusiveTags;
      exclusive = widget.exclusiveTags;
    }

    return Stack(
      children: [
        if (_itemIndices.isNotEmpty)
          ListView.builder(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 10,
              top: 90,
            ),
            controller: widget.scrollCtrl,
            itemExtent: Consts.tapTargetSize,
            itemCount: _itemIndices.length,
            itemBuilder: (_, i) {
              final name = _tags.names[_itemIndices[i]];
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
          )
        else
          Center(
            child: Text(
              'No Results',
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Consts.radiusMax),
          child: BackdropFilter(
            filter: Consts.filter,
            child: Container(
              height: 95,
              color: Theme.of(context).cardColor,
              padding: const EdgeInsets.only(top: 10, bottom: 5),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 5,
                    ),
                    child: SearchField(
                      hint: 'Tag',
                      value: _filter,
                      onChange: (val) {
                        _filter = val.toLowerCase();
                        _categoryIndices.clear();
                        _itemIndices.clear();

                        categoryLoop:
                        for (int i = 0; i < _tags.categoryNames.length; i++)
                          for (final j in _tags.categoryItems[i])
                            if (_tags.names[j]
                                .toLowerCase()
                                .contains(_filter)) {
                              _categoryIndices.add(i);
                              continue categoryLoop;
                            }

                        if (_categoryIndices.isEmpty) {
                          _index = 0;
                          setState(() {});
                          return;
                        }

                        if (_index >= _categoryIndices.length)
                          _index = _categoryIndices.length - 1;

                        final itemsIndex = _categoryIndices[_index];
                        for (final i in _tags.categoryItems[itemsIndex])
                          if (_tags.names[i].toLowerCase().contains(_filter))
                            _itemIndices.add(i);

                        setState(() {});
                      },
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      scrollDirection: Axis.horizontal,
                      itemCount: _categoryIndices.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: ChipOptionField(
                          name: _tags.categoryNames[_categoryIndices[i]],
                          selected: i == _index,
                          onTap: () {
                            if (_index == i) return;

                            _index = i;
                            _itemIndices.clear();

                            final itemsIndex = _categoryIndices[_index];
                            for (final i in _tags.categoryItems[itemsIndex])
                              if (_tags.names[i]
                                  .toLowerCase()
                                  .contains(_filter)) _itemIndices.add(i);

                            setState(() {});
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
