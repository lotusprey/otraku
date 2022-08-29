import 'package:otraku/discover/discover_models.dart';
import 'package:otraku/tag/tag_models.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/settings.dart';

class MediaInfoModel {
  final int id;
  final DiscoverType type;
  final int? favourites;
  bool isFavourite;
  final String? preferredTitle;
  final String? romajiTitle;
  final String? englishTitle;
  final String? nativeTitle;
  final List<String> synonyms;
  final String cover;
  final String extraLargeCover;
  final String? banner;
  final String description;
  final String? format;
  final String? status;
  final int? nextEpisode;
  final int? airingAt;
  final int? episodes;
  final String? duration;
  final int? chapters;
  final int? volumes;
  final String? startDate;
  final String? endDate;
  final String? season;
  final String? averageScore;
  final String? meanScore;
  final int? popularity;
  final List<String> genres;
  final studios = <String, int>{};
  final producers = <String, int>{};
  final tags = <Tag>[];
  final String? source;
  final String? hashtag;
  final String? siteUrl;
  final String? countryOfOrigin;
  final bool isAdult;

  MediaInfoModel._({
    required this.id,
    required this.type,
    required this.favourites,
    required this.isFavourite,
    required this.preferredTitle,
    required this.romajiTitle,
    required this.englishTitle,
    required this.nativeTitle,
    required this.synonyms,
    required this.cover,
    required this.extraLargeCover,
    required this.banner,
    required this.description,
    required this.format,
    required this.status,
    required this.nextEpisode,
    required this.airingAt,
    required this.episodes,
    required this.duration,
    required this.chapters,
    required this.volumes,
    required this.startDate,
    required this.endDate,
    required this.season,
    required this.averageScore,
    required this.meanScore,
    required this.popularity,
    required this.genres,
    required this.source,
    required this.hashtag,
    required this.siteUrl,
    required this.countryOfOrigin,
    required this.isAdult,
  });

  factory MediaInfoModel(Map<String, dynamic> map) {
    String? duration;
    if (map['duration'] != null) {
      int time = map['duration'];
      int hours = time ~/ 60;
      int minutes = time % 60;
      duration = '${hours != 0 ? '$hours hours, ' : ''}$minutes mins';
    }

    String? season;
    if (map['season'] != null) {
      season = map['season'];
      season = season![0] + season.substring(1).toLowerCase();
      if (map['seasonYear'] != null) season += ' ${map["seasonYear"]}';
    }

    final model = MediaInfoModel._(
      id: map['id'],
      type: map['type'] == 'ANIME' ? DiscoverType.anime : DiscoverType.manga,
      isFavourite: map['isFavourite'] ?? false,
      favourites: map['favourites'],
      preferredTitle: map['title']['userPreferred'],
      romajiTitle: map['title']['romaji'],
      englishTitle: map['title']['english'],
      nativeTitle: map['title']['native'],
      synonyms: List<String>.from(map['synonyms'] ?? [], growable: false),
      cover: map['coverImage'][Settings().imageQuality],
      extraLargeCover: map['coverImage']['extraLarge'],
      banner: map['bannerImage'],
      description: Convert.clearHtml(map['description']),
      format: Convert.clarifyEnum(map['format']),
      status: Convert.clarifyEnum(map['status']),
      nextEpisode: map['nextAiringEpisode']?['episode'],
      airingAt: map['nextAiringEpisode']?['airingAt'],
      episodes: map['episodes'],
      duration: duration,
      chapters: map['chapters'],
      volumes: map['volumes'],
      startDate: Convert.mapToDateStr(map['startDate']),
      endDate: Convert.mapToDateStr(map['endDate']),
      season: season,
      averageScore:
          map['averageScore'] != null ? '${map["averageScore"]}%' : null,
      meanScore: map['meanScore'] != null ? '${map["meanScore"]}%' : null,
      popularity: map['popularity'],
      genres: List<String>.from(map['genres'] ?? [], growable: false),
      source: Convert.clarifyEnum(map['source']),
      hashtag: map['hashtag'],
      siteUrl: map['siteUrl'],
      countryOfOrigin: Convert.countryCodes[map['countryOfOrigin']],
      isAdult: map['isAdult'] ?? false,
    );

    if (map['studios'] != null) {
      final List<dynamic> companies = map['studios']['edges'];
      for (final company in companies) {
        if (company['isMain']) {
          model.studios[company['node']['name']] = company['node']['id'];
        } else {
          model.producers[company['node']['name']] = company['node']['id'];
        }
      }
    }

    if (map['tags'] != null) {
      for (final tag in map['tags']) {
        model.tags.add(Tag(tag));
      }
    }

    return model;
  }
}
