import 'package:otraku/common/utils/convert.dart';
import 'package:otraku/common/utils/options.dart';

class ScheduleMediaItem {
  ScheduleMediaItem._(
      {required this.id,
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

  factory ScheduleMediaItem(Map<String, dynamic> map) => ScheduleMediaItem._(
        id: map['id'],
        format: Convert.clarifyEnum(map['format']),
        title: map['title']['userPreferred'],
        season: Convert.clarifyEnum(map['season'])!,
        genres: List.from(map['genres'] ?? [], growable: false),
        episodes: map['episodes'],
        listStatus: Convert.clarifyEnum(map['mediaListEntry']?['status']),
        popularity: map['popularity'] ?? 0,
        imageUrl: map['coverImage'][Options().imageQuality.value],
        releaseYear: map['startDate']?['year'],
        isAdult: map['isAdult'] ?? false,
      );

  final int id;
  final String? format;
  final String title;
  final String season;
  final List<String> genres;
  final int? episodes;
  final String? listStatus;
  final int popularity;
  final String imageUrl;
  final int? releaseYear;
  final bool isAdult;
}

class ScheduleAiringScheduleItem {
  ScheduleAiringScheduleItem._({required this.episode, required this.airingAt, required this.timeUntilAiring, required this.media});

  factory ScheduleAiringScheduleItem(Map<String, dynamic> map) =>
      ScheduleAiringScheduleItem._(episode: map['episode'], airingAt: map['airingAt'], timeUntilAiring: map['timeUntilAiring'], media: ScheduleMediaItem(map));

  final int episode;
  final int airingAt;
  final int timeUntilAiring;
  final ScheduleMediaItem media;
}
