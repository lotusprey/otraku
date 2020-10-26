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
        HeadlineHeader('${widget.ofAnime ? 'Anime' : 'Manga'} List'),
        CollectionHeader(widget.scrollCtrl),
        MediaList(widget.ofAnime),
      ],
    );
  }
}
