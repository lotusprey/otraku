import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/explore_controller.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/widgets/overlays/drag_sheets.dart';
import 'package:otraku/widgets/layouts/review_grid.dart';
import 'package:otraku/widgets/layouts/title_grid.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/layouts/tile_grid.dart';
import 'package:otraku/widgets/navigation/action_button.dart';
import 'package:otraku/widgets/navigation/sliver_filterable_app_bar.dart';
import 'package:otraku/widgets/layouts/nav_layout.dart';
import 'package:otraku/widgets/loaders.dart/sliver_refresh_control.dart';

class ExploreView extends StatelessWidget {
  const ExploreView();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExploreController>(
      builder: (ctrl) => CustomScrollView(
        physics: Consts.PHYSICS,
        controller: ctrl.scrollCtrl,
        slivers: [
          const SliverExploreAppBar(),
          SliverRefreshControl(
            onRefresh: ctrl.fetch,
            canRefresh: () => !ctrl.isLoading,
          ),
          const _ExploreGrid(),
          const _EndOfListLoader(),
          SliverToBoxAdapter(
              child: SizedBox(height: NavLayout.offset(context))),
        ],
      ),
    );
  }
}

class _ExploreGrid extends StatelessWidget {
  const _ExploreGrid();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ExploreController>();

    return Obx(() {
      if (ctrl.isLoading)
        return const SliverFillRemaining(child: Center(child: Loader()));

      final results = ctrl.results;
      if (results.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Text(
              'No results',
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
        );
      }

      if (results[0].explorable == Explorable.studio) return TitleGrid(results);

      if (results[0].explorable == Explorable.user)
        return TileGrid(models: results, full: false);

      if (results[0].explorable == Explorable.review)
        return ReviewGrid(results);

      return TileGrid(models: results);
    });
  }
}

class _EndOfListLoader extends StatelessWidget {
  const _EndOfListLoader();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: Obx(
            () {
              final ctrl = Get.find<ExploreController>();
              return ctrl.hasNextPage && !ctrl.isLoading
                  ? const Loader()
                  : const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}

class ExploreActionButton extends StatelessWidget {
  const ExploreActionButton();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ExploreController>();
    return Obx(
      () => FloatingListener(
        scrollCtrl: ctrl.scrollCtrl,
        child: ActionButton(
          tooltip: 'Types',
          icon: ctrl.type.icon,
          onTap: () => DragSheet.show(context, ExploreDragSheet(context)),
          onSwipe: (goRight) {
            final index = ctrl.type.index;
            if (goRight) {
              if (index < Explorable.values.length - 1)
                ctrl.type = Explorable.values.elementAt(index + 1);
              else
                ctrl.type = Explorable.values.elementAt(0);
            } else {
              if (index > 0)
                ctrl.type = Explorable.values.elementAt(index - 1);
              else
                ctrl.type = Explorable.values.last;
            }

            return ctrl.type.icon;
          },
        ),
      ),
    );
  }
}
