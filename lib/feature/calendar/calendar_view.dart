import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/extension/date_time_extension.dart';
import 'package:otraku/feature/media/media_route_tile.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/layout/adaptive_scaffold.dart';
import 'package:otraku/widget/layout/hiding_floating_action_button.dart';
import 'package:otraku/widget/layout/navigation_tool.dart';
import 'package:otraku/widget/layout/top_bar.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/widget/paged_view.dart';
import 'package:otraku/widget/text_rail.dart';
import 'package:otraku/feature/calendar/calendar_filter_provider.dart';
import 'package:otraku/feature/calendar/calendar_filter_sheet.dart';
import 'package:otraku/feature/calendar/calendar_models.dart';
import 'package:otraku/feature/calendar/calendar_provider.dart';

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
        final options = ref.watch(persistenceProvider.select((s) => s.options));
        final date = ref.watch(calendarFilterProvider.select((s) => s.date));
        final today = DateTime.now();
        final isBeforeToday = date.day < today.day &&
            date.month == today.month &&
            date.year == today.year;

        return AdaptiveScaffold(
          (context, compact) => ScaffoldConfig(
            topBar: const TopBar(title: 'Calendar'),
            floatingAction: HidingFloatingActionButton(
              key: const Key('filter'),
              scrollCtrl: _scrollCtrl,
              child: FloatingActionButton(
                tooltip: 'Filter',
                onPressed: () => showCalendarFilterSheet(context, ref),
                child: const Icon(Ionicons.funnel_outline),
              ),
            ),
            bottomBar: BottomBar([
              const SizedBox(width: Theming.offset),
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
                  child: Text(date.formattedWithWeekDay),
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
              const SizedBox(width: Theming.offset),
            ]),
            child: PagedView(
              provider: calendarProvider,
              scrollCtrl: _scrollCtrl,
              onRefresh: (invalidate) => invalidate(calendarProvider),
              onData: (data) => SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _Tile(data.items[i], options.analogClock),
                  childCount: data.items.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  mainAxisExtent: 120,
                  mainAxisSpacing: Theming.offset,
                  crossAxisSpacing: Theming.offset,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _setDate(WidgetRef ref, DateTime date) {
    final filter = ref.read(calendarFilterProvider);
    ref.read(calendarFilterProvider.notifier).state = filter.copyWith(
      date: date,
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.item, this.analogClock);

  final CalendarItem item;
  final bool analogClock;

  @override
  Widget build(BuildContext context) {
    final textRailItems = {
      item.airingAt.formattedTime(analogClock): true,
      if (item.airingAt.isAfter(DateTime.now()))
        'Ep ${item.episode} in ${item.airingAt.timeUntil}': false
      else
        'Ep ${item.episode}': false,
    };

    if (item.entryStatus != null) {
      textRailItems[item.entryStatus!.label(true)] = true;
    }

    const contentPadding = EdgeInsets.symmetric(horizontal: Theming.offset);

    return Card(
      child: MediaRouteTile(
        id: item.mediaId,
        imageUrl: item.cover,
        child: Row(
          children: [
            Hero(
              tag: item.mediaId,
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Theming.radiusSmall,
                ),
                child: Container(
                  width: 120 / Theming.coverHtoWRatio,
                  color: ColorScheme.of(context).surfaceContainerHighest,
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
                        style: TextTheme.of(context).labelMedium,
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
      padding: const EdgeInsets.only(
        left: Theming.offset,
        right: Theming.offset / 2,
      ),
      itemCount: links.length,
      itemBuilder: (context, i) {
        return Padding(
          padding: const EdgeInsets.only(right: Theming.offset / 2),
          child: ActionChip(
            onPressed: () => SnackBarExtension.launch(context, links[i].url),
            label: Text(links[i].site),
            avatar: links[i].color != null
                ? Container(
                    height: 15,
                    width: 15,
                    decoration: BoxDecoration(
                      borderRadius: Theming.borderRadiusSmall,
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
