import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/models/paged.dart';
import 'package:otraku/common/utils/api.dart';
import 'package:otraku/common/utils/extensions.dart';
import 'package:otraku/common/utils/graphql.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/modules/calendar/calendar_models.dart';
import 'package:otraku/modules/collection/collection_models.dart';

final calendarProvider =
    AsyncNotifierProvider.autoDispose<CalendarNotifier, Paged<CalendarItem>>(
  CalendarNotifier.new,
);

final calendarFilterProvider =
    NotifierProvider.autoDispose<CalendarFilterNotifier, CalendarFilter>(
  CalendarFilterNotifier.new,
);

class CalendarNotifier extends AutoDisposeAsyncNotifier<Paged<CalendarItem>> {
  late CalendarFilter filter;

  @override
  FutureOr<Paged<CalendarItem>> build() async {
    filter = ref.watch(calendarFilterProvider);
    return await _fetch(const Paged());
  }

  Future<void> fetch(bool onAnime) async {
    final oldState = state.valueOrNull ?? const Paged();
    if (!oldState.hasNext) return;
    state = await AsyncValue.guard(() => _fetch(oldState));
  }

  Future<Paged<CalendarItem>> _fetch(Paged<CalendarItem> oldState) async {
    final airingFrom =
        filter.date.copyWith(hour: 0, minute: 0, second: 0).secondsSinceEpoch;
    final airingTo = filter.date
        .copyWith(hour: 23, minute: 59, second: 59)
        .secondsSinceEpoch;

    final data = await Api.get(GqlQuery.calendar, {
      'page': oldState.next,
      'airingFrom': airingFrom,
      'airingTo': airingTo,
    });

    final items = <CalendarItem>[];
    for (final c in data['Page']['airingSchedules']) {
      final season = c['media']['season'];
      final year = c['media']['seasonYear'];
      if (season == null || year == null) continue;

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

    return oldState.withNext(
      items,
      data['Page']['pageInfo']['hasNextPage'] ?? false,
    );
  }

  (String, String) _previousAndCurrentSeason() => switch (filter.date.month) {
        >= 3 && <= 5 => ('WINTER', 'SPRING'),
        >= 6 && <= 8 => ('SPRING', 'SUMMER'),
        >= 9 && <= 11 => ('SUMMER', 'FALL'),
        _ => ('FALL', 'WINTER'),
      };
}

class CalendarFilterNotifier extends AutoDisposeNotifier<CalendarFilter> {
  @override
  CalendarFilter build() => CalendarFilter(
        date: DateTime.now(),
        season: CalendarSeasonFilter.values[Options().calendarSeason],
        status: CalendarStatusFilter.values[Options().calendarStatus],
      );

  @override
  set state(CalendarFilter newState) {
    super.state = newState;

    Options().calendarSeason = state.season.index;
    Options().calendarStatus = state.status.index;
  }
}
