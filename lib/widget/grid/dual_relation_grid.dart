import 'package:flutter/material.dart';
import 'package:otraku/extension/build_context_extension.dart';
import 'package:otraku/extension/card_extension.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/util/tile_modelable.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/grid/sliver_grid_delegates.dart';

class DualRelationGrid extends StatelessWidget {
  const DualRelationGrid({
    required this.items,
    required this.onTapPrimary,
    required this.onTapSecondary,
    required this.highContrast,
  });

  final List<(TileModelable, TileModelable?)> items;
  final void Function(TileModelable item) onTapPrimary;
  final void Function(TileModelable item) onTapSecondary;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SliverToBoxAdapter();

    final textTheme = TextTheme.of(context);
    final bodyMediumLineHeight = context.lineHeight(textTheme.bodyMedium!);
    final labelSmallLineHeight = context.lineHeight(textTheme.labelSmall!);
    final tileHeight = bodyMediumLineHeight * 3 + labelSmallLineHeight * 2 + 13;
    final imageWidth = tileHeight / Theming.coverHtoWRatio;

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithMinWidthAndFixedHeight(minWidth: 300, height: tileHeight),
      delegate: SliverChildBuilderDelegate(
        childCount: items.length,
        (context, i) => _Tile(
          primaryItem: items[i].$1,
          secondaryItem: items[i].$2,
          onTapPrimary: onTapPrimary,
          onTapSecondary: onTapSecondary,
          highContrast: highContrast,
          imageWidth: imageWidth,
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
    required this.highContrast,
    required this.imageWidth,
  });

  final TileModelable primaryItem;
  final TileModelable? secondaryItem;
  final void Function(TileModelable item) onTapPrimary;
  final void Function(TileModelable item) onTapSecondary;
  final bool highContrast;
  final double imageWidth;

  @override
  Widget build(BuildContext context) {
    late final Widget centerContent;
    if (secondaryItem != null) {
      centerContent = Column(
        crossAxisAlignment: .stretch,
        mainAxisAlignment: .spaceBetween,
        children: [
          Flexible(
            child: GestureDetector(
              behavior: .opaque,
              onTap: () => onTapPrimary(primaryItem),
              child: Column(
                mainAxisSize: .min,
                crossAxisAlignment: .start,
                children: [
                  Flexible(child: Text(primaryItem.tileTitle, overflow: .ellipsis, maxLines: 2)),
                  if (primaryItem.tileSubtitle != null)
                    Text(
                      primaryItem.tileSubtitle!,
                      style: TextTheme.of(context).labelSmall,
                      overflow: .ellipsis,
                      maxLines: 1,
                    ),
                ],
              ),
            ),
          ),
          const Divider(height: 3),
          GestureDetector(
            behavior: .opaque,
            onTap: () => onTapSecondary(secondaryItem!),
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .end,
              children: [
                Flexible(
                  child: Text(
                    secondaryItem!.tileTitle,
                    overflow: .ellipsis,
                    textAlign: .end,
                    maxLines: 1,
                  ),
                ),
                if (secondaryItem!.tileSubtitle != null)
                  Text(
                    secondaryItem!.tileSubtitle!,
                    style: TextTheme.of(context).labelSmall,
                    overflow: .ellipsis,
                    maxLines: 1,
                  ),
              ],
            ),
          ),
        ],
      );
    } else {
      centerContent = GestureDetector(
        behavior: .opaque,
        onTap: () => onTapPrimary(primaryItem),
        child: Column(
          mainAxisAlignment: .start,
          crossAxisAlignment: .start,
          children: [
            Flexible(child: Text(primaryItem.tileTitle, overflow: .ellipsis, maxLines: 2)),
            if (primaryItem.tileSubtitle != null)
              Text(
                primaryItem.tileSubtitle!,
                style: TextTheme.of(context).labelSmall,
                overflow: .ellipsis,
                maxLines: 2,
              ),
          ],
        ),
      );
    }

    return CardExtension.highContrast(highContrast)(
      child: Row(
        children: [
          GestureDetector(
            behavior: .opaque,
            onTap: () => onTapPrimary(primaryItem),
            child: ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Theming.radiusSmall),
              child: CachedImage(primaryItem.tileImageUrl, width: imageWidth),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const .symmetric(horizontal: Theming.offset, vertical: 5),
              child: centerContent,
            ),
          ),
          if (secondaryItem != null)
            GestureDetector(
              behavior: .opaque,
              key: ValueKey(secondaryItem!.tileId),
              onTap: () => onTapSecondary(secondaryItem!),
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(right: Theming.radiusSmall),
                child: CachedImage(secondaryItem!.tileImageUrl, width: imageWidth),
              ),
            ),
        ],
      ),
    );
  }
}
