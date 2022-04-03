import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/loaders.dart/sliver_refresh_control.dart';
import 'package:otraku/widgets/layouts/collection_grid.dart';
import 'package:otraku/widgets/navigation/action_button.dart';
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
  HomeCollectionView({
    required this.id,
    required this.ofAnime,
    key,
  }) : super(key: key);

  final int id;
  final bool ofAnime;

  @override
  Widget build(BuildContext context) {
    final tag = '$id$ofAnime';
    final isMe =
        tag == '${Settings().id}true' || tag == '${Settings().id}false';
    final sidePadding = 10.0 +
        (MediaQuery.of(context).size.width > 1000
            ? (MediaQuery.of(context).size.width - 1000) / 2
            : 0.0);

    return GetBuilder<CollectionController>(
      tag: tag,
      builder: (ctrl) => CustomScrollView(
        physics: Consts.PHYSICS,
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

                return CollectionGrid(
                  items: ctrl.entries,
                  scoreFormat: ctrl.scoreFormat!,
                  updateProgress: isMe ? ctrl.updateProgress : null,
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
  const CollectionActionButton(this.ctrlTag, {Key? key}) : super(key: key);

  final String ctrlTag;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CollectionController>(tag: ctrlTag);

    return FloatingListener(
      scrollCtrl: ctrl.scrollCtrl,
      child: ActionButton(
        tooltip: 'Lists',
        icon: Ionicons.menu_outline,
        onTap: () => showSheet(
          context,
          DynamicGradientDragSheet(
            itemCount: ctrl.listNames.length,
            onTap: (i) => ctrl.listIndex = i,
            itemBuilder: (_, i) => Row(
              children: [
                Flexible(
                  child: Text(
                    ctrl.listNames[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: i != ctrl.listIndex
                        ? Theme.of(context).textTheme.headline1
                        : Theme.of(context).textTheme.headline1?.copyWith(
                            color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
                Text(
                  ' ${ctrl.listCounts[i]}',
                  style: Theme.of(context).textTheme.headline3,
                ),
              ],
            ),
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
