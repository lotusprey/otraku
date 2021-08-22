import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/explore_controller.dart';
import 'package:otraku/enums/explorable.dart';
import 'package:otraku/widgets/bottom_drawer.dart';
import 'package:otraku/widgets/layouts/review_grid.dart';
import 'package:otraku/widgets/layouts/title_list.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/layouts/tile_grid.dart';
import 'package:otraku/widgets/navigation/action_button.dart';
import 'package:otraku/widgets/navigation/sliver_filterable_app_bar.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';
import 'package:otraku/widgets/navigation/headline_header.dart';
import 'package:otraku/widgets/loaders.dart/sliver_refresh_control.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class ExploreView extends StatelessWidget {
  const ExploreView();

  @override
  Widget build(BuildContext context) {
    final explorer = Get.find<ExploreController>();
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      controller: explorer.scrollCtrl,
      slivers: [
        const HeadlineHeader('Explore', false),
        SliverExploreAppBar(),
        SliverRefreshControl(
          onRefresh: explorer.fetch,
          canRefresh: () => !explorer.isLoading,
        ),
        _ExploreGrid(),
        _EndOfListLoader(),
        SliverToBoxAdapter(child: SizedBox(height: NavBar.offset(context))),
      ],
    );
  }
}

class _ExploreGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final explorer = Get.find<ExploreController>();

    return Obx(() {
      if (explorer.isLoading)
        return const SliverFillRemaining(child: Center(child: Loader()));

      final results = explorer.results;
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

      if (results[0].explorable == Explorable.studio) return TitleList(results);

      if (results[0].explorable == Explorable.user)
        return TileGrid(models: results, full: false);

      if (results[0].explorable == Explorable.review)
        return ReviewGrid(results);

      return TileGrid(models: results);
    });
  }
}

class _EndOfListLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: Obx(
            () => Get.find<ExploreController>().hasNextPage &&
                    !Get.find<ExploreController>().isLoading
                ? Loader()
                : const SizedBox(),
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
          onTap: () => Sheet.show(
            ctx: context,
            sheet: ExploreBottomDrawer(context),
            isScrollControlled: true,
            barrierColour: Theme.of(context).primaryColor.withAlpha(150),
          ),
        ),
      ),
    );
  }
}
