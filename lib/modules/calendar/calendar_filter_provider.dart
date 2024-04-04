import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/modules/calendar/calendar_models.dart';

final calendarFilterProvider =
    NotifierProvider.autoDispose<CalendarFilterNotifier, CalendarFilter>(
  CalendarFilterNotifier.new,
);

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
