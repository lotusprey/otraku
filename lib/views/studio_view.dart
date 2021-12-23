import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/studio_controller.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/constants/media_sort.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/layouts/tile_grid.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/navigation/top_sliver_header.dart';
import 'package:otraku/widgets/overlays/drag_sheets.dart';
import 'package:otraku/widgets/overlays/sheets.dart';
import 'package:otraku/widgets/overlays/toast.dart';

class StudioView extends StatelessWidget {
  final int id;
  final String? name;

  StudioView(this.id, this.name);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: GetBuilder<StudioController>(
          init: StudioController(id),
          tag: id.toString(),
          builder: (ctrl) => CustomScrollView(
            physics: Consts.PHYSICS,
            controller: ctrl.scrollCtrl,
            semanticChildCount: ctrl.media.mediaCount,
            slivers: [
              TopSliverHeader(
                toggleFavourite: ctrl.toggleFavourite,
                isFavourite: ctrl.model?.isFavourite,
                favourites: ctrl.model?.favourites,
                text: ctrl.model?.name,
              ),
              if (name != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: Consts.PADDING,
                    child: GestureDetector(
                      onTap: () => Toast.copy(context, name!),
                      child: Hero(
                        tag: id,
                        child: Text(
                          name!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headline1,
                        ),
                      ),
                    ),
                  ),
                ),
              if (ctrl.model != null) ...[
                SliverShadowAppBar([
                  const Spacer(),
                  AppBarIcon(
                    tooltip: 'Filter',
                    icon: Ionicons.funnel_outline,
                    onTap: () => DragSheet.show(
                      context,
                      OptionDragSheet(
                        options: const ['Everything', 'On List', 'Not On List'],
                        index: ctrl.onList == null
                            ? 0
                            : ctrl.onList!
                                ? 1
                                : 2,
                        onTap: (val) => ctrl.onList = val == 0
                            ? null
                            : val == 1
                                ? true
                                : false,
                      ),
                    ),
                  ),
                  AppBarIcon(
                    tooltip: 'Sort',
                    icon: Ionicons.filter_outline,
                    onTap: () => Sheet.show(
                      ctx: context,
                      sheet: MediaSortSheet(ctrl.sort, (s) => ctrl.sort = s),
                    ),
                  ),
                ]),
                if (ctrl.media.names.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'No results',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                  ),
                if (ctrl.sort == MediaSort.START_DATE ||
                    ctrl.sort == MediaSort.START_DATE_DESC ||
                    ctrl.sort == MediaSort.END_DATE ||
                    ctrl.sort == MediaSort.END_DATE_DESC) ...[
                  for (int i = 0; i < ctrl.media.names.length; i++) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: Consts.PADDING,
                        child: Text(
                          ctrl.media.names[i],
                          style: Theme.of(context).textTheme.headline1,
                        ),
                      ),
                    ),
                    TileGrid(models: ctrl.media.groups[i]),
                  ],
                ] else
                  TileGrid(models: ctrl.media.joined),
                if (ctrl.media.hasNextPage)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Center(
                        child: const Loader(),
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).viewPadding.bottom,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
