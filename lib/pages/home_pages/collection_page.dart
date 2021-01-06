import 'package:flutter/material.dart';
import 'package:otraku/tools/navigation/control_header.dart';
import 'package:otraku/tools/layouts/media_list.dart';
import 'package:otraku/tools/navigation/headline_header.dart';

class CollectionPage extends StatefulWidget {
  final int otherUserId;
  final bool ofAnime;
  final String collectionTag;

  CollectionPage({
    @required this.otherUserId,
    @required this.ofAnime,
    @required this.collectionTag,
    @required key,
  }) : super(key: key);

  @override
  _CollectionPageState createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
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
