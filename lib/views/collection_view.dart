import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/controllers/progress_controller.dart';
import 'package:otraku/edit/edit.dart';
import 'package:otraku/utils/pagination_controller.dart';
import 'package:otraku/utils/route_arg.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/widgets/layouts/floating_bar.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';
import 'package:otraku/widgets/grids/large_collection_grid.dart';
import 'package:otraku/widgets/navigation/filter_tools.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class CollectionView extends StatefulWidget {
  CollectionView(this.id, this.ofAnime);

  final int id;
  final bool ofAnime;

  @override
  State<CollectionView> createState() => _CollectionViewState();
}

class _CollectionViewState extends State<CollectionView> {
  late final _tag = '${widget.id}${widget.ofAnime}';
  final _ctrl = ScrollController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CollectionController>(
      init: CollectionController(widget.id, widget.ofAnime),
      tag: _tag,
      builder: (collectionCtrl) => WillPopScope(
        onWillPop: () {
          if (collectionCtrl.search == null) return Future.value(true);
          collectionCtrl.search = null;
          return Future.value(false);
        },
        child: CollectionSubView(scrollCtrl: _ctrl, ctrlTag: _tag),
      ),
    );
  }
}

class CollectionSubView extends StatefulWidget {
  CollectionSubView({
    required this.ctrlTag,
    required this.scrollCtrl,
    super.key,
  });

  final String ctrlTag;
  final ScrollController scrollCtrl;

  @override
  State<CollectionSubView> createState() => _CollectionSubViewState();
}

class _CollectionSubViewState extends State<CollectionSubView> {
  void _scrollListener() => widget.scrollCtrl.scrollToTop();

  @override
  void initState() {
    super.initState();
    Get.find<CollectionController>(tag: widget.ctrlTag)
        .addListenerId(CollectionController.ID_SCROLLVIEW, _scrollListener);
  }

  @override
  void dispose() {
    Get.find<CollectionController>(tag: widget.ctrlTag)
        .removeListenerId(CollectionController.ID_SCROLLVIEW, _scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMe = widget.ctrlTag == '${Settings().id}true' ||
        widget.ctrlTag == '${Settings().id}false';
    final sidePadding = MediaQuery.of(context).size.width > Consts.layoutBig
        ? (MediaQuery.of(context).size.width - Consts.layoutBig) / 2
        : 10.0;

    return GetBuilder<CollectionController>(
      tag: widget.ctrlTag,
      builder: (ctrl) => PageLayout(
        floatingBar: FloatingBar(
          scrollCtrl: widget.scrollCtrl,
          children: [CollectionActionButton(widget.ctrlTag)],
        ),
        topBar: TopBar(
          canPop: !isMe,
          items: !ctrl.isEmpty
              ? [
                  GetBuilder<CollectionController>(
                    id: CollectionController.ID_HEAD,
                    tag: widget.ctrlTag,
                    builder: (ctrl) => SearchToolField(
                      value: ctrl.search,
                      title: ctrl.currentName,
                      onChanged: (val) => ctrl.search = val,
                    ),
                  ),
                  TopBarIcon(
                    tooltip: 'Random',
                    icon: Ionicons.shuffle_outline,
                    onTap: () {
                      final entry = ctrl.random;
                      Navigator.pushNamed(
                        context,
                        RouteArg.media,
                        arguments:
                            RouteArg(id: entry.mediaId, info: entry.imageUrl),
                      );
                    },
                  ),
                  FilterMediaToolButton(ctrl.filters),
                ]
              : const [],
        ),
        child: CustomScrollView(
          physics: Consts.physics,
          controller: widget.scrollCtrl,
          slivers: [
            SliverRefreshControl(
              onRefresh: ctrl.refetch,
              canRefresh: () => !ctrl.isLoading,
            ),
            SliverPadding(
              padding: EdgeInsets.only(
                left: sidePadding,
                right: sidePadding,
                top: 10,
              ),
              sliver: GetBuilder<CollectionController>(
                tag: widget.ctrlTag,
                id: CollectionController.ID_BODY,
                builder: (ctrl) {
                  if (ctrl.isLoading)
                    return const SliverFillRemaining(
                      child: Center(child: Loader()),
                    );

                  if (ctrl.entries.isEmpty)
                    return SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'No ${ctrl.ofAnime ? 'Anime' : 'Manga'}',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ),
                    );

                  return LargeCollectionGrid(
                    items: ctrl.entries,
                    scoreFormat: ctrl.scoreFormat!,
                    updateProgress: isMe
                        ? (e) async {
                            final customLists =
                                await updateProgress(e.mediaId, e.progress);

                            if (customLists == null) return;

                            ctrl.updateProgress(
                              e.mediaId,
                              e.progress,
                              customLists,
                              e.entryStatus,
                              e.format,
                            );

                            Get.find<ProgressController>().incrementProgress(
                              e.mediaId,
                              e.progress,
                            );
                          }
                        : null,
                  );
                },
              ),
            ),
            const SliverFooter(),
          ],
        ),
      ),
    );
  }
}

class CollectionActionButton extends StatelessWidget {
  const CollectionActionButton(this.ctrlTag, {super.key});

  final String ctrlTag;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CollectionController>(tag: ctrlTag);

    return ActionButton(
      tooltip: 'Lists',
      icon: Ionicons.menu_outline,
      onTap: () => showSheet(
        context,
        DynamicGradientDragSheet(
          onTap: (i) => ctrl.listIndex = i,
          children: [
            for (int i = 0; i < ctrl.listNames.length; i++)
              Row(
                children: [
                  Flexible(
                    child: Text(
                      ctrl.listNames[i],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: i != ctrl.listIndex
                          ? Theme.of(context).textTheme.headline1
                          : Theme.of(context).textTheme.headline1?.copyWith(
                              color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  Text(
                    ' ${ctrl.listCounts[i]}',
                    style: Theme.of(context).textTheme.headline3,
                  ),
                ],
              ),
          ],
        ),
      ),
      onSwipe: (goRight) {
        if (goRight) {
          if (ctrl.listIndex < ctrl.listCount - 1)
            ctrl.listIndex++;
          else
            ctrl.listIndex = 0;
        } else {
          if (ctrl.listIndex > 0)
            ctrl.listIndex--;
          else
            ctrl.listIndex = ctrl.listCount - 1;
        }

        return null;
      },
    );
  }
}
