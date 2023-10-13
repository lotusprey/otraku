import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/models/paged.dart';
import 'package:otraku/common/utils/api.dart';
import 'package:otraku/common/utils/extensions.dart';
import 'package:otraku/common/utils/graphql.dart';
import 'package:otraku/modules/calendar/calendar_models.dart';
import 'package:otraku/modules/collection/collection_models.dart';

final calendarFilterProvider = StateProvider.autoDispose(
  (ref) => CalendarFilter(
    date: DateTime.now(),
    season: CalendarSeasonFilter.All,
    status: CalendarStatusFilter.All,
  ),
);

final calendarProvider = StateNotifierProvider.autoDispose<CalendarNotifier,
    AsyncValue<Paged<CalendarItem>>>(
  (ref) => CalendarNotifier(ref.watch(calendarFilterProvider)),
);

class CalendarNotifier extends StateNotifier<AsyncValue<Paged<CalendarItem>>> {
  CalendarNotifier(this.filter) : super(const AsyncValue.loading()) {
    fetch();
  }

  final CalendarFilter filter;

  Future<void> fetch() async {
    state = await AsyncValue.guard(() async {
      final value = state.valueOrNull ?? const Paged();

      final now = DateTime.now().secondsSinceEpoch;
      final airingFrom =
          filter.date.copyWith(hour: 0, minute: 0, second: 0).secondsSinceEpoch;
      final airingTo = filter.date
          .copyWith(hour: 23, minute: 59, second: 59)
          .secondsSinceEpoch;

      final data = await Api.get(GqlQuery.calendar, {
        'page': value.next,
        'airingFrom': airingFrom > now ? airingFrom : now,
        'airingTo': airingTo,
      });

      final items = <CalendarItem>[];
      for (final c in data['Page']['airingSchedules']) {
        final season = c['media']['season'];
        final year = c['media']['seasonYear'];
        switch (filter.season) {
          case CalendarSeasonFilter.Current:
            final currSeason = _previousAndCurrentSeason().$2;
            if (season != currSeason || year < filter.date.year - 1) continue;
          case CalendarSeasonFilter.Previous:
            final prevSeason = _previousAndCurrentSeason().$1;
            if (season != prevSeason || year < filter.date.year - 1) continue;
          case CalendarSeasonFilter.Other:
            final (prevSeason, currSeason) = _previousAndCurrentSeason();
            if ((season == prevSeason || season == currSeason) &&
                year >= filter.date.year - 1) {
              continue;
            }
            break;
          case CalendarSeasonFilter.All:
            break;
        }

        final status = c['media']['mediaListEntry']?['status'];
        switch (filter.status) {
          case CalendarStatusFilter.NotInLists:
            if (status != null) continue;
          case CalendarStatusFilter.WatchingAndPlanning:
            if (status != EntryStatus.CURRENT.name &&
                status != EntryStatus.PLANNING.name) {
              continue;
            }
          case CalendarStatusFilter.Other:
            if (status == null ||
                status == EntryStatus.CURRENT.name ||
                status == EntryStatus.PLANNING.name) {
              continue;
            }
          case CalendarStatusFilter.All:
            break;
        }

        items.add(CalendarItem(c));
      }

      return value.withNext(
        items,
        data['Page']['pageInfo']['hasNextPage'] ?? false,
      );
    });
  }

  (String, String) _previousAndCurrentSeason() => switch (filter.date.month) {
        >= 3 && <= 5 => ('WINTER', 'SPRING'),
        >= 6 && <= 8 => ('SPRING', 'SUMMER'),
        >= 9 && <= 11 => ('SUMMER', 'FALL'),
        _ => ('FALL', 'WINTER'),
      };
}
