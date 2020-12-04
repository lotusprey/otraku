import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/collections.dart';
import 'package:otraku/tools/headers/control_header.dart';
import 'package:otraku/tools/layouts/media_list.dart';
import 'package:otraku/tools/headers/headline_header.dart';

class CollectionsTab extends StatefulWidget {
  final int otherUserId;
  final bool ofAnime;

  CollectionsTab({
    @required this.otherUserId,
    @required this.ofAnime,
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
  Widget build(BuildContext context) {
    Get.find<Collections>().assignCollection(
      widget.ofAnime,
      widget.otherUserId,
    );

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      controller: _ctrl,
      slivers: [
        HeadlineHeader('${widget.ofAnime ? 'Anime' : 'Manga'} List', false),
        ControlHeader(true, _ctrl),
        MediaList(widget.ofAnime),
        SliverToBoxAdapter(
          child: const SizedBox(height: 50),
        ),
      ],
    );
  }
}
