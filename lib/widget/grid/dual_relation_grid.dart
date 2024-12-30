import 'package:flutter/material.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/util/tile_modelable.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/grid/sliver_grid_delegates.dart';

class DualRelationGrid extends StatelessWidget {
  const DualRelationGrid({
    required this.items,
    required this.onTapPrimary,
    required this.onTapSecondary,
  });

  final List<(TileModelable, TileModelable?)> items;
  final void Function(TileModelable item) onTapPrimary;
  final void Function(TileModelable item) onTapSecondary;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SliverToBoxAdapter();

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
        minWidth: 300,
        height: 115,
      ),
      delegate: SliverChildBuilderDelegate(
        childCount: items.length,
        (context, i) => _Tile(
          primaryItem: items[i].$1,
          secondaryItem: items[i].$2,
          onTapPrimary: onTapPrimary,
          onTapSecondary: onTapSecondary,
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.primaryItem,
    required this.secondaryItem,
    required this.onTapPrimary,
    required this.onTapSecondary,
  });

  final TileModelable primaryItem;
  final TileModelable? secondaryItem;
  final void Function(TileModelable item) onTapPrimary;
  final void Function(TileModelable item) onTapSecondary;

  @override
  Widget build(BuildContext context) {
    late final Widget centerContent;
    if (secondaryItem != null) {
      centerContent = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTapPrimary(primaryItem),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      primaryItem.tileTitle,
                      maxLines: 2,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                  if (primaryItem.tileSubtitle != null)
                    Text(
                      primaryItem.tileSubtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.fade,
                      style: TextTheme.of(context).labelSmall,
                    ),
                ],
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onTapSecondary(secondaryItem!),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    secondaryItem!.tileTitle,
                    maxLines: 2,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.fade,
                  ),
                ),
                if (secondaryItem!.tileSubtitle != null)
                  Text(
                    secondaryItem!.tileSubtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.fade,
                    style: TextTheme.of(context).labelSmall,
                  ),
              ],
            ),
          ),
        ],
      );
    } else {
      centerContent = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTapPrimary(primaryItem),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Text(primaryItem.tileTitle, overflow: TextOverflow.fade),
            ),
            if (primaryItem.tileSubtitle != null)
              Text(
                primaryItem.tileSubtitle!,
                maxLines: 4,
                overflow: TextOverflow.fade,
                style: TextTheme.of(context).labelSmall,
              ),
          ],
        ),
      );
    }

    return Card(
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onTapPrimary(primaryItem),
            child: ClipRRect(
              borderRadius: Theming.borderRadiusSmall,
              child: CachedImage(primaryItem.tileImageUrl, width: 80),
            ),
          ),
          Expanded(
            child: Padding(padding: Theming.paddingAll, child: centerContent),
          ),
          if (secondaryItem != null)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              key: ValueKey(secondaryItem!.tileId),
              onTap: () => onTapSecondary(secondaryItem!),
              child: ClipRRect(
                borderRadius: Theming.borderRadiusSmall,
                child: CachedImage(secondaryItem!.tileImageUrl, width: 80),
              ),
            ),
        ],
      ),
    );
  }
}
