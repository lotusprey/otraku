import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/extension/date_time_extension.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/feature/viewer/repository_provider.dart';
import 'package:otraku/util/paged.dart';
import 'package:otraku/util/graphql.dart';
import 'package:otraku/feature/calendar/calendar_filter_provider.dart';
import 'package:otraku/feature/calendar/calendar_models.dart';
import 'package:otraku/feature/collection/collection_models.dart';

final calendarProvider = AsyncNotifierProvider.autoDispose<CalendarNotifier, Paged<CalendarItem>>(
  CalendarNotifier.new,
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
    final airingFrom = filter.date.copyWith(hour: 0, minute: 0, second: 0).secondsSinceEpoch;
    final airingTo = filter.date.copyWith(hour: 23, minute: 59, second: 59).secondsSinceEpoch;

    final data = await ref.read(repositoryProvider).request(GqlQuery.calendar, {
      'page': oldState.next,
      'airingFrom': airingFrom,
      'airingTo': airingTo,
    });

    final imageQuality = ref.read(persistenceProvider).options.imageQuality;
    final items = <CalendarItem>[];
    for (final c in data['Page']['airingSchedules']) {
      final season = c['media']['season'];
      final year = c['media']['seasonYear'];
      if (season == null || year == null) continue;

      switch (filter.season) {
        case CalendarSeasonFilter.current:
          final currSeason = _previousAndCurrentSeason().$2;
          if (season != currSeason || year < filter.date.year - 1) continue;
        case CalendarSeasonFilter.previous:
          final prevSeason = _previousAndCurrentSeason().$1;
          if (season != prevSeason || year < filter.date.year - 1) continue;
        case CalendarSeasonFilter.other:
          final (prevSeason, currSeason) = _previousAndCurrentSeason();
          if ((season == prevSeason || season == currSeason) && year >= filter.date.year - 1) {
            continue;
          }
          break;
        case CalendarSeasonFilter.all:
          break;
      }

      final status = c['media']['mediaListEntry']?['status'];
      switch (filter.status) {
        case CalendarStatusFilter.notInLists:
          if (status != null) continue;
        case CalendarStatusFilter.watchingAndPlanning:
          if (status != ListStatus.current.value && status != ListStatus.planning.value) {
            continue;
          }
        case CalendarStatusFilter.other:
          if (status == null ||
              status == ListStatus.current.value ||
              status == ListStatus.planning.value) {
            continue;
          }
        case CalendarStatusFilter.all:
          break;
      }

      items.add(CalendarItem(c, imageQuality));
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
