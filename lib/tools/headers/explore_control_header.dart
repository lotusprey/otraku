import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/pages/pushable/filter_page.dart';
import 'package:otraku/providers/design.dart';
import 'package:otraku/providers/explorable.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/headers/header_refresh_button.dart';
import 'package:otraku/tools/headers/header_search_bar.dart';
import 'package:otraku/tools/navigation/title_segmented_control.dart';
import 'package:otraku/tools/overlays/explore_sort_sheet.dart';
import 'package:provider/provider.dart';

class ExploreControlHeader extends StatelessWidget {
  final ScrollController scrollCtrl;

  const ExploreControlHeader(this.scrollCtrl);

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: false,
      floating: true,
      delegate: _ExploreControlHeaderDelegate(context, scrollCtrl),
    );
  }
}

class _ExploreControlHeaderDelegate implements SliverPersistentHeaderDelegate {
  static const _height = 95.0;

  ScrollController _scrollCtrl;

  _ExploreControlHeaderDelegate(
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
          padding: const EdgeInsets.symmetric(horizontal: 15),
          color: Theme.of(context).cardColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TitleSegmentedControl(
                  value: Provider.of<Explorable>(context).type,
                  pairs: Map.fromIterable(
                    Browsable.values,
                    key: (v) => clarifyEnum(describeEnum(v)),
                    value: (v) => v,
                  ),
                  onNewValue: (value) {
                    provider.type = value;
                    _scrollCtrl.jumpTo(0);
                  },
                  onSameValue: (_) => _scrollCtrl.jumpTo(0),
                ),
              ),
              SizedBox(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    HeaderSearchBar(provider),
                    if (provider.type == Browsable.anime ||
                        provider.type == Browsable.manga) ...[
                      _FilterButton(),
                      IconButton(
                        icon: const Icon(LineAwesomeIcons.sort),
                        onPressed: () => showModalBottomSheet(
                          context: context,
                          builder: (ctx) => ExploreSortSheet(),
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                        ),
                      ),
                    ],
                    HeaderRefreshButton(
                      listenable: provider,
                      readable: provider,
                    ),
                  ],
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
    return Provider.of<Explorable>(context, listen: false).areFiltersActive()
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
                borderRadius: ViewConfig.RADIUS,
                color: Theme.of(context).accentColor,
              ),
              child: const Icon(
                LineAwesomeIcons.filter,
                size: Design.ICON_SMALL,
                color: Colors.white,
              ),
            ),
          )
        : IconButton(
            icon: const Icon(LineAwesomeIcons.filter),
            onPressed: () => Navigator.of(context).push(
              CupertinoPageRoute(builder: (_) => FilterPage()),
            ),
          );
  }
}
