import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otraku/providers/collections.dart';
import 'package:otraku/tools/headers/collection_header.dart';
import 'package:otraku/tools/multichild_layouts/media_list.dart';
import 'package:otraku/tools/headers/headline_header.dart';
import 'package:provider/provider.dart';

class CollectionsTab extends StatefulWidget {
  final ScrollController scrollCtrl;
  final int otherUserId;
  final bool ofAnime;

  CollectionsTab({
    @required this.scrollCtrl,
    @required this.otherUserId,
    @required this.ofAnime,
    @required key,
  }) : super(key: key);

  @override
  _CollectionsTabState createState() => _CollectionsTabState();
}

class _CollectionsTabState extends State<CollectionsTab> {
  @override
  Widget build(BuildContext context) {
    Provider.of<Collections>(context, listen: false).assignCollection(
      widget.ofAnime,
      widget.otherUserId,
    );

    return CustomScrollView(
      controller: widget.scrollCtrl,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        HeadlineHeader('${widget.ofAnime ? 'Anime' : 'Manga'} List', false),
        CollectionHeader(widget.scrollCtrl),
        MediaList(widget.ofAnime),
      ],
    );
  }
}

class CollectionDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final collection = Provider.of<Collections>(context).collection;
    final names = collection.listNames;
    final counts = collection.listEntryCounts;
    final selected = collection.listIndex;

    return SafeArea(
      child: Container(
        width: MediaQuery.of(context).size.width - 100,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).backgroundColor,
              Theme.of(context).backgroundColor.withAlpha(0),
            ],
          ),
        ),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 35),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Text(
                '${collection.totalEntryCount} Total',
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
            for (int i = 0; i < names.length; i++) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    if (i != selected)
                      Provider.of<Collections>(context, listen: false)
                          .collection
                          .listIndex = i;
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(names[i],
                          style: i != selected
                              ? Theme.of(context).textTheme.headline3
                              : Theme.of(context).textTheme.headline2),
                      Text(
                        counts[i].toString(),
                        style: Theme.of(context).textTheme.headline4,
                      )
                    ],
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
