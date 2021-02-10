import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/collection.dart';
import 'package:otraku/pages/home/media_controls.dart';
import 'package:otraku/tools/layouts/media_list.dart';
import 'package:otraku/tools/navigation/custom_nav_bar.dart';
import 'package:otraku/tools/navigation/headline_header.dart';

class CollectionTab extends StatelessWidget {
  final int otherUserId;
  final bool ofAnime;
  final String collectionTag;

  CollectionTab({
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
          MediaControls(collectionTag),
          MediaList(collectionTag),
          SliverToBoxAdapter(
            child: SizedBox(height: CustomNavBar.offset(context)),
          ),
        ],
      );
}
