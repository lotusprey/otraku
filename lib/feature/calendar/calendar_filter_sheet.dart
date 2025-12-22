import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/sheets.dart';
import 'package:otraku/feature/calendar/calendar_filter_provider.dart';
import 'package:otraku/feature/calendar/calendar_models.dart';
import 'package:otraku/widget/input/chip_selector.dart';

void showCalendarFilterSheet(BuildContext context, WidgetRef ref) {
  final highContrast = ref.read(persistenceProvider.select((s) => s.options.highContrast));
  final filter = ref.read(calendarFilterProvider);
  CalendarSeasonFilter season = filter.season;
  CalendarStatusFilter status = filter.status;

  showSheet(
    context,
    SimpleSheet(
      initialHeight: Theming.normalTapTarget * 2 + MediaQuery.paddingOf(context).bottom + 40,
      builder: (context, scrollCtrl) => ListView(
        controller: scrollCtrl,
        physics: Theming.bouncyPhysics,
        padding: const .symmetric(horizontal: Theming.offset, vertical: 20),
        children: [
          ChipSelector(
            title: 'Season',
            items: CalendarSeasonFilter.values.skip(1).map((v) => (v.label, v)).toList(),
            value: season != .all ? season : null,
            onChanged: (v) => season = v ?? .all,
            highContrast: highContrast,
          ),
          ChipSelector(
            title: 'Status',
            items: CalendarStatusFilter.values.skip(1).map((v) => (v.label, v)).toList(),
            value: status != .all ? status : null,
            onChanged: (v) => status = v ?? .all,
            highContrast: highContrast,
          ),
        ],
      ),
    ),
  ).then((_) {
    if (season != filter.season || status != filter.status) {
      ref.read(calendarFilterProvider.notifier).state = filter.copyWith(
        season: season,
        status: status,
      );
    }
  });
}
