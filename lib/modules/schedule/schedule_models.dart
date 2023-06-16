import 'package:otraku/common/utils/convert.dart';
import 'package:otraku/common/utils/options.dart';

class ScheduleAiringScheduleItem {
  ScheduleAiringScheduleItem._({
    required this.episode,
    required this.airingAt,
    required this.timeUntilAiring,
    required this.id,
    required this.title,
    required this.format,
    required this.episodes,
    required this.listStatus,
    required this.progress,
    required this.popularity,
    required this.imageUrl,
  });

  factory ScheduleAiringScheduleItem(Map<String, dynamic> map) =>
      ScheduleAiringScheduleItem._(
        episode: map['episode'],
        airingAt: map['airingAt'],
        timeUntilAiring: map['timeUntilAiring'],
        id: map['media']['id'],
        title: map['media']['title']['userPreferred'],
        format: Convert.clarifyEnum(map['media']['format']),
        episodes: map['media']['episodes'],
        listStatus:
            Convert.clarifyEnum(map['media']['mediaListEntry']?['status']),
        progress: map['media']['mediaListEntry']?['progress'],
        popularity: map['media']['popularity'] ?? 0,
        imageUrl: map['media']['coverImage'][Options().imageQuality.value],
      );

  final int episode;
  final int airingAt;
  final int timeUntilAiring;
  final int id;
  final String title;
  final String? format;
  final int? episodes;
  final String? listStatus;
  final int? progress;
  final int popularity;
  final String imageUrl;
}
