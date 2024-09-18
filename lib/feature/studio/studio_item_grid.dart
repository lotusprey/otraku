import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:otraku/feature/studio/studio_item_model.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/grid/sliver_grid_delegates.dart';

class StudioItemGrid extends StatelessWidget {
  const StudioItemGrid(this.items);

  final List<StudioItem> items;

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
        minWidth: 230,
        height: 60,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
      ),
      delegate: SliverChildBuilderDelegate(
        childCount: items.length,
        (_, i) => InkWell(
          borderRadius: Theming.borderRadiusSmall,
          onTap: () => context.push(Routes.studio(items[i].id, items[i].name)),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Theming.offset,
              vertical: Theming.offset / 2,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Hero(
                tag: items[i].id,
                child: Text(
                  items[i].name,
                  maxLines: 2,
                  overflow: TextOverflow.fade,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
