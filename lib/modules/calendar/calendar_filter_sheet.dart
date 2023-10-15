import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/common/widgets/overlays/sheets.dart';
import 'package:otraku/modules/calendar/calendar_models.dart';
import 'package:otraku/modules/calendar/calendar_provider.dart';
import 'package:otraku/modules/filter/chip_selector.dart';

void showCalendarFilterSheet(BuildContext context, WidgetRef ref) {
  final filter = ref.read(calendarFilterProvider);
  CalendarSeasonFilter season = filter.season;
  CalendarStatusFilter status = filter.status;

  showSheet(
    context,
    OpaqueSheet(
      initialHeight:
          MediaQuery.of(context).padding.bottom + Consts.tapTargetSize * 3 + 20,
      builder: (context, scrollCtrl) => ListView(
        controller: scrollCtrl,
        physics: Consts.physics,
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: [
          ChipSelector(
            title: 'Season',
            options: const [
              'Current',
              'Previous',
              'Other',
            ],
            current:
                season != CalendarSeasonFilter.All ? season.index - 1 : null,
            onChanged: (v) {
              season = v == null
                  ? CalendarSeasonFilter.All
                  : CalendarSeasonFilter.values[v + 1];
              Options().calendarSeason = season.index;
            },
          ),
          ChipSelector(
            title: 'Status',
            options: const [
              'Watching/Planning',
              'Not In Lists',
              'Other',
            ],
            current:
                status != CalendarStatusFilter.All ? status.index - 1 : null,
            onChanged: (v) {
              status = v == null
                  ? CalendarStatusFilter.All
                  : CalendarStatusFilter.values[v + 1];
              Options().calendarStatus = status.index;
            },
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
