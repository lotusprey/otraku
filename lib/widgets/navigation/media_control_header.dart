import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/collection.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/controllers/explorer.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/enums/media_sort.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/filterable.dart';
import 'package:otraku/pages/pushable/filter_page.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class MediaControlHeader extends StatelessWidget {
  final String? collectionTag;

  const MediaControlHeader([this.collectionTag]);

  @override
  Widget build(BuildContext context) {
    if (collectionTag == null)
      return SliverPersistentHeader(
        pinned: true,
        delegate: _ControlHeaderDelegate(null),
      );

    return Obx(() {
      final collection = Get.find<Collection>(tag: collectionTag);
      if (collection.isLoading || collection.isFullyEmpty)
        return const SliverToBoxAdapter();

      return SliverPersistentHeader(
        pinned: true,
        delegate: _ControlHeaderDelegate(collectionTag),
      );
    });
  }
}

class _ControlHeaderDelegate implements SliverPersistentHeaderDelegate {
  static const _height = 58.0;

  final String? collectionTag;

  _ControlHeaderDelegate(this.collectionTag);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ClipRect(
      child: BackdropFilter(
        filter: Config.filter,
        child: Container(
          height: _height,
          color: Theme.of(context).cardColor,
          padding: const EdgeInsets.only(right: 10),
          child: Row(
            children: [
              IconButton(
                tooltip: collectionTag == null ? 'Types' : 'Lists',
                padding: const EdgeInsets.only(right: 10),
                icon: const Icon(FluentIcons.list_24_regular),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
              if (collectionTag != null)
                Obx(() {
                  final collection = Get.find<Collection>(tag: collectionTag);
                  return _Navigation(
                    scrollToTop: () => collection.scrollTo(0),
                    swipe: (int offset) => collection.listIndex += offset,
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            collection.currentName!,
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
                    hint: collection.currentName,
                    searchValue: collection.getFilterWithKey(Filterable.SEARCH),
                    search: (search) => collection.setFilterWithKey(
                      Filterable.SEARCH,
                      value: search,
                      update: true,
                    ),
                  );
                })
              else
                Obx(() {
                  final explorer = Get.find<Explorer>();
                  return _Navigation(
                    scrollToTop: () => explorer.scrollTo(0),
                    swipe: (int offset) {
                      final index = explorer.type.index + offset;
                      if (index >= 0 && index < Browsable.values.length)
                        explorer.type = Browsable.values[index];
                    },
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          explorer.type.icon,
                          color: Theme.of(context).dividerColor,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            Convert.clarifyEnum(describeEnum(explorer.type))!,
                            style: Theme.of(context).textTheme.headline2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    hint: Convert.clarifyEnum(describeEnum(explorer.type)),
                    searchValue: explorer.search,
                    search: explorer.type != Browsable.review
                        ? (search) => explorer.search = search
                        : null,
                  );
                }),
              if (collectionTag == null) ...[
                Obx(() {
                  final type = Get.find<Explorer>().type;
                  if (type == Browsable.anime || type == Browsable.manga)
                    return IconButton(
                      tooltip: 'Sort',
                      icon: const Icon(FluentIcons.arrow_sort_24_regular),
                      onPressed: () => Sheet.show(
                        ctx: context,
                        sheet: MediaSortSheet(
                          Convert.stringToEnum(
                            Get.find<Explorer>()
                                .getFilterWithKey(Filterable.SORT),
                            MediaSort.values,
                          ),
                          (sort) => Get.find<Explorer>().setFilterWithKey(
                            Filterable.SORT,
                            value: describeEnum(sort),
                            update: true,
                          ),
                        ),
                        isScrollControlled: true,
                      ),
                    );
                  return const SizedBox();
                }),
                Obx(() {
                  final type = Get.find<Explorer>().type;
                  if (type == Browsable.anime || type == Browsable.manga)
                    return _Filter(collectionTag);
                  return const SizedBox();
                }),
              ] else ...[
                IconButton(
                  tooltip: 'Sort',
                  icon: const Icon(FluentIcons.arrow_sort_24_regular),
                  onPressed: () => Sheet.show(
                    ctx: context,
                    sheet: CollectionSortSheet(collectionTag),
                    isScrollControlled: true,
                  ),
                ),
                _Filter(collectionTag),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => _height;

  @override
  double get minExtent => _height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;

  @override
  FloatingHeaderSnapConfiguration? get snapConfiguration => null;

  @override
  OverScrollHeaderStretchConfiguration? get stretchConfiguration => null;

  @override
  PersistentHeaderShowOnScreenConfiguration? get showOnScreenConfiguration =>
      null;

  @override
  TickerProvider? get vsync => null;
}

class _Navigation extends StatefulWidget {
  final Function scrollToTop;
  final Function(int) swipe;
  final Widget title;
  final String? hint;
  final String? searchValue;
  final Function(String)? search;

  _Navigation({
    required this.scrollToTop,
    required this.swipe,
    required this.title,
    required this.hint,
    required this.searchValue,
    required this.search,
  });

  @override
  __NavigationState createState() => __NavigationState();
}

class __NavigationState extends State<_Navigation> {
  late bool _empty;
  late bool _searchMode;
  TextEditingController? _ctrl;
  FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchMode = widget.searchValue != null && widget.searchValue != '';
    _ctrl = TextEditingController(text: widget.searchValue ?? '');
    _empty = _ctrl!.text.isEmpty;
  }

  @override
  void dispose() {
    _focus.dispose();
    _ctrl!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DragStartDetails? dragStart;
    DragUpdateDetails? dragUpdate;

    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!_searchMode || widget.search == null) ...[
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.scrollToTop as void Function()?,
                onHorizontalDragStart: (details) => dragStart = details,
                onHorizontalDragUpdate: (details) => dragUpdate = details,
                onHorizontalDragEnd: (_) {
                  if (dragUpdate == null || dragStart == null) return;
                  if (dragUpdate!.globalPosition.dx <
                      dragStart!.globalPosition.dx) {
                    widget.swipe(1);
                  } else {
                    widget.swipe(-1);
                  }
                },
                child: widget.title,
              ),
            ),
            if (widget.search != null)
              IconButton(
                tooltip: 'Search',
                icon: const Icon(FluentIcons.search_24_regular),
                onPressed: () => setState(() => _searchMode = true),
              ),
          ] else
            Expanded(
              child: SizedBox(
                height: 35,
                child: TextField(
                  controller: _ctrl,
                  focusNode: _focus,
                  autofocus: true,
                  cursorColor: Theme.of(context).accentColor,
                  style: Theme.of(context).textTheme.headline6,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(30),
                  ],
                  textAlignVertical: TextAlignVertical.bottom,
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    suffixIcon: _empty
                        ? IconButton(
                            tooltip: 'Hide',
                            padding: const EdgeInsets.all(0),
                            icon:
                                const Icon(FluentIcons.chevron_right_24_filled),
                            color: Theme.of(context).disabledColor,
                            onPressed: () {
                              _focus.canRequestFocus = false;
                              widget.search!('');
                              setState(() => _searchMode = false);
                            },
                          )
                        : IconButton(
                            tooltip: 'Clear',
                            padding: const EdgeInsets.all(0),
                            icon: const Icon(Icons.close),
                            color: Theme.of(context).disabledColor,
                            onPressed: () {
                              _ctrl!.clear();
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
    );
  }

  void _update(String text) {
    widget.search!(text);
    if (text.length > 0) {
      if (_empty) setState(() => _empty = false);
    } else {
      if (!_empty) setState(() => _empty = true);
    }
  }
}

class _Filter extends StatefulWidget {
  final String? collectionTag;

  _Filter(this.collectionTag);

  @override
  __FilterState createState() => __FilterState();
}

class __FilterState extends State<_Filter> {
  late Filterable _filterable;
  late bool _active;

  @override
  void initState() {
    super.initState();
    if (widget.collectionTag != null)
      _filterable = Get.find<Collection>(tag: widget.collectionTag);
    else
      _filterable = Get.find<Explorer>();
    _active = _checkIfActive();
  }

  @override
  void didUpdateWidget(covariant _Filter oldWidget) {
    super.didUpdateWidget(oldWidget);
    _active = _checkIfActive();
  }

  @override
  Widget build(BuildContext context) {
    if (!_active)
      return IconButton(
        tooltip: 'Filter',
        icon: const Icon(Icons.filter_alt_outlined),
        onPressed: () => _pushPage(context),
      );

    return Tooltip(
      message: 'Filter',
      child: GestureDetector(
        onTap: () => _pushPage(context),
        onLongPress: () {
          _filterable.clearAllFilters();
          setState(() => _active = false);
        },
        child: Container(
          width: Config.MATERIAL_TAP_TARGET_SIZE,
          decoration: BoxDecoration(
            color: Theme.of(context).accentColor,
            borderRadius: Config.BORDER_RADIUS,
          ),
          child: Icon(
            Icons.filter_alt_outlined,
            color: Theme.of(context).backgroundColor,
          ),
        ),
      ),
    );
  }

  void _pushPage(BuildContext context) =>
      Get.toNamed(FilterPage.ROUTE, arguments: [
        widget.collectionTag,
        (definitelyInactive) => definitelyInactive
            ? setState(() => _active = false)
            : setState(() => _active = _checkIfActive()),
      ]);

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
