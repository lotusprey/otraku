import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otraku/providers/anime_collection.dart';
import 'package:otraku/providers/auth.dart';
import 'package:otraku/providers/manga_collection.dart';
import 'package:otraku/tools/headers/collection_header.dart';
import 'package:otraku/tools/headers/header_refresh_button.dart';
import 'package:otraku/tools/multichild_layouts/media_list.dart';
import 'package:otraku/tools/headers/headline_header.dart';
import 'package:provider/provider.dart';

class CollectionsTab extends StatefulWidget {
  final ScrollController scrollCtrl;
  final bool isAnime;

  CollectionsTab({
    @required this.scrollCtrl,
    @required this.isAnime,
    @required key,
  }) : super(key: key);

  @override
  _CollectionsTabState createState() => _CollectionsTabState();
}

class _CollectionsTabState extends State<CollectionsTab> {
  @override
  Widget build(BuildContext context) {
    final collection = widget.isAnime
        ? Provider.of<AnimeCollection>(context, listen: false)
        : Provider.of<MangaCollection>(context, listen: false);

    if (collection.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No ${collection.collectionName}',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(
              height: 60,
              child: HeaderRefreshButton(
                readable: collection,
                listenable: widget.isAnime
                    ? Provider.of<AnimeCollection>(context)
                    : Provider.of<MangaCollection>(context),
              ),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      controller: widget.scrollCtrl,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        HeadlineHeader('${collection.collectionName} List'),
        CollectionHeader(widget.isAnime, widget.scrollCtrl),
        MediaList(
          widget.isAnime,
          Provider.of<Auth>(context, listen: false).scoreFormat,
        ),
      ],
    );
  }
}
