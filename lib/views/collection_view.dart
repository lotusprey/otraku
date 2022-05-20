import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/loaders.dart/sliver_loaders.dart';
import 'package:otraku/widgets/grids/large_collection_grid.dart';
import 'package:otraku/widgets/layouts/action_button.dart';
import 'package:otraku/widgets/navigation/sliver_filter_app_bar.dart';
import 'package:otraku/widgets/layouts/nav_layout.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class CollectionView extends StatelessWidget {
  CollectionView(this.id, this.ofAnime);

  final int id;
  final bool ofAnime;

  @override
  Widget build(BuildContext context) {
    final tag = '$id$ofAnime';
    return GetBuilder<CollectionController>(
      init: CollectionController(id, ofAnime),
      tag: tag,
      builder: (ctrl) => WillPopScope(
        onWillPop: () {
          if (ctrl.search == null) return Future.value(true);
          ctrl.search = null;
          return Future.value(false);
        },
        child: Scaffold(
          floatingActionButton: CollectionActionButton(tag),
          body: SafeArea(
            child: HomeCollectionView(id: id, ofAnime: ofAnime, key: null),
          ),
        ),
      ),
    );
  }
}

class HomeCollectionView extends StatelessWidget {
  HomeCollectionView({required this.id, required this.ofAnime, super.key});

  final int id;
  final bool ofAnime;

  @override
  Widget build(BuildContext context) {
    final tag = '$id$ofAnime';
    final isMe =
        tag == '${Settings().id}true' || tag == '${Settings().id}false';
    final sidePadding = MediaQuery.of(context).size.width > Consts.layoutBig
        ? (MediaQuery.of(context).size.width - Consts.layoutBig) / 2
        : 10.0;

    return GetBuilder<CollectionController>(
      tag: tag,
      builder: (ctrl) => CustomScrollView(
        physics: Consts.physics,
        controller: ctrl.scrollCtrl,
        slivers: [
          SliverCollectionAppBar(tag, id != Settings().id),
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
              tag: tag,
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
                      ? (e) => ctrl.updateProgress(
                            e.mediaId,
                            e.progress,
                            e.listStatus,
                            e.format,
                          )
                      : null,
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: NavLayout.offset(context)),
          ),
        ],
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

    return FloatingActionListener(
      scrollCtrl: ctrl.scrollCtrl,
      child: ActionButtonOld(
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
      ),
    );
  }
}
