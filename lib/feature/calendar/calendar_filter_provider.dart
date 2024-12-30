import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/feature/calendar/calendar_models.dart';

final calendarFilterProvider =
    NotifierProvider.autoDispose<CalendarFilterNotifier, CalendarFilter>(
  CalendarFilterNotifier.new,
);

class CalendarFilterNotifier extends AutoDisposeNotifier<CalendarFilter> {
  @override
  CalendarFilter build() => ref
      .watch(persistenceProvider.select((s) => s.calendarFilter))
      .copyWith(date: DateTime.now());

  @override
  set state(CalendarFilter newState) {
    ref.read(persistenceProvider.notifier).setCalendarFilter(newState);
  }
}
