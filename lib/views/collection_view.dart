import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/utils/settings.dart';
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
          if (!ctrl.searchMode) return Future.value(true);
          ctrl.searchMode = false;
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
          CollectionGrid(tag),
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
            itemExtent: 60,
            itemCount: ctrl.listNames.length,
            onTap: (i) => ctrl.listIndex = i,
            itemBuilder: (_, i) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ctrl.listNames[i],
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: i != ctrl.listIndex
                      ? Theme.of(context).textTheme.headline1
                      : Theme.of(context).textTheme.headline1?.copyWith(
                          color: Theme.of(context).colorScheme.secondary),
                ),
                const SizedBox(height: 5),
                Text(
                  ctrl.listCounts[i].toString(),
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
