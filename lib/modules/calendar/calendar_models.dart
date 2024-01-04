import 'package:flutter/widgets.dart';
import 'package:otraku/common/utils/extensions.dart';
import 'package:otraku/common/utils/image_quality.dart';
import 'package:otraku/modules/collection/collection_models.dart';

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
      cover: map['media']['coverImage'][imageQuality],
      episode: map['episode'],
      airingAt: DateTimeUtil.fromSecondsSinceEpoch(map['airingAt']),
      entryStatus: EntryStatus.formatText(
        map['media']['mediaListEntry']?['status'],
        true,
      ),
      streamingServices: streamingServices,
    );
  }

  final int mediaId;
  final String title;
  final String cover;
  final int episode;
  final DateTime airingAt;
  final String? entryStatus;
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
  All,
  Current,
  Previous,
  Other,
}

enum CalendarStatusFilter {
  All,
  WatchingAndPlanning,
  NotInLists,
  Other,
}
