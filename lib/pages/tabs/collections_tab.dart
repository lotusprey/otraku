import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:otraku/providers/anime_collection.dart';
import 'package:otraku/providers/auth.dart';
import 'package:otraku/providers/collection_provider.dart';
import 'package:otraku/providers/manga_collection.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/tools/headers/collection_control_header.dart';
import 'package:otraku/tools/multichild_layouts/media_list.dart';
import 'package:otraku/tools/headers/headline_header.dart';
import 'package:provider/provider.dart';

class CollectionsTab extends StatefulWidget {
  final ScrollController scrollCtrl;
  final bool isAnimeCollection;

  CollectionsTab({
    @required this.scrollCtrl,
    @required this.isAnimeCollection,
    @required key,
  }) : super(key: key);

  @override
  _CollectionsTabState createState() => _CollectionsTabState();
}

class _CollectionsTabState extends State<CollectionsTab> {
  CollectionProvider _collection;

  @override
  Widget build(BuildContext context) {
    if (_collection.isEmpty) {
      final palette = Provider.of<Theming>(context, listen: false).palette;
      return CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        controller: widget.scrollCtrl,
        slivers: [
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'No ${_collection.collectionName} Results',
                    style: palette.smallTitle,
                  ),
                  IconButton(
                    icon: const Icon(LineAwesomeIcons.retweet),
                    color: palette.faded,
                    iconSize: Palette.ICON_MEDIUM,
                    onPressed: () =>
                        _collection.fetchMedia().then((_) => setState(() {})),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return CustomScrollView(
      controller: widget.scrollCtrl,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        HeadlineHeader('${_collection.collectionName} List'),
        CollectionControlHeader(widget.isAnimeCollection),
        SliverToBoxAdapter(
          child: const SizedBox(height: 15),
        ),
        MediaList(
          widget.isAnimeCollection,
          Provider.of<Auth>(context, listen: false).scoreFormat,
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.isAnimeCollection) {
      _collection = Provider.of<AnimeCollection>(context, listen: false);
    } else {
      _collection = Provider.of<MangaCollection>(context, listen: false);
    }
  }
}
