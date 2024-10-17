import 'package:flutter/widgets.dart';
import 'package:otraku/extension/color_extension.dart';
import 'package:otraku/extension/date_time_extension.dart';
import 'package:otraku/extension/iterable_extension.dart';
import 'package:otraku/extension/string_extension.dart';
import 'package:otraku/feature/collection/collection_models.dart';
import 'package:otraku/feature/viewer/persistence_model.dart';
import 'package:otraku/util/paged.dart';
import 'package:otraku/feature/discover/discover_model.dart';
import 'package:otraku/feature/edit/edit_model.dart';
import 'package:otraku/feature/tag/tag_models.dart';
import 'package:otraku/util/tile_modelable.dart';

class Media {
  Media(this.edit, this.info, this.stats, this.related);

  Edit edit;
  final MediaInfo info;
  final MediaStats stats;
  final List<RelatedMedia> related;
}

class MediaConnections {
  const MediaConnections({
    this.characters = const Paged(),
    this.staff = const Paged(),
    this.reviews = const Paged(),
    this.recommendations = const Paged(),
    this.languageToVoiceActors = const [],
    this.selectedLanguage = 0,
  });

  final Paged<MediaRelatedItem> characters;
  final Paged<MediaRelatedItem> staff;
  final Paged<RelatedReview> reviews;
  final Paged<Recommendation> recommendations;

  /// For each language, a list of voice actors
  /// is mapped to the corresponding media's id.
  final List<MediaLanguageMapping> languageToVoiceActors;
  final int selectedLanguage;

  /// Returns the characters, along with their voice actors,
  /// corresponding to the current [language]. If there are
  /// multiple actors, the given character is repeated for each actor.
  Paged<(MediaRelatedItem, MediaRelatedItem?)> getCharactersAndVoiceActors() {
    if (languageToVoiceActors.isEmpty) {
      return Paged(
        items: characters.items.map((c) => (c, null)).toList(),
        hasNext: characters.hasNext,
        next: characters.next,
      );
    }

    final actorsPerMedia = languageToVoiceActors[selectedLanguage].voiceActors;

    final charactersAndVoiceActors = <(MediaRelatedItem, MediaRelatedItem?)>[];
    for (final c in characters.items) {
      final actors = actorsPerMedia[c.id];
      if (actors == null || actors.isEmpty) {
        charactersAndVoiceActors.add((c, null));
        continue;
      }

      for (final va in actors) {
        charactersAndVoiceActors.add((c, va));
      }
    }

    return Paged(
      items: charactersAndVoiceActors,
      hasNext: characters.hasNext,
      next: characters.next,
    );
  }

  MediaConnections copyWith({
    Paged<MediaRelatedItem>? characters,
    Paged<MediaRelatedItem>? staff,
    Paged<RelatedReview>? reviews,
    Paged<Recommendation>? recommendations,
    List<MediaLanguageMapping>? languageToVoiceActors,
    int? selectedLanguage,
  }) =>
      MediaConnections(
        characters: characters ?? this.characters,
        staff: staff ?? this.staff,
        reviews: reviews ?? this.reviews,
        recommendations: recommendations ?? this.recommendations,
        languageToVoiceActors:
            languageToVoiceActors ?? this.languageToVoiceActors,
        selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      );
}

typedef MediaLanguageMapping = ({
  String language,
  Map<int, List<MediaRelatedItem>> voiceActors,
});

class RelatedMedia {
  const RelatedMedia._({
    required this.id,
    required this.isAnime,
    required this.title,
    required this.imageUrl,
    required this.relationType,
    required this.format,
    required this.entryStatus,
    required this.releaseStatus,
  });

  factory RelatedMedia(Map<String, dynamic> map, ImageQuality imageQuality) =>
      RelatedMedia._(
        id: map['node']['id'],
        title: map['node']['title']['userPreferred'],
        imageUrl: map['node']['coverImage'][imageQuality.value],
        relationType:
            StringExtension.tryNoScreamingSnakeCase(map['relationType']),
        format: MediaFormat.from(map['node']['format']),
        entryStatus: EntryStatus.from(map['node']['mediaListEntry']?['status']),
        releaseStatus: StringExtension.tryNoScreamingSnakeCase(
          map['node']['status'],
        ),
        isAnime: map['node']['type'] == 'ANIME',
      );

