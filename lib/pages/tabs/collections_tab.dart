import 'package:flutter/material.dart';
import 'package:otraku/tools/navigators/control_header.dart';
import 'package:otraku/tools/layouts/media_list.dart';
import 'package:otraku/tools/navigators/headline_header.dart';

class CollectionsTab extends StatefulWidget {
  final int otherUserId;
  final bool ofAnime;
  final String collectionTag;

  CollectionsTab({
    @required this.otherUserId,
    @required this.ofAnime,
    @required this.collectionTag,
    @required key,
  }) : super(key: key);

  @override
  _CollectionsTabState createState() => _CollectionsTabState();
}

class _CollectionsTabState extends State<CollectionsTab> {
  final _ctrl = ScrollController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        controller: _ctrl,
        slivers: [
          HeadlineHeader(
            '${widget.ofAnime ? 'Anime' : 'Manga'} List',
            widget.otherUserId != null,
          ),
          CollectionControlHeader(_ctrl, widget.collectionTag),
          MediaList(widget.collectionTag),
          SliverToBoxAdapter(
            child: const SizedBox(height: 50),
          ),
        ],
      );
}
