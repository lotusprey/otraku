import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/common/utils/extensions.dart';
import 'package:otraku/common/widgets/cached_image.dart';
import 'package:otraku/common/widgets/layouts/bottom_bar.dart';
import 'package:otraku/common/widgets/layouts/floating_bar.dart';
import 'package:otraku/common/widgets/layouts/scaffolds.dart';
import 'package:otraku/common/widgets/layouts/top_bar.dart';
import 'package:otraku/common/widgets/link_tile.dart';
import 'package:otraku/common/widgets/overlays/toast.dart';
import 'package:otraku/common/widgets/paged_view.dart';
import 'package:otraku/common/widgets/text_rail.dart';
import 'package:otraku/modules/calendar/calendar_filter_sheet.dart';
import 'package:otraku/modules/calendar/calendar_models.dart';
import 'package:otraku/modules/calendar/calendar_provider.dart';
import 'package:otraku/modules/discover/discover_models.dart';

class CalendarView extends StatefulWidget {
  const CalendarView();

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    super.dispose();
    _scrollCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final date = ref.watch(calendarFilterProvider.select((s) => s.date));
        final today = DateTime.now();
        final isBeforeToday = date.day < today.day &&
            date.month == today.month &&
            date.year == today.year;

        return PageScaffold(
          bottomBar: BottomBar([
            const SizedBox(width: 10),
            SizedBox(
              width: 60,
              child: isBeforeToday
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded),
                      onPressed: () => _setDate(
                        ref,
                        date.subtract(const Duration(days: 1)),
                      ),
                    ),
            ),
            Expanded(
              child: TextButton(
                onPressed: () => showDatePicker(
                  context: context,
                  initialDate: date,
                  firstDate: today.add(const Duration(days: -1)),
                  lastDate: today.add(const Duration(days: 150)),
                ).then((newDate) {
                  if (newDate != null && newDate != date) {
                    _setDate(ref, newDate);
                  }
                }),
                child: Text(
                  '${date.formattedDate} - ${date.formattedWeekday}',
                ),
              ),
            ),
            SizedBox(
              width: 60,
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded),
                onPressed: () => _setDate(
                  ref,
                  date.add(const Duration(days: 1)),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ]),
          child: TabScaffold(
            topBar: const TopBar(title: 'Calendar'),
            floatingBar: FloatingBar(
              scrollCtrl: _scrollCtrl,
              children: [
                ActionButton(
                  tooltip: 'Filter',
                  icon: Ionicons.funnel_outline,
                  onTap: () => showCalendarFilterSheet(context, ref),
                ),
              ],
            ),
            child: PagedView(
              provider: calendarProvider,
              scrollCtrl: _scrollCtrl,
              onRefresh: () => ref.invalidate(calendarProvider),
              onData: (data) => SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _Tile(data.items[i]),
                  childCount: data.items.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  mainAxisExtent: 120,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _setDate(WidgetRef ref, DateTime date) => ref
      .read(calendarFilterProvider.notifier)
      .update((s) => s.copyWith(date: date));
}

class _Tile extends StatelessWidget {
  const _Tile(this.item);

  final CalendarItem item;

  @override
  Widget build(BuildContext context) {
    final textRailItems = {
      item.airingAt.formattedTime: true,
      if (item.airingAt.isAfter(DateTime.now()))
        'Ep ${item.episode} in ${item.airingAt.timeUntil}': false
      else
        'Ep ${item.episode}': false,
    };
    if (item.entryStatus != null) textRailItems[item.entryStatus!] = true;

    const contentPadding = EdgeInsets.symmetric(horizontal: 10);

    return Card(
      child: LinkTile(
        id: item.mediaId,
        info: item.cover,
        discoverType: DiscoverType.Anime,
        child: Row(
          children: [
            Hero(
              tag: item.mediaId,
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Consts.radiusMin,
                ),
                child: Container(
                  width: 120 / Consts.coverHtoWRatio,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: CachedImage(item.cover),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: contentPadding,
                        child: Text(
                          item.title,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ),
                    Padding(
                      padding: contentPadding,
                      child: TextRail(
                        textRailItems,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                    if (item.streamingServices.isNotEmpty)
                      SizedBox(
                        height: 35,
                        child: _ExternalLinkList(item.streamingServices),
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

class _ExternalLinkList extends StatelessWidget {
  const _ExternalLinkList(this.links);

  final List<StreamingService> links;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 10, right: 5),
      itemCount: links.length,
      itemBuilder: (context, i) {
        return Padding(
          padding: const EdgeInsets.only(right: 5),
          child: ActionChip(
            onPressed: () => Toast.launch(context, links[i].url),
            label: Text(links[i].site),
            avatar: links[i].color != null
                ? Container(
                    height: 15,
                    width: 15,
                    decoration: BoxDecoration(
                      borderRadius: Consts.borderRadiusMin,
                      color: links[i].color,
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }
}
