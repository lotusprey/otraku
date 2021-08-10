import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/controllers/explorer_controller.dart';
import 'package:otraku/enums/explorable.dart';
import 'package:otraku/enums/media_sort.dart';
import 'package:otraku/enums/themes.dart';
import 'package:otraku/routing/navigation.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/filterable.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class SliverCollectionAppBar extends StatelessWidget {
  final String tag;
  SliverCollectionAppBar(this.tag);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CollectionController>(
      tag: tag,
      builder: (collection) {
        if (collection.isFullyEmpty) return const SliverToBoxAdapter();

        return SliverTransparentAppBar(
          [
            Obx(
              () => MediaSearchField(
                scrollToTop: () => collection.scrollTo(0),
                swipe: (offset) => collection.listIndex += offset,
                hint: collection.currentName,
                searchValue:
                    collection.getFilterWithKey(Filterable.SEARCH) ?? '',
                search: (val) => collection.setFilterWithKey(
                  Filterable.SEARCH,
                  value: val,
                  update: true,
                ),
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        collection.currentName,
                        style: Theme.of(context).textTheme.headline2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      ' ${collection.currentCount}',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ],
                ),
              ),
            ),
            AppBarIcon(
              tooltip: 'Sort',
              icon: Ionicons.filter_outline,
              onTap: () => Sheet.show(
                ctx: context,
                sheet: CollectionSortSheet(tag),
                isScrollControlled: true,
              ),
            ),
            _FilterIcon(tag),
          ],
        );
      },
    );
  }
}

class SliverExploreAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final explorer = Get.find<ExplorerController>();
    return Obx(
      () => SliverTransparentAppBar(
        [
          MediaSearchField(
            scrollToTop: () => explorer.scrollTo(0),
            swipe: (offset) {
              final index = explorer.type.index + offset;
              if (index >= 0 && index < Explorable.values.length)
                explorer.type = Explorable.values[index];
            },
            hint: Convert.clarifyEnum(describeEnum(explorer.type))!,
            searchValue: explorer.search,
            search: explorer.type != Explorable.review
                ? (val) => explorer.search = val
                : null,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(explorer.type.icon, color: Theme.of(context).dividerColor),
                const SizedBox(width: 15),
                Flexible(
                  child: Text(
                    Convert.clarifyEnum(describeEnum(explorer.type))!,
                    style: Theme.of(context).textTheme.headline2,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          if (explorer.type == Explorable.anime ||
              explorer.type == Explorable.manga) ...[
            AppBarIcon(
              tooltip: 'Sort',
              icon: Ionicons.filter_outline,
              onTap: () => Sheet.show(
                ctx: context,
                sheet: MediaSortSheet(
                  Convert.strToEnum(
                    Get.find<ExplorerController>()
                        .getFilterWithKey(Filterable.SORT),
                    MediaSort.values,
                  )!,
                  (sort) => Get.find<ExplorerController>().setFilterWithKey(
                    Filterable.SORT,
                    value: describeEnum(sort),
                    update: true,
                  ),
                ),
                isScrollControlled: true,
              ),
            ),
            _FilterIcon(null),
          ],
        ],
      ),
    );
  }
}

class MediaSearchField extends StatefulWidget {
  final Function() scrollToTop;
  final Function(int) swipe;
  final Widget title;
  final String hint;
  final String searchValue;
  final Function(String)? search;

  MediaSearchField({
    required this.scrollToTop,
    required this.swipe,
    required this.title,
    required this.hint,
    required this.searchValue,
    required this.search,
  });

  @override
  _MediaSearchFieldState createState() => _MediaSearchFieldState();
}

class _MediaSearchFieldState extends State<MediaSearchField> {
  late bool _empty;
  late bool _onSearch;
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.searchValue);
    _onSearch = widget.search != null && widget.searchValue != '';
    _empty = _ctrl.text.isEmpty;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DragStartDetails? dragStart;
    DragUpdateDetails? dragUpdate;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!_onSearch) ...[
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.scrollToTop,
                  onHorizontalDragStart: (details) => dragStart = details,
                  onHorizontalDragUpdate: (details) => dragUpdate = details,
                  onHorizontalDragEnd: (_) {
                    if (dragUpdate == null || dragStart == null) return;
                    if (dragUpdate!.globalPosition.dx <
                        dragStart!.globalPosition.dx)
                      widget.swipe(1);
                    else
                      widget.swipe(-1);
                  },
                  child: widget.title,
                ),
              ),
              if (widget.search != null)
                AppBarIcon(
                  tooltip: 'Search',
                  icon: Ionicons.search_outline,
                  onTap: () => setState(() => _onSearch = true),
                ),
            ] else
              Expanded(
                child: Container(
                  height: 35,
                  padding: const EdgeInsets.only(right: 10),
                  child: TextField(
                    controller: _ctrl,
                    autofocus: true,
                    scrollPhysics: Config.PHYSICS,
                    cursorColor: Theme.of(context).accentColor,
                    style: Theme.of(context).textTheme.headline6,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(30),
                    ],
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(left: 10),
                      hintText: widget.hint,
                      suffixIcon: _empty
                          ? IconButton(
                              tooltip: 'Hide',
                              constraints: const BoxConstraints(maxWidth: 40),
                              padding: const EdgeInsets.all(0),
                              icon:
                                  const Icon(Ionicons.chevron_forward_outline),
                              iconSize: Style.ICON_SMALL,
                              color: Theme.of(context).disabledColor,
                              onPressed: () =>
                                  setState(() => _onSearch = false),
                            )
                          : IconButton(
                              tooltip: 'Clear',
                              constraints: const BoxConstraints(maxWidth: 40),
                              padding: const EdgeInsets.all(0),
                              icon: const Icon(Icons.close_rounded),
                              iconSize: Style.ICON_SMALL,
                              color: Theme.of(context).disabledColor,
                              onPressed: () {
                                _ctrl.clear();
                                _update('');
                              },
                            ),
                    ),
                    onChanged: (text) => _update(text),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _update(String text) {
    widget.search!(text);
    if (_empty != text.isEmpty) setState(() => _empty = text.isEmpty);
  }
}

class _FilterIcon extends StatefulWidget {
  final String? collectionTag;

  _FilterIcon(this.collectionTag);

  @override
  _FilterIconState createState() => _FilterIconState();
}

class _FilterIconState extends State<_FilterIcon> {
  late Filterable _filterable;
  late bool _active;

  @override
  void initState() {
    super.initState();
    if (widget.collectionTag != null)
      _filterable = Get.find<CollectionController>(tag: widget.collectionTag);
    else
      _filterable = Get.find<ExplorerController>();
    _active = _checkIfActive();
  }

  @override
  void didUpdateWidget(covariant _FilterIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    _active = _checkIfActive();
  }

  @override
  Widget build(BuildContext context) => AppBarIcon(
        tooltip: 'Filter',
        icon: Ionicons.funnel_outline,
        onTap: () => Navigation.it.push(
          Navigation.filtersRoute,
          args: [
            widget.collectionTag,
            (bool definitelyInactive) => definitelyInactive
                ? setState(() => _active = false)
                : setState(() => _active = _checkIfActive()),
          ],
        ),
        colour: _active ? Theme.of(context).accentColor : null,
      );

  bool _checkIfActive() => _filterable.anyActiveFilterFrom([
        Filterable.STATUS_IN,
        Filterable.FORMAT_IN,
        Filterable.GENRE_IN,
        Filterable.GENRE_NOT_IN,
        Filterable.TAG_IN,
        Filterable.TAG_NOT_IN,
        Filterable.ON_LIST,
      ]);
}
