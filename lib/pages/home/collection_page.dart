import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/collection.dart';
import 'package:otraku/pages/home/media_controls.dart';
import 'package:otraku/tools/layouts/media_list.dart';
import 'package:otraku/tools/navigation/custom_drawer.dart';
import 'package:otraku/tools/navigation/nav_bar.dart';
import 'package:otraku/tools/navigation/headline_header.dart';

class CollectionPage extends StatelessWidget {
  static const ROUTE = '/collection';

  final int otherUserId;
  final bool ofAnime;
  final String collectionTag;

  CollectionPage({
    @required this.otherUserId,
    @required this.ofAnime,
    @required this.collectionTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerScrimColor: Theme.of(context).primaryColor.withAlpha(150),
      drawer: CollectionDrawer(collectionTag),
      body: SafeArea(
        child: CollectionTab(
          otherUserId: otherUserId,
          ofAnime: ofAnime,
          collectionTag: collectionTag,
          key: null,
        ),
      ),
    );
  }
}

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
            child: SizedBox(height: NavBar.offset(context)),
          ),
        ],
      );
}
