import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otraku/providers/auth.dart';
import 'package:otraku/tools/headers/collection_control_header.dart';
import 'package:otraku/tools/multichild_layouts/media_list.dart';
import 'package:otraku/tools/headers/headline_header.dart';
import 'package:provider/provider.dart';

class CollectionsTab extends StatelessWidget {
  final ScrollController scrollCtrl;
  final bool isAnimeCollection;

  CollectionsTab({
    @required this.scrollCtrl,
    @required this.isAnimeCollection,
    @required key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollCtrl,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        HeadlineHeader('${isAnimeCollection ? 'Anime' : 'Manga'} List'),
        CollectionControlHeader(isAnimeCollection),
        SliverToBoxAdapter(
          child: const SizedBox(height: 15),
        ),
        MediaList(
          isAnimeCollection,
          Provider.of<Auth>(context, listen: false).scoreFormat,
        ),
      ],
    );
  }
}
