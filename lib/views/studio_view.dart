import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/studio_controller.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/constants/media_sort.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/widgets/fields/drop_down_field.dart';
import 'package:otraku/widgets/layouts/sliver_grid_delegates.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/layouts/tile_grid.dart';
import 'package:otraku/widgets/navigation/action_button.dart';
import 'package:otraku/widgets/navigation/top_sliver_header.dart';
import 'package:otraku/widgets/overlays/sheets.dart';
import 'package:otraku/widgets/overlays/toast.dart';

class StudioView extends StatelessWidget {
  StudioView(this.id, this.name);

  final int id;
  final String? name;

  @override
  Widget build(BuildContext context) {
    final sidePadding = MediaQuery.of(context).size.width > Consts.LAYOUT_BIG
        ? (MediaQuery.of(context).size.width - Consts.LAYOUT_BIG) / 2
        : 10.0;

    return GetBuilder<StudioController>(
      init: StudioController(id),
      tag: id.toString(),
      builder: (ctrl) => Scaffold(
        floatingActionButton: ctrl.model != null ? _ActionButton(id) : null,
        floatingActionButtonLocation: Settings().leftHanded
            ? FloatingActionButtonLocation.startFloat
            : FloatingActionButtonLocation.endFloat,
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
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
                        padding: EdgeInsets.symmetric(
                          horizontal: sidePadding,
                          vertical: 10,
                        ),
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

class _ActionButton extends StatelessWidget {
  const _ActionButton(this.id);

  final int id;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StudioController>(
      tag: id.toString(),
      builder: (ctrl) => FloatingActionListener(
        scrollCtrl: ctrl.scrollCtrl,
        child: ActionButton(
          icon: Ionicons.funnel_outline,
          tooltip: 'Filter',
          onTap: () {
            MediaSort sort = ctrl.sort;
            bool? onList = ctrl.onList;

            final sortItems = <String, int>{};
            for (int i = 0; i < MediaSort.values.length; i += 2) {
              String key = Convert.clarifyEnum(MediaSort.values[i].name)!;
              sortItems[key] = i ~/ 2;
            }

            showSheet(
              context,
              OpaqueSheet(
                initialHeight: Consts.TAP_TARGET_SIZE * 4,
                builder: (context, scrollCtrl) => GridView(
                  controller: scrollCtrl,
                  physics: Consts.PHYSICS,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 20,
                  ),
                  gridDelegate:
                      const SliverGridDelegateWithMinWidthAndFixedHeight(
                    minWidth: 155,
                    height: 75,
                  ),
                  children: [
                    DropDownField<int>(
                      title: 'Sort',
                      value: sort.index ~/ 2,
                      items: sortItems,
                      onChanged: (val) {
                        int index = val * 2;
                        if (sort.index % 2 != 0) index++;
                        sort = MediaSort.values[index];
                      },
                    ),
                    DropDownField<bool>(
                      title: 'Order',
                      value: sort.index % 2 == 0,
                      items: const {'Ascending': true, 'Descending': false},
                      onChanged: (val) {
                        int index = sort.index;
                        if (!val && index % 2 == 0) {
                          index++;
                        } else if (val && index % 2 != 0) {
                          index--;
                        }
                        sort = MediaSort.values[index];
                      },
                    ),
                    DropDownField<bool?>(
                      title: 'List Filter',
                      value: onList,
                      items: const {
                        'Everything': null,
                        'On List': true,
                        'Not On List': false,
                      },
                      onChanged: (val) => onList = val,
                    ),
                  ],
                ),
              ),
            ).then((_) => ctrl.filter(sort, onList));
          },
        ),
      ),
    );
  }
}
