import 'package:flutter/material.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/modules/discover/discover_models.dart';
import 'package:otraku/common/widgets/cached_image.dart';
import 'package:otraku/common/widgets/link_tile.dart';
import 'package:otraku/common/widgets/text_rail.dart';
import 'package:otraku/modules/schedule/schedule_models.dart';
import 'package:intl/intl.dart';

class ScheduleMediaGrid extends StatelessWidget {
  const ScheduleMediaGrid(
    this.items,
  );

  final List<List<ScheduleAiringScheduleItem>> items;

  @override
  Widget build(BuildContext context) {
    debugPrint('Items.length ${items.length}');
    if (items.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Text('No Media'),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: items.length,
        (context, index) => _DayGroup(
          items[index],
          DateFormat('EEEE').format(
            DateTime.now().add(
              Duration(days: index),
            ),
          ),
        ),
      ),
    );
  }
}

class _DayGroup extends StatelessWidget {
  const _DayGroup(this.items, this.day);

  final List<ScheduleAiringScheduleItem> items;
  final String day;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: (120 * items.length + 72).toDouble(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(text: day),
            textScaleFactor: 2,
          ),
          for (var item in items)
            Padding(
              padding: EdgeInsets.only(top: Consts.padding.top),
              child: SizedBox(
                height: 110,
                child: _Tile(item),
              ),
            )
        ],
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

    if (item.format != null) textRailItems[item.format!] = false;
    textRailItems['Episode ${item.episode}'] = false;
    if (item.listStatus != null) {
      textRailItems[item.listStatus!] = true;
    }
    if (item.isAdult) textRailItems['Adult'] = true;

    final detailTextStyle = Theme.of(context).textTheme.labelSmall;

    return Card(
      child: LinkTile(
        id: item.id,
        discoverType: DiscoverType.anime,
        info: item.imageUrl,
        child: Row(
          children: [
            Hero(
              tag: item.id,
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Consts.radiusMin,
                ),
                child: Container(
                  width: 120 / Consts.coverHtoWRatio,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: CachedImage(item.imageUrl),
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
                              item.title,
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
