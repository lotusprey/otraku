import 'package:flutter/material.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/modules/discover/discover_models.dart';
import 'package:otraku/common/widgets/cached_image.dart';
import 'package:otraku/common/widgets/grids/sliver_grid_delegates.dart';
import 'package:otraku/common/widgets/link_tile.dart';
import 'package:otraku/common/widgets/text_rail.dart';
import 'package:otraku/modules/schedule/schedule_models.dart';

class ScheduleMediaGrid extends StatelessWidget {
  const ScheduleMediaGrid(this.items);

  final List<ScheduleAiringScheduleItem> items;

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

  final ScheduleAiringScheduleItem item;

  @override
  Widget build(BuildContext context) {
    final textRailItems = <String, bool>{};

    if (item.media.format != null) textRailItems[item.media.format!] = false;
    textRailItems['Episode ${item.episode}'] = false;
    if (item.media.listStatus != null) textRailItems[item.media.listStatus!] = true;
    if (item.media.isAdult) textRailItems['Adult'] = true;

    final detailTextStyle = Theme.of(context).textTheme.labelSmall;

    return Card(
      child: LinkTile(
        id: item.media.id,
        discoverType: DiscoverType.anime,
        info: item.media.imageUrl,
        child: Row(
          children: [
            Hero(
              tag: item.media.id,
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Consts.radiusMin,
                ),
                child: Container(
                  width: 120 / Consts.coverHtoWRatio,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: CachedImage(item.media.imageUrl),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: Consts.padding,
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
                              item.media.title,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                          const SizedBox(height: 5),
                          TextRail(
                            textRailItems,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 15,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          item.media.popularity.toString(),
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