  final int id;
  final bool isAnime;
  final String title;
  final String imageUrl;
  final String? relationType;
  final MediaFormat? format;
  final EntryStatus? entryStatus;
  final String? releaseStatus;
}

class MediaRelatedItem implements TileModelable {
  const MediaRelatedItem._({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.role,
  });

  factory MediaRelatedItem(Map<String, dynamic> map, String? role) =>
      MediaRelatedItem._(
        id: map['id'],
        name: map['name']['userPreferred'],
        imageUrl: map['image']['large'],
        role: role,
      );

  final int id;
  final String name;
  final String imageUrl;
  final String? role;

  @override
  int get tileId => id;

  @override
  String get tileTitle => name;

  @override
  String? get tileSubtitle => role;

  @override
  String get tileImageUrl => imageUrl;
}

class RelatedReview {
  const RelatedReview._({
    required this.reviewId,
    required this.userId,
    required this.avatar,
    required this.username,
    required this.summary,
    required this.rating,
    required this.score,
  });

  static RelatedReview? maybe(Map<String, dynamic> map) {
    if (map['user'] == null) return null;

    return RelatedReview._(
      reviewId: map['id'],
      userId: map['user']['id'],
      username: map['user']['name'] ?? '',
      summary: map['summary'] ?? '',
      avatar: map['user']['avatar']['large'],
      rating: '${map['rating']}/${map['ratingAmount']}',
      score: map['score'] ?? 0,
    );
  }

  final int reviewId;
  final int userId;
  final String username;
  final String avatar;
  final String summary;
  final String rating;
  final int score;
}

class MediaFollowing {
  MediaFollowing._({
    required this.entryStatus,
    required this.score,
    required this.notes,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.scoreFormat,
  });

  factory MediaFollowing(Map<String, dynamic> map) => MediaFollowing._(
        entryStatus: EntryStatus.from(map['status'])!,
        score: (map['score'] ?? 0).toDouble(),
        notes: map['notes'] ?? '',
        userId: map['user']['id'],
        userName: map['user']['name'],
        userAvatar: map['user']['avatar']['large'],
        scoreFormat: ScoreFormat.from(
          map['user']['mediaListOptions']?['scoreFormat'],
        ),
      );

  final EntryStatus entryStatus;
  final double score;
  final String notes;
  final int userId;
  final String userName;
  final String userAvatar;
  final ScoreFormat scoreFormat;
}

class Recommendation {
  Recommendation._({
    required this.id,
    required this.rating,
    required this.userRating,
    required this.title,
    required this.imageUrl,
    required this.isAnime,
    required this.releaseYear,
    required this.format,
    required this.entryStatus,
  });

  factory Recommendation(Map<String, dynamic> map, ImageQuality imageQuality) {
    bool? userRating;
    if (map['userRating'] == 'RATE_UP') userRating = true;
    if (map['userRating'] == 'RATE_DOWN') userRating = false;

    return Recommendation._(
      id: map['mediaRecommendation']['id'],
      rating: map['rating'] ?? 0,
      userRating: userRating,
      title: map['mediaRecommendation']['title']['userPreferred'],
      imageUrl: map['mediaRecommendation']['coverImage'][imageQuality.value],
      isAnime: map['type'] == 'ANIME',
      releaseYear: map['mediaRecommendation']['startDate']?['year'],
      format: MediaFormat.from(map['mediaRecommendation']['format']),
      entryStatus: EntryStatus.from(
          map['mediaRecommendation']['mediaListEntry']?['status']),
    );
  }

  final int id;
  int rating;
  bool? userRating;
  final String title;
  final String imageUrl;
  final bool isAnime;
  final int? releaseYear;
  final MediaFormat? format;
  final EntryStatus? entryStatus;
}

class MediaInfo {
  MediaInfo._({
    required this.id,
    required this.type,
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
    required this.favourites,
    required this.isFavorite,
    required this.genres,
    required this.source,
    required this.hashtag,
    required this.siteUrl,
    required this.countryOfOrigin,
    required this.isAdult,
  });

