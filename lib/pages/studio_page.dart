import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/studio.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/enums/media_sort.dart';
import 'package:otraku/widgets/action_icon.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/layouts/tile_grid.dart';
import 'package:otraku/widgets/navigation/opaque_header.dart';
import 'package:otraku/widgets/navigation/top_sliver_header.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class StudioPage extends StatelessWidget {
  static const ROUTE = '/studio';

  final int id;
  final String name;

  StudioPage(this.id, this.name);

  @override
  Widget build(BuildContext context) {
    final studio = Get.find<Studio>(tag: id.toString());

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Obx(
          () => CustomScrollView(
            physics: Config.PHYSICS,
            controller: studio.scrollCtrl,
            semanticChildCount: studio.media.mediaCount,
            slivers: [
              TopSliverHeader(
                toggleFavourite: studio.toggleFavourite,
                isFavourite: studio.model?.isFavourite,
                favourites: studio.model?.favourites,
                text: studio.model?.name,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: Config.PADDING,
                  child: Hero(
                    tag: id,
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline2,
                    ),
                  ),
                ),
              ),
              if (studio.model != null) ...[
                OpaqueHeader([
                  const Spacer(),
                  ActionIcon(
                    tooltip: 'Filter',
                    active: studio.onList != null,
                    icon: Ionicons.funnel_outline,
                    onTap: () => Sheet.show(
                      ctx: context,
                      sheet: OptionSheet(
                        title: 'List Filter',
                        options: ['Everything', 'On List', 'Not On List'],
                        index: studio.onList == null
                            ? 0
                            : studio.onList!
                                ? 1
                                : 2,
                        onTap: (val) {
                          studio.onList = val == 0
                              ? null
                              : val == 1
                                  ? true
                                  : false;
                          studio.scrollTo(0);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  ActionIcon(
                    tooltip: 'Sort',
                    icon: Ionicons.filter_outline,
                    onTap: () => Sheet.show(
                      ctx: context,
                      sheet: MediaSortSheet(
                        studio.sort,
                        (sort) {
                          studio.sort = sort;
                          studio.scrollTo(0);
                        },
                      ),
                      isScrollControlled: true,
                    ),
                  ),
                ]),
                if (studio.media.categories.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'No results',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                  ),
                if (studio.sort == MediaSort.START_DATE ||
                    studio.sort == MediaSort.START_DATE_DESC ||
                    studio.sort == MediaSort.END_DATE ||
                    studio.sort == MediaSort.END_DATE_DESC) ...[
                  for (int i = 0; i < studio.media.categories.length; i++) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: Config.PADDING,
                        child: Text(
                          studio.media.categories[i],
                          style: Theme.of(context).textTheme.headline3,
                        ),
                      ),
                    ),
                    TileGrid(models: studio.media.groups[i]),
                  ],
                ] else
                  TileGrid(models: studio.media.joined),
                if (studio.media.hasNextPage)
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
