import 'dart:ui';

import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:otraku/providers/anime_collection.dart';
import 'package:otraku/providers/collection_provider.dart';
import 'package:otraku/providers/manga_collection.dart';
import 'package:otraku/tools/headers/header_search_bar.dart';
import 'package:otraku/tools/title_segmented_control.dart';
import 'package:otraku/tools/overlays/collection_sort_sheet.dart';
import 'package:provider/provider.dart';

class CollectionHeader extends StatelessWidget {
  final bool isAnime;
  final ScrollController scrollCtrl;

  const CollectionHeader(this.isAnime, this.scrollCtrl);

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _CollectionHeaderDelegate(context, isAnime, scrollCtrl),
    );
  }
}

class _CollectionHeaderDelegate implements SliverPersistentHeaderDelegate {
  static const _height = 95.0;

  CollectionProvider _collection;
  ScrollController _scrollCtrl;

  _CollectionHeaderDelegate(BuildContext context, isAnime, this._scrollCtrl) {
    _collection = isAnime
        ? Provider.of<AnimeCollection>(context, listen: false)
        : Provider.of<MangaCollection>(context, listen: false);
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    if (_collection.isEmpty) return const SizedBox();

    Map<String, Object> segmentedControlPairs = {};
    final allNames = _collection.names;
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
                initialValue: _collection.listIndex,
                pairs: segmentedControlPairs,
                onNewValue: (value) {
                  _collection.listIndex = value;
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
                      CollectionSearchBar(
                        _collection.search,
                        (value) => _collection.search = value,
                      ),
                      IconButton(
                        icon: const Icon(
                            FluentSystemIcons.ic_fluent_arrow_sort_filled),
                        onPressed: () => showModalBottomSheet(
                          context: context,
                          builder: (ctx) =>
                              CollectionSortSheet(_collection.isAnime),
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