  final int id;
  final DiscoverType type;
  final String? preferredTitle;
  final String? romajiTitle;
  final String? englishTitle;
  final String? nativeTitle;
  final List<String> synonyms;
  final String description;
  final String cover;
  final String extraLargeCover;
  final String? banner;
  final MediaFormat? format;
  final ReleaseStatus? status;
  final int? nextEpisode;
  final DateTime? airingAt;
  final int? episodes;
  final String? duration;
  final int? chapters;
  final int? volumes;
  final String? startDate;
  final String? endDate;
  final String? season;
  final int averageScore;
  final int meanScore;
  final int popularity;
  final int favourites;
  bool isFavorite;
  final List<String> genres;
  final studios = <String, int>{};
  final producers = <String, int>{};
  final tags = <Tag>[];
  final MediaSource? source;
  final String? hashtag;
  final String? siteUrl;
  final OriginCountry? countryOfOrigin;
  final bool isAdult;
  final externalLinks = <ExternalLink>[];

  factory MediaInfo(Map<String, dynamic> map, ImageQuality imageQuality) {
    String? duration;
    if (map['duration'] != null) {
      final time = map['duration'];
      final hours = time ~/ 60;
      final minutes = time % 60;
      duration =
          '${hours != 0 ? '$hours hours ' : ''}${minutes != 0 ? '$minutes mins' : ''}';
    }

    String? season;
    if (map['season'] != null) {
      season = map['season'];
      season = season![0] + season.substring(1).toLowerCase();
      if (map['seasonYear'] != null) season += ' ${map["seasonYear"]}';
    }

    final model = MediaInfo._(
      id: map['id'],
      type: map['type'] == 'ANIME' ? DiscoverType.anime : DiscoverType.manga,
      preferredTitle: map['title']['userPreferred'],
      romajiTitle: map['title']['romaji'],
      englishTitle: map['title']['english'],
      nativeTitle: map['title']['native'],
      synonyms: List<String>.from(map['synonyms'] ?? [], growable: false),
      description: map['description'] ?? '',
      cover: map['coverImage'][imageQuality.value],
      extraLargeCover: map['coverImage']['extraLarge'],
      banner: map['bannerImage'],
      format: MediaFormat.from(map['format']),
      status: ReleaseStatus.from(map['status']),
      nextEpisode: map['nextAiringEpisode']?['episode'],
      airingAt: DateTimeExtension.tryFromSecondsSinceEpoch(
        map['nextAiringEpisode']?['airingAt'],
      ),
      episodes: map['episodes'],
      duration: duration,
      chapters: map['chapters'],
      volumes: map['volumes'],
      startDate: StringExtension.fromFuzzyDate(map['startDate']),
      endDate: StringExtension.fromFuzzyDate(map['endDate']),
      season: season,
      averageScore: map['averageScore'] ?? 0,
      meanScore: map['meanScore'] ?? 0,
      popularity: map['popularity'] ?? 0,
      favourites: map['favourites'] ?? 0,
      isFavorite: map['isFavourite'] ?? false,
      genres: List<String>.from(map['genres'] ?? [], growable: false),
      source: MediaSource.from(map['source']),
      hashtag: map['hashtag'],
      siteUrl: map['siteUrl'],
      countryOfOrigin: OriginCountry.fromCode(map['countryOfOrigin']),
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

    if (map['externalLinks'] != null) {
      for (final link in map['externalLinks']) {
        model.externalLinks.add((
          url: link['url'],
          site: link['site'],
          type: ExternalLinkType.fromString(link['type']),
          color: link['color'] != null
              ? ColorExtension.fromHexString(link['color'])
              : null,
          countryCode: StringExtension.languageToCode(link['language']),
        ));
      }
      model.externalLinks.sort(
        (a, b) => a.type == b.type
            ? a.site.compareTo(b.site)
            : a.type.index.compareTo(b.type.index),
      );
    }

    return model;
  }
}

typedef ExternalLink = ({
  String url,
  String site,
  ExternalLinkType type,
  Color? color,
  String? countryCode,
});

enum ExternalLinkType {
  info,
  social,
  streaming;

  static ExternalLinkType fromString(String? str) => switch (str) {
        'SOCIAL' => ExternalLinkType.social,
        'STREAMING' => ExternalLinkType.streaming,
        _ => ExternalLinkType.info,
      };
}

class MediaRank {
  const MediaRank({
    required this.text,
    required this.typeIsScore,
    required this.season,
    required this.year,
  });

