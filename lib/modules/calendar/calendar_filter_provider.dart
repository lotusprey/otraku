import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/utils/persistence.dart';
import 'package:otraku/modules/calendar/calendar_models.dart';

final calendarFilterProvider =
    NotifierProvider.autoDispose<CalendarFilterNotifier, CalendarFilter>(
  CalendarFilterNotifier.new,
);

class CalendarFilterNotifier extends AutoDisposeNotifier<CalendarFilter> {
  @override
  CalendarFilter build() => CalendarFilter(
        date: DateTime.now(),
        season: CalendarSeasonFilter.values[Persistence().calendarSeason],
        status: CalendarStatusFilter.values[Persistence().calendarStatus],
      );

  @override
  set state(CalendarFilter newState) {
    super.state = newState;

    Persistence().calendarSeason = state.season.index;
    Persistence().calendarStatus = state.status.index;
  }
}
