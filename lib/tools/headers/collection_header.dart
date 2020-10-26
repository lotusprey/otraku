import 'dart:ui';

import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:otraku/providers/collections.dart';
import 'package:otraku/tools/headers/header_search_bar.dart';
import 'package:otraku/tools/title_segmented_control.dart';
import 'package:otraku/tools/overlays/collection_sort_sheet.dart';
import 'package:provider/provider.dart';

class CollectionHeader extends StatelessWidget {
  final ScrollController scrollCtrl;

  const CollectionHeader(this.scrollCtrl);

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _CollectionHeaderDelegate(scrollCtrl),
    );
  }
}

class _CollectionHeaderDelegate implements SliverPersistentHeaderDelegate {
  static const _height = 95.0;

  ScrollController _scrollCtrl;

  _CollectionHeaderDelegate(this._scrollCtrl);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final collection = Provider.of<Collections>(context).collection;
    if (collection == null) return Container();

    Map<String, Object> segmentedControlPairs = {};
    final allNames = context.read<Collections>().collection.listNames;
    for (int i = 0; i < allNames.length; i++) {
      segmentedControlPairs[allNames[i]] = i;
    }

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
                initialValue: collection.listIndex,
                pairs: segmentedControlPairs,
                onNewValue: (value) {
                  collection.listIndex = value;
                  if (_scrollCtrl.offset > 100) _scrollCtrl.jumpTo(100);
                  _scrollCtrl.animateTo(0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.decelerate);
                },
                onSameValue: (_) {
                  if (_scrollCtrl.offset > 100) _scrollCtrl.jumpTo(100);
                  _scrollCtrl.animateTo(0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.decelerate);
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SizedBox(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CollectionSearchBar(
                        collection.search,
                        (value) => collection.search = value,
                      ),
                      IconButton(
                        icon: const Icon(
                            FluentSystemIcons.ic_fluent_arrow_sort_filled),
                        onPressed: () => showModalBottomSheet(
                          context: context,
                          builder: (ctx) => CollectionSortSheet(),
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
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
