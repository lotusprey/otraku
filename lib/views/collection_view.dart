import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/constants/config.dart';
import 'package:otraku/utils/local_settings.dart';
import 'package:otraku/widgets/loaders.dart/sliver_refresh_control.dart';
import 'package:otraku/widgets/overlays/drag_sheets.dart';
import 'package:otraku/widgets/layouts/media_list.dart';
import 'package:otraku/widgets/navigation/action_button.dart';
import 'package:otraku/widgets/navigation/sliver_filterable_app_bar.dart';
import 'package:otraku/widgets/layouts/nav_layout.dart';

class CollectionView extends StatelessWidget {
  CollectionView(this.id, this.ofAnime);

  final int id;
  final bool ofAnime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: CollectionActionButton('$id$ofAnime'),
      body: SafeArea(
        child: HomeCollectionView(id: id, ofAnime: ofAnime, key: null),
      ),
    );
  }
}

class HomeCollectionView extends StatelessWidget {
  HomeCollectionView({
    required this.id,
    required this.ofAnime,
    required key,
  }) : super(key: key);

  final int id;
  final bool ofAnime;

  @override
  Widget build(BuildContext context) {
    final tag = '$id$ofAnime';
    return GetBuilder<CollectionController>(
      init: CollectionController(id, ofAnime),
      tag: tag,
      builder: (ctrl) => CustomScrollView(
        physics: Config.PHYSICS,
        controller: ctrl.scrollCtrl,
        slivers: [
          SliverCollectionAppBar(tag, id != LocalSettings().id),
          SliverRefreshControl(
            onRefresh: ctrl.refetch,
            canRefresh: () => !ctrl.isLoading,
          ),
          MediaList(tag),
          SliverToBoxAdapter(
              child: SizedBox(height: NavLayout.offset(context))),
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
        onTap: () => DragSheet.show(
          context,
          CollectionDragSheet(context, ctrlTag),
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
