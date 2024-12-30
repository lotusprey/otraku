import 'package:flutter/material.dart';
import 'package:otraku/feature/discover/discover_model.dart';
import 'package:otraku/feature/media/media_route_tile.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/grid/sliver_grid_delegates.dart';
import 'package:otraku/widget/text_rail.dart';

class DiscoverMediaGrid extends StatelessWidget {
  const DiscoverMediaGrid(this.items);

  final List<DiscoverMediaItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SliverFillRemaining(child: Center(child: Text('No Media')));
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
        minWidth: 290,
        height: 110,
      ),
      delegate: SliverChildBuilderDelegate(
        childCount: items.length,
        (context, index) => _Tile(items[index]),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.item);

  final DiscoverMediaItem item;

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

    return Card(
      child: MediaRouteTile(
        id: item.id,
        imageUrl: item.imageUrl,
        child: Row(
          children: [
            Hero(
              tag: item.id,
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Theming.radiusSmall,
                ),
                child: Container(
                  width: 120 / Theming.coverHtoWRatio,
                  color: ColorScheme.of(context).surfaceContainerHighest,
                  child: CachedImage(item.imageUrl),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: Theming.paddingAll,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              item.name,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                          const SizedBox(height: 5),
                          TextRail(
                            textRailItems,
                            style: TextTheme.of(context).labelMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          Icons.percent_rounded,
                          size: 15,
                          color: ColorScheme.of(context).onSurfaceVariant,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          item.averageScore.toString(),
                          style: detailTextStyle,
                        ),
                        const SizedBox(width: 15),
                        Icon(
                          Icons.person_outline_rounded,
                          size: 15,
                          color: ColorScheme.of(context).onSurfaceVariant,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          item.popularity.toString(),
                          style: detailTextStyle,
                        ),
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
