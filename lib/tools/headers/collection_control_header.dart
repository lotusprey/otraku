import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:otraku/providers/anime_collection.dart';
import 'package:otraku/providers/collection_provider.dart';
import 'package:otraku/providers/manga_collection.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/tools/headers/header_refresh_button.dart';
import 'package:otraku/tools/headers/header_search_button.dart';
import 'package:otraku/tools/navigation/title_segmented_control.dart';
import 'package:otraku/tools/overlays/collection_sort_sheet.dart';
import 'package:provider/provider.dart';

class CollectionControlHeader extends StatelessWidget {
  final bool isAnime;

  const CollectionControlHeader(this.isAnime);

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: false,
      floating: true,
      delegate: _CollectionControlHeaderDelegate(context, isAnime),
    );
  }
}

class _CollectionControlHeaderDelegate
    implements SliverPersistentHeaderDelegate {
  static const _height = 100.0;

  CollectionProvider _collection;
  Palette _palette;

  _CollectionControlHeaderDelegate(BuildContext context, bool isAnime) {
    _collection = isAnime
        ? Provider.of<AnimeCollection>(context)
        : Provider.of<MangaCollection>(context);
    _palette = Provider.of<Theming>(context, listen: false).palette;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
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
          padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
          color: _palette.background.withAlpha(200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TitleSegmentedControl(
                value: _collection.listIndex,
                pairs: segmentedControlPairs,
                function: (value) => _collection.listIndex = value,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  HeaderSearchButton(_collection, _palette),
                  IconButton(
                    icon: const Icon(LineAwesomeIcons.sort),
                    color: _palette.faded,
                    iconSize: Palette.ICON_MEDIUM,
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      builder: (ctx) =>
                          CollectionSortSheet(_collection.isAnime),
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                    ),
                  ),
                  HeaderRefreshButton(
                    listenable: _collection,
                    readable: _collection.isAnime
                        ? Provider.of<AnimeCollection>(context, listen: false)
                        : Provider.of<MangaCollection>(context, listen: false),
                    palette: _palette,
                  )
                ],
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
}