  final String text;
  final bool typeIsScore;
  final MediaSeason? season;
  final int? year;
}

class MediaStats {
  MediaStats._();

  final ranks = <MediaRank>[];

  final scoreNames = <int>[];
  final scoreValues = <int>[];

  final statusNames = <String>[];
  final statusValues = <int>[];

  factory MediaStats(Map<String, dynamic> map) {
    final model = MediaStats._();

    // The key is the text and the value signals
    // if the rank is about rating or popularity.
    if (map['rankings'] != null) {
      for (final r in map['rankings']) {
        final season = MediaSeason.from(r['season']);

        final String when = (r['allTime'] ?? false)
            ? 'Ever'
            : season != null
                ? '${season.label} ${r['year'] ?? ''}'
                : (r['year'] ?? '').toString();
        if (when.isEmpty) continue;

        model.ranks.add(MediaRank(
          text: r['type'] == 'RATED'
              ? '#${r["rank"]} Highest Rated $when'
              : '#${r["rank"]} Most Popular $when',
          typeIsScore: r['type'] == 'RATED',
          season: season,
          year: r['year'],
        ));
      }
    }

    if (map['stats'] != null) {
      if (map['stats']['scoreDistribution'] != null) {
        for (final s in map['stats']['scoreDistribution']) {
          model.scoreNames.add(s['score']);
          model.scoreValues.add(s['amount']);
        }
      }

      if (map['stats']['statusDistribution'] != null) {
        for (final s in map['stats']['statusDistribution']) {
          int index = -1;
          for (int i = 0; i < model.statusValues.length; i++) {
            if (model.statusValues[i] < s['amount']) {
              model.statusValues.insert(i, s['amount']);
              index = i;
              break;
            }
          }

          if (index < 0) {
            index = model.statusValues.length;
            model.statusValues.add(s['amount']);
          }

          model.statusNames.insert(
            index,
            EntryStatus.from(s['status'])!.label(map['type'] == 'ANIME'),
          );
        }
      }
    }

    return model;
  }
}

enum MediaTab {
  info,
  relations,
  characters,
  staff,
  reviews,
  following,
  recommendations,
  statistics,
}

enum MediaType {
  anime('Anime', 'ANIME'),
  manga('Manga', 'MANGA');

  const MediaType(this.label, this.value);

  final String label;
  final String value;
}

enum ReleaseStatus {
  finished('Finished', 'FINISHED'),
  releasing('Releasing', 'RELEASING'),
  notYetReleased('Not Yet Released', 'NOT_YET_RELEASED'),
  hiatus('Hiatus', 'HIATUS'),
  cancelled('Cancelled', 'CANCELLED');

  const ReleaseStatus(this.label, this.value);

  final String label;
  final String value;

  static ReleaseStatus? from(String? value) =>
      ReleaseStatus.values.firstWhereOrNull((v) => v.value == value);
}

enum MediaFormat {
  tv('TV', 'TV'),
  tvShort('TV Short', 'TV_SHORT'),
  movie('Movie', 'MOVIE'),
  special('Special', 'SPECIAL'),
  ova('OVA', 'OVA'),
  ona('ONA', 'ONA'),
  music('Music', 'MUSIC'),

  manga('Manga', 'MANGA'),
  novel('Novel', 'NOVEL'),
  oneShot('One Shot', 'ONE_SHOT');

  const MediaFormat(this.label, this.value);

  final String label;
  final String value;

  static const animeFormats = [tv, tvShort, movie, special, ova, ona, music];
  static const mangaFormats = [manga, novel, oneShot];

  static MediaFormat? from(String? value) =>
      MediaFormat.values.firstWhereOrNull((v) => v.value == value);
}

enum MediaSeason {
  winter('Winter', 'WINTER'),
  spring('Spring', 'SPRING'),
  summer('Summer', 'SUMMER'),
  fall('Fall', 'FALL');

  const MediaSeason(this.label, this.value);

  final String label;
  final String value;

