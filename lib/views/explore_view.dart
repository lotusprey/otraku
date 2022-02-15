import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/explore_controller.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/widgets/overlays/gradient_sheets.dart';
import 'package:otraku/widgets/layouts/review_grid.dart';
import 'package:otraku/widgets/layouts/title_grid.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/layouts/tile_grid.dart';
import 'package:otraku/widgets/navigation/action_button.dart';
import 'package:otraku/widgets/navigation/sliver_filter_app_bar.dart';
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
        ],
      ),
    );
  }
}

class _ExploreGrid extends StatelessWidget {
  const _ExploreGrid();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExploreController>(
      id: ExploreController.ID_BODY,
      builder: (ctrl) {
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

        if (results[0].explorable == Explorable.studio)
          return TitleGrid(results);

        if (results[0].explorable == Explorable.user)
          return TileGrid(models: results, full: false);

        if (results[0].explorable == Explorable.review)
          return ReviewGrid(results);

        return TileGrid(models: results);
      },
    );
  }
}

class _EndOfListLoader extends StatelessWidget {
  const _EndOfListLoader();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExploreController>(
      id: ExploreController.ID_BODY,
      builder: (ctrl) => SliverToBoxAdapter(
        child: Padding(
          padding:
              EdgeInsets.only(top: 20, bottom: NavLayout.offset(context) + 10),
          child: Align(
            alignment: Alignment.topCenter,
            child: ctrl.hasNextPage && !ctrl.isLoading
                ? const Loader()
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
    return GetBuilder<ExploreController>(
      id: ExploreController.ID_BUTTON,
      builder: (ctrl) => FloatingListener(
        scrollCtrl: ctrl.scrollCtrl,
        child: ActionButton(
          tooltip: 'Types',
          icon: ctrl.type.icon,
          onTap: () => showDragSheet(
            context,
            DynamicGradientDragSheet(
              onTap: (i) => ctrl.type = Explorable.values[i],
              itemCount: Explorable.values.length,
              itemBuilder: (_, i) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Explorable.values[i].icon,
                    color: i != ctrl.type.index
                        ? Theme.of(context).colorScheme.onBackground
                        : Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    Convert.clarifyEnum(Explorable.values[i].name)!,
                    style: i != ctrl.type.index
                        ? Theme.of(context).textTheme.headline1
                        : Theme.of(context).textTheme.headline1?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                  ),
                ],
              ),
            ),
          ),
          onSwipe: (goRight) {
            if (goRight) {
              if (ctrl.type.index < Explorable.values.length - 1)
                ctrl.type = Explorable.values.elementAt(ctrl.type.index + 1);
              else
                ctrl.type = Explorable.values.elementAt(0);
            } else {
              if (ctrl.type.index > 0)
                ctrl.type = Explorable.values.elementAt(ctrl.type.index - 1);
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
