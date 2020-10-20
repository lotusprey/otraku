import 'dart:ui';

import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/pages/pushable/filter_page.dart';
import 'package:otraku/providers/design.dart';
import 'package:otraku/providers/explorable.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/headers/header_search_bar.dart';
import 'package:otraku/tools/title_segmented_control.dart';
import 'package:otraku/tools/overlays/explore_sort_sheet.dart';
import 'package:provider/provider.dart';

class ExploreHeader extends StatelessWidget {
  final ScrollController scrollCtrl;

  const ExploreHeader(this.scrollCtrl);

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _ExploreHeaderDelegate(context, scrollCtrl),
    );
  }
}

class _ExploreHeaderDelegate implements SliverPersistentHeaderDelegate {
  static const _height = 95.0;

  ScrollController _scrollCtrl;

  _ExploreHeaderDelegate(
      BuildContext context, ScrollController scrollController) {
    _scrollCtrl = scrollController;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final provider = Provider.of<Explorable>(context, listen: false);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: _height,
          color: Theme.of(context).cardColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TitleSegmentedControl(
                initialValue:
                    Provider.of<Explorable>(context, listen: false).type,
                pairs: Map.fromIterable(
                  Browsable.values,
                  key: (v) => clarifyEnum(describeEnum(v)),
                  value: (v) => v,
                ),
                onNewValue: (value) {
                  Provider.of<Explorable>(context, listen: false).type = value;
                  _scrollCtrl.jumpTo(0);
                },
                onSameValue: (_) => _scrollCtrl.jumpTo(0),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SizedBox(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ExploreSearchBar(
                        provider.search,
                        (value) => provider.search = value,
                      ),
                      Flexible(child: _FilterButton()),
                      Flexible(
                        child: IconButton(
                          icon: const Icon(
                            FluentSystemIcons.ic_fluent_arrow_sort_filled,
                          ),
                          onPressed: () => showModalBottomSheet(
                            context: context,
                            builder: (ctx) => ExploreSortSheet(),
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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

class _FilterButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider.of<Explorable>(context).areFiltersActive()
        ? GestureDetector(
            onTap: () => Navigator.of(context).push(
              CupertinoPageRoute(builder: (_) => FilterPage()),
            ),
            onLongPress: Provider.of<Explorable>(context, listen: false)
                .clearGenreTagFilters,
            child: Container(
              width: ViewConfig.MATERIAL_TAP_TARGET_SIZE,
              height: ViewConfig.CONTROL_HEADER_ICON_HEIGHT,
              decoration: BoxDecoration(
                borderRadius: ViewConfig.BORDER_RADIUS,
                color: Theme.of(context).accentColor,
              ),
              child: const Icon(
                FluentSystemIcons.ic_fluent_filter_filled,
                size: Design.ICON_SMALL,
                color: Colors.white,
              ),
            ),
          )
        : IconButton(
            icon: const Icon(FluentSystemIcons.ic_fluent_filter_filled),
            onPressed: () => Navigator.of(context).push(
              CupertinoPageRoute(builder: (_) => FilterPage()),
            ),
          );
  }
}
