import 'package:flutter/material.dart';
import 'package:otraku/extension/build_context_extension.dart';
import 'package:otraku/extension/card_extension.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/util/tile_modelable.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/grid/sliver_grid_delegates.dart';

class MonoRelationGrid extends StatelessWidget {
  const MonoRelationGrid({required this.items, required this.onTap, required this.highContrast});

  final List<TileModelable> items;
  final void Function(TileModelable item) onTap;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SliverToBoxAdapter();

    final textTheme = TextTheme.of(context);
    final bodyMediumLineHeight = context.lineHeight(textTheme.bodyMedium!);
    final labelSmallLineHeight = context.lineHeight(textTheme.labelSmall!);
    final tileHeight = bodyMediumLineHeight * 2 + labelSmallLineHeight * 2 + 10;
    final imageWidth = tileHeight / Theming.coverHtoWRatio;

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithMinWidthAndFixedHeight(minWidth: 240, height: tileHeight),
      delegate: SliverChildBuilderDelegate(
        childCount: items.length,
        (context, i) =>
            _Tile(item: items[i], onTap: onTap, highContrast: highContrast, imageWidth: imageWidth),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.item,
    required this.onTap,
    required this.highContrast,
    required this.imageWidth,
  });

  final TileModelable item;
  final void Function(TileModelable item) onTap;
  final bool highContrast;
  final double imageWidth;

  @override
  Widget build(BuildContext context) {
    return CardExtension.highContrast(highContrast)(
      child: InkWell(
        borderRadius: Theming.borderRadiusSmall,
        onTap: () => onTap(item),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Theming.radiusSmall),
              child: CachedImage(item.tileImageUrl, width: imageWidth),
            ),
            Expanded(
              child: Padding(
                padding: const .symmetric(horizontal: Theming.offset, vertical: 5),
                child: Column(
                  mainAxisAlignment: .spaceEvenly,
                  crossAxisAlignment: .start,
                  children: [
                    Flexible(child: Text(item.tileTitle, overflow: .ellipsis, maxLines: 2)),
                    if (item.tileSubtitle != null)
                      Text(
                        item.tileSubtitle!,
                        style: TextTheme.of(context).labelSmall,
                        overflow: .ellipsis,
                        maxLines: 2,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
