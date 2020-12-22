import 'dart:ui';

import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/collection.dart';
import 'package:otraku/services/config.dart';
import 'package:otraku/controllers/explorer.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/enums/theme_enum.dart';
import 'package:otraku/services/filterable.dart';
import 'package:otraku/pages/pushable/filter_page.dart';

class CollectionControlHeader extends StatelessWidget {
  final ScrollController ctrl;
  final String collectionTag;

  const CollectionControlHeader(this.ctrl, this.collectionTag);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (Get.find<Collection>(tag: collectionTag).names.isEmpty)
        return const SliverToBoxAdapter();

      return SliverPersistentHeader(
        pinned: true,
        delegate: _ControlHeaderDelegate(
          collectionTag: collectionTag,
          ctrl: ctrl,
        ),
      );
    });
  }
}

class ExploreControlHeader extends StatelessWidget {
  final ScrollController ctrl;

  const ExploreControlHeader(this.ctrl);

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _ControlHeaderDelegate(
        collectionTag: null,
        ctrl: ctrl,
      ),
    );
  }
}

class _ControlHeaderDelegate implements SliverPersistentHeaderDelegate {
  static const _height = 58.0;

  final String collectionTag;
  final ScrollController ctrl;

  _ControlHeaderDelegate({
    @required this.collectionTag,
    @required this.ctrl,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: _height,
          width: double.infinity,
          color: Theme.of(context).cardColor,
          padding: const EdgeInsets.only(right: 10),
          child: Row(
            children: [
              IconButton(
                padding: const EdgeInsets.only(right: 10),
                icon: const Icon(FluentSystemIcons.ic_fluent_list_regular),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
              if (collectionTag != null)
                Obx(() {
                  final collection = Get.find<Collection>(tag: collectionTag);
                  if (collection.names.isEmpty)
                    return const Expanded(child: SizedBox());

                  return _Navigation(
                    ctrl: ctrl,
                    swipe: (int offset) => collection.listIndex += offset,
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
                          style: Theme.of(context).textTheme.headline4,
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
                  final explorable = Get.find<Explorer>();
                  return _Navigation(
                    ctrl: ctrl,
                    swipe: (int offset) {
                      final index = explorable.type.index + offset;
                      if (index >= 0 && index < Browsable.values.length)
                        explorable.type = Browsable.values[index];
                    },
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          explorable.type.icon,
                          color: Theme.of(context).accentColor,
                          size: Styles.ICON_SMALL,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            clarifyEnum(describeEnum(explorable.type)),
                            style: Theme.of(context).textTheme.headline2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    hint: clarifyEnum(describeEnum(explorable.type)),
                    searchValue: explorable.search,
                    search: (search) => explorable.search = search,
                  );
                }),
              if (collectionTag == null)
                Obx(() {
                  final type = Get.find<Explorer>().type;
                  if (type == Browsable.anime || type == Browsable.manga)
                    return _Filter(collectionTag);
                  return const SizedBox();
                })
              else
                _Filter(collectionTag),
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
  FloatingHeaderSnapConfiguration get snapConfiguration => null;

  @override
  OverScrollHeaderStretchConfiguration get stretchConfiguration => null;

  @override
  PersistentHeaderShowOnScreenConfiguration get showOnScreenConfiguration =>
      null;

  @override
  TickerProvider get vsync => null;
}

class _Navigation extends StatefulWidget {
  final ScrollController ctrl;
  final Function(int) swipe;
  final Widget title;
  final String hint;
  final String searchValue;
  final Function(String) search;

  _Navigation({
    @required this.ctrl,
    @required this.swipe,
    @required this.title,
    @required this.hint,
    @required this.searchValue,
    @required this.search,
  });

  @override
  __NavigationState createState() => __NavigationState();
}

class __NavigationState extends State<_Navigation> {
  bool _searchMode;

  @override
  void initState() {
    super.initState();
    final val = widget.searchValue;
    _searchMode = val != null && val != '';
  }

  @override
  Widget build(BuildContext context) {
    DragStartDetails dragStart;
    DragUpdateDetails dragUpdate;

    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!_searchMode)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (widget.ctrl.offset > 100) widget.ctrl.jumpTo(100);
                  widget.ctrl.animateTo(0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.decelerate);
                },
                onHorizontalDragStart: (details) => dragStart = details,
                onHorizontalDragUpdate: (details) => dragUpdate = details,
                onHorizontalDragEnd: (_) {
                  if (dragUpdate == null || dragStart == null) return;
                  if (dragUpdate.globalPosition.dx <
                      dragStart.globalPosition.dx) {
                    widget.swipe(1);
                  } else {
                    widget.swipe(-1);
                  }
                },
                child: widget.title,
              ),
            )
          else
            _Searchbar(widget.hint, widget.searchValue, widget.search),
          if (!_searchMode)
            IconButton(
              icon: const Icon(FluentSystemIcons.ic_fluent_search_regular),
              onPressed: () => setState(() => _searchMode = true),
            )
          else
            IconButton(
              icon:
                  const Icon(FluentSystemIcons.ic_fluent_chevron_right_filled),
              onPressed: () {
                widget.search(null);
                setState(() => _searchMode = false);
              },
            )
        ],
      ),
    );
  }
}

