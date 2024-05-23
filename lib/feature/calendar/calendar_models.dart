import 'package:flutter/widgets.dart';
import 'package:otraku/util/extensions.dart';
import 'package:otraku/util/persistence.dart';
import 'package:otraku/feature/collection/collection_models.dart';

class CalendarItem {
  const CalendarItem._({
    required this.mediaId,
    required this.title,
    required this.cover,
    required this.episode,
    required this.airingAt,
    required this.entryStatus,
    required this.streamingServices,
  });

  factory CalendarItem(Map<String, dynamic> map) {
    final streamingServices = <StreamingService>[];
    if (map['media']['externalLinks'] != null) {
      for (final link in map['media']['externalLinks']) {
        if (link['type'] == 'STREAMING') {
          streamingServices.add((
            url: link['url'],
            site: link['site'],
            color: link['color'] != null
                ? ColorUtil.fromHexString(link['color'])
                : null,
          ));
        }
      }
    }

    return CalendarItem._(
      mediaId: map['mediaId'],
      title: map['media']['title']['userPreferred'],
      cover: map['media']['coverImage'][Persistence().imageQuality.value],
      episode: map['episode'],
      airingAt: DateTimeUtil.fromSecondsSinceEpoch(map['airingAt']),
      entryStatus: EntryStatus.from(map['media']['mediaListEntry']?['status']),
      streamingServices: streamingServices,
    );
  }

  final int mediaId;
  final String title;
  final String cover;
  final int episode;
  final DateTime airingAt;
  final EntryStatus? entryStatus;
  final List<StreamingService> streamingServices;
}

typedef StreamingService = ({
  String url,
  String site,
  Color? color,
});

class CalendarFilter {
  const CalendarFilter({
    required this.date,
    required this.season,
    required this.status,
  });

  final DateTime date;
  final CalendarSeasonFilter season;
  final CalendarStatusFilter status;

  CalendarFilter copyWith({
    DateTime? date,
    CalendarSeasonFilter? season,
    CalendarStatusFilter? status,
  }) =>
      CalendarFilter(
        date: date ?? this.date,
        season: season ?? this.season,
        status: status ?? this.status,
      );
}

enum CalendarSeasonFilter {
  all('All'),
  current('Current'),
  previous('Previous'),
  other('Other');

  const CalendarSeasonFilter(this.label);

  final String label;
}

enum CalendarStatusFilter {
  all('All'),
  watchingAndPlanning('Watching And Planning'),
  notInLists('Not In Lists'),
  other('Other');

  const CalendarStatusFilter(this.label);

  final String label;
}