  static MediaSeason? from(String? value) =>
      MediaSeason.values.firstWhereOrNull((v) => v.value == value);
}

enum MediaSource {
  original('Original', 'ORIGINAL'),
  anime('Anime', 'ANIME'),
  manga('Manga', 'MANGA'),
  novel('Novel', 'NOVEL'),
  webNovel('Web Novel', 'WEB_NOVEL'),
  lightNovel('Light Novel', 'LIGHT_NOVEL'),
  visualNovel('Visual Novel', 'VISUAL_NOVEL'),
  videoGame('Video Game', 'VIDEO_GAME'),
  doujinshi('Doujinshi', 'DOUJINSHI'),
  game('Game', 'GAME'),
  comic('Comic', 'COMIC'),
  liveAction('Live Action', 'LIVE_ACTION'),
  multimediaProject('Multimedia Project', 'MULTIMEDIA_PROJECT'),
  pictureBook('Picture Book', 'PICTURE_BOOK'),
  other('Other', 'OTHER');

  const MediaSource(this.label, this.value);

  final String label;
  final String value;

  static MediaSource? from(String? value) =>
      MediaSource.values.firstWhereOrNull((v) => v.value == value);
}

enum OriginCountry {
  japan('Japan', 'JP'),
  china('China', 'CN'),
  southKorea('South Korea', 'KR'),
  taiwan('Taiwan', 'TW');

  const OriginCountry(this.label, this.code);

  final String label;
  final String code;

  static OriginCountry? fromCode(String? code) =>
      OriginCountry.values.firstWhereOrNull((v) => v.code == code);
}

enum ScoreFormat {
  point100('100 Points', 'POINT_100'),
  point10Decimal('10 Decimal Points', 'POINT_10_DECIMAL'),
  point10('10 Points', 'POINT_10'),
  point5('5 Stars', 'POINT_5'),
  point3('3 Smileys', 'POINT_3');

  const ScoreFormat(this.label, this.value);

  final String label;
  final String value;

  static ScoreFormat from(String? value) => ScoreFormat.values.firstWhere(
        (v) => v.value == value,
        orElse: () => point10,
      );
}

enum MediaSort {
  trendingDesc('Trending', 'TRENDING_DESC'),
  popularityDesc('Popularity', 'POPULARITY_DESC'),
  scoreDesc('Score', 'SCORE_DESC'),
  score('Worst Score', 'SCORE'),
  favoritesDesc('Favourites', 'FAVOURITES_DESC'),
  startDateDesc('Released Latest', 'START_DATE_DESC'),
  startDate('Released Earliest', 'START_DATE'),
  idDesc('Last Added', 'ID_DESC'),
  id('First Added', 'ID'),
  titleRomaji('Title Romaji', 'TITLE_ROMAJI'),
  titleEnglish('Title English', 'TITLE_ENGLISH'),
  titleNative('Title Native', 'TITLE_NATIVE');

  const MediaSort(this.label, this.value);

  final String label;
  final String value;
}

enum EntrySort {
  title('Title'),
  titleDesc('Title'),
  score('Score'),
  scoreDesc('Score'),
  updated('Updated'),
  updatedDesc('Updated'),
  added('Added'),
  addedDesc('Added'),
  airing('Airing'),
  airingDesc('Airing'),
  startedOn('Started'),
  startedOnDesc('Started'),
  completedOn('Completed'),
  completedOnDesc('Completed'),
  releasedOn('Released'),
  releasedOnDesc('Released'),
  progress('Progress'),
  progressDesc('Progress'),
  avgScore('Rating'),
  avgScoreDesc('Rating'),
  repeated('Repeats'),
  repeatedDesc('Repeats');

  const EntrySort(this.label);

  final String label;

  /// The API supports only few default sortings.
  static const rowOrders = [scoreDesc, title, updatedDesc, addedDesc];

  /// Serialize to API row order.
  String toRowOrder() => switch (this) {
        scoreDesc => 'score',
        updatedDesc => 'updatedAt',
        addedDesc => 'id',
        title => 'title',
        _ => 'title',
      };

  /// Deserialize from API row order.
  static EntrySort fromRowOrder(String key) => switch (key) {
        'score' => scoreDesc,
        'updatedAt' => updatedDesc,
        'id' => addedDesc,
        'title' => title,
        _ => title,
      };
}
