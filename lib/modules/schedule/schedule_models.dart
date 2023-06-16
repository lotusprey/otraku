import 'package:otraku/common/utils/convert.dart';
import 'package:otraku/common/utils/options.dart';

class ScheduleAiringScheduleItem {
  ScheduleAiringScheduleItem._(
      {required this.episode,
      required this.airingAt,
      required this.timeUntilAiring,
      required this.id,
      required this.format,
      required this.title,
      required this.season,
      required this.genres,
      required this.episodes,
      required this.listStatus,
      required this.popularity,
      required this.imageUrl,
      required this.releaseYear,
      required this.isAdult});

  factory ScheduleAiringScheduleItem(Map<String, dynamic> map) =>
      ScheduleAiringScheduleItem._(
        episode: map['episode'],
        airingAt: map['airingAt'],
        timeUntilAiring: map['timeUntilAiring'],
        id: map['media']['id'],
        format: Convert.clarifyEnum(map['media']['format']),
        title: map['media']['title']['userPreferred'],
        season: Convert.clarifyEnum(map['media']['season']),
        genres: List.from(map['media']['genres'] ?? [], growable: false),
        episodes: map['media']['episodes'],
        listStatus:
            Convert.clarifyEnum(map['media']['mediaListEntry']?['status']),
        popularity: map['media']['popularity'] ?? 0,
        imageUrl: map['media']['coverImage'][Options().imageQuality.value],
        releaseYear: map['media']['startDate']?['year'],
        isAdult: map['media']['isAdult'] ?? false,
      );

  final int episode;
  final int airingAt;
  final int timeUntilAiring;
  final int id;
  final String? format;
  final String title;
  final String? season;
  final List<String> genres;
  final int? episodes;
  final String? listStatus;
  final int popularity;
  final String imageUrl;
  final int? releaseYear;
  final bool isAdult;
}
