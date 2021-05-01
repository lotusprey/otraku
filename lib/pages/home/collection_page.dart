import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/collection.dart';
import 'package:otraku/widgets/layouts/media_list.dart';
import 'package:otraku/widgets/navigation/control_header.dart';
import 'package:otraku/widgets/navigation/custom_drawer.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';
import 'package:otraku/widgets/navigation/headline_header.dart';

import '../../utils/client.dart';

class CollectionPage extends StatelessWidget {
  static const ROUTE = '/collection';

  final int id;
  final bool ofAnime;
  final String collectionTag;

  CollectionPage({
    required this.id,
    required this.ofAnime,
    required this.collectionTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerScrimColor: Theme.of(context).primaryColor.withAlpha(150),
      drawer: CollectionDrawer(collectionTag),
      body: SafeArea(
        child: CollectionTab(
          id: id,
          ofAnime: ofAnime,
          collectionTag: collectionTag,
          key: null,
        ),
      ),
    );
  }
}

class CollectionTab extends StatelessWidget {
  final int id;
  final bool ofAnime;
  final String collectionTag;

  CollectionTab({
    required this.id,
    required this.ofAnime,
    required this.collectionTag,
    required key,
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
            id != Client.viewerId,
          ),
          CollectionControlHeader(collectionTag),
          MediaList(collectionTag),
          SliverToBoxAdapter(
            child: SizedBox(height: NavBar.offset(context)),
          ),
        ],
      );
}