class _Searchbar extends StatefulWidget {
  final String hint;
  final String searchValue;
  final Function(String) onChanged;

  _Searchbar(this.hint, this.searchValue, this.onChanged);

  @override
  __SearchbarState createState() => __SearchbarState();
}

class __SearchbarState extends State<_Searchbar> {
  TextEditingController _ctrl;
  bool _empty;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.searchValue ?? '');
    _empty = _ctrl.text.length == 0;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 35,
        child: TextField(
          controller: _ctrl,
          cursorColor: Theme.of(context).accentColor,
          style: Theme.of(context).textTheme.headline6,
          inputFormatters: [
            LengthLimitingTextInputFormatter(30),
          ],
          textAlignVertical: TextAlignVertical.bottom,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: Theme.of(context).textTheme.subtitle1,
            filled: true,
            fillColor: Theme.of(context).primaryColor,
            border: OutlineInputBorder(
              borderRadius: Config.BORDER_RADIUS,
              borderSide: BorderSide.none,
            ),
            isDense: true,
            suffixIcon: _empty
                ? null
                : IconButton(
                    padding: const EdgeInsets.all(0),
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _ctrl.clear();
                      _update('');
                    },
                  ),
          ),
          onChanged: (text) => _update(text),
        ),
      ),
    );
  }

  void _update(String text) {
    widget.onChanged(text);
    if (text.length > 0) {
      if (_empty) setState(() => _empty = false);
    } else {
      if (!_empty) setState(() => _empty = true);
    }
  }
}

// TODO finish filter button

class _Filter extends StatefulWidget {
  final String collectionTag;

  _Filter(this.collectionTag);

  @override
  __FilterState createState() => __FilterState();
}

class __FilterState extends State<_Filter> {
  bool _active;

  @override
  void initState() {
    super.initState();
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
        icon: const Icon(Icons.filter_alt_outlined),
        onPressed: () => _pushPage(context),
      );

    return GestureDetector(
      onTap: () => _pushPage(context),
      onLongPress: () {
        Get.find<Explorer>().clearAllFilters();
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
    );
  }

  void _pushPage(BuildContext context) =>
      Get.to(FilterPage(widget.collectionTag, (newActive) {
        if (newActive == null) {
          setState(() => _active = _checkIfActive());
        } else {
          setState(() => _active = newActive);
        }
      }));

  bool _checkIfActive() => Get.find<Explorer>().anyActiveFilterFrom([
        Filterable.STATUS_IN,
        Filterable.STATUS_NOT_IN,
        Filterable.FORMAT_IN,
        Filterable.FORMAT_NOT_IN,
        Filterable.GENRE_IN,
        Filterable.GENRE_NOT_IN,
        Filterable.TAG_IN,
        Filterable.TAG_NOT_IN,
      ]);
}
