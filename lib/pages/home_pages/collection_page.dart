import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/collection.dart';
import 'package:otraku/tools/navigation/control_header.dart';
import 'package:otraku/tools/layouts/media_list.dart';
import 'package:otraku/tools/navigation/headline_header.dart';

class CollectionPage extends StatelessWidget {
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
  Widget build(BuildContext context) => CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        controller: Get.find<Collection>(tag: collectionTag).scrollCtrl,
        slivers: [
          HeadlineHeader(
            '${ofAnime ? 'Anime' : 'Manga'} List',
            otherUserId != null,
          ),
          ControlHeader(collectionTag),
          MediaList(collectionTag),
          SliverToBoxAdapter(
            child: const SizedBox(height: 50),
          ),
        ],
      );
}
