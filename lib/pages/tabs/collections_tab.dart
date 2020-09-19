import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:otraku/providers/auth.dart';
import 'package:otraku/providers/collection_provider.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/tools/headers/collection_control_header.dart';
import 'package:otraku/tools/multichild_layouts/media_list.dart';
import 'package:otraku/tools/headers/headline_header.dart';
import 'package:provider/provider.dart';

class CollectionsTab extends StatefulWidget {
  final ScrollController scrollCtrl;
  final CollectionProvider collection;

  CollectionsTab({
    @required this.scrollCtrl,
    @required this.collection,
    @required key,
  }) : super(key: key);

  @override
  _CollectionsTabState createState() => _CollectionsTabState();
}

class _CollectionsTabState extends State<CollectionsTab> {
  @override
  Widget build(BuildContext context) {
    if (widget.collection.isEmpty) {
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
                    'No ${widget.collection.collectionName} Results',
                    style: palette.smallTitle,
                  ),
                  IconButton(
                    icon: const Icon(LineAwesomeIcons.retweet),
                    color: palette.faded,
                    iconSize: Palette.ICON_MEDIUM,
                    onPressed: () => widget.collection
                        .fetchMedia()
                        .then((_) => setState(() {})),
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
        HeadlineHeader('${widget.collection.collectionName} List'),
        CollectionControlHeader(widget.collection.isAnime, widget.scrollCtrl),
        MediaList(
          widget.collection.isAnime,
          Provider.of<Auth>(context, listen: false).scoreFormat,
        ),
      ],
    );
  }
}
