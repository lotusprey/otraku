import 'package:flutter/material.dart';
import 'package:otraku/extension/build_context_extension.dart';
import 'package:otraku/extension/card_extension.dart';
import 'package:otraku/feature/discover/discover_model.dart';
import 'package:otraku/feature/media/media_route_tile.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/grid/sliver_grid_delegates.dart';
import 'package:otraku/widget/text_rail.dart';

class DiscoverMediaGrid extends StatelessWidget {
  const DiscoverMediaGrid(this.items, {required this.highContrast});

  final List<DiscoverMediaItem> items;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SliverFillRemaining(child: Center(child: Text('No Media')));
    }

    final textTheme = TextTheme.of(context);
    final bodyMediumLineHeight = context.lineHeight(textTheme.bodyMedium!);
    final labelMediumLineHeight = context.lineHeight(textTheme.labelMedium!);
    final labelSmallLineHeight = context.lineHeight(textTheme.labelSmall!);
    final tileHeight = bodyMediumLineHeight + labelMediumLineHeight * 2 + labelSmallLineHeight + 16;

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithMinWidthAndFixedHeight(minWidth: 290, height: tileHeight),
      delegate: SliverChildBuilderDelegate(
        childCount: items.length,
        (context, index) => _Tile(items[index], highContrast, tileHeight),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.item, this.highContrast, this.tileHeight);

  final DiscoverMediaItem item;
  final bool highContrast;
  final double tileHeight;

  @override
  Widget build(BuildContext context) {
    final textRailItems = <String, bool>{};
    if (item.format != null) textRailItems[item.format!] = false;
    if (item.releaseStatus != null) {
      textRailItems[item.releaseStatus!.label] = false;
    }
    if (item.releaseYear != null) {
      textRailItems[item.releaseYear!.toString()] = false;
    }

    if (item.entryStatus != null) {
      textRailItems[item.entryStatus!.label(item.isAnime)] = true;
    }

    if (item.isAdult) textRailItems['Adult'] = true;

    final detailTextStyle = TextTheme.of(context).labelSmall;

    return CardExtension.highContrast(highContrast)(
      child: MediaRouteTile(
        id: item.id,
        imageUrl: item.imageUrl,
        child: Row(
          children: [
            Hero(
              tag: item.id,
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Theming.radiusSmall),
                child: Container(
                  width: tileHeight / Theming.coverHtoWRatio,
                  color: ColorScheme.of(context).surfaceContainerHighest,
                  child: CachedImage(item.imageUrl),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: .symmetric(horizontal: Theming.offset, vertical: 5),
                child: Column(
                  crossAxisAlignment: .start,
                  mainAxisAlignment: .spaceAround,
                  spacing: 3,
                  children: [
                    Flexible(
                      child: Column(
                        mainAxisSize: .min,
                        crossAxisAlignment: .start,
                        mainAxisAlignment: .spaceBetween,
                        spacing: 3,
                        children: [
                          Flexible(child: Text(item.name, overflow: .ellipsis, maxLines: 2)),
                          TextRail(textRailItems, style: TextTheme.of(context).labelMedium),
                        ],
                      ),
                    ),
                    Row(
                      spacing: 5,
                      children: [
                        Icon(
                          Icons.percent_rounded,
                          size: 15,
                          color: ColorScheme.of(context).onSurfaceVariant,
                        ),
                        Text(
                          item.averageScore.toString(),
                          style: detailTextStyle,
                          overflow: .ellipsis,
                          maxLines: 1,
                        ),
                        Icon(
                          Icons.person_outline_rounded,
                          size: 15,
                          color: ColorScheme.of(context).onSurfaceVariant,
                        ),
                        Text(item.popularity.toString(), style: detailTextStyle),
                      ],
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
