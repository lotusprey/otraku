import 'package:flutter/widgets.dart';
import 'package:otraku/extension/color_extension.dart';
import 'package:otraku/extension/date_time_extension.dart';
import 'package:otraku/extension/iterable_extension.dart';
import 'package:otraku/extension/string_extension.dart';
import 'package:otraku/feature/collection/collection_models.dart';
import 'package:otraku/feature/viewer/persistence_model.dart';
import 'package:otraku/localizations/gen.dart';
import 'package:otraku/util/paged.dart';
import 'package:otraku/feature/edit/edit_model.dart';
import 'package:otraku/feature/tag/tag_model.dart';
import 'package:otraku/util/tile_modelable.dart';

class Media {
  Media(this.entryEdit, this.info, this.stats, this.related);

  EntryEdit entryEdit;
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
  }) => MediaConnections(
    characters: characters ?? this.characters,
    staff: staff ?? this.staff,
    reviews: reviews ?? this.reviews,
    recommendations: recommendations ?? this.recommendations,
    languageToVoiceActors: languageToVoiceActors ?? this.languageToVoiceActors,
    selectedLanguage: selectedLanguage ?? this.selectedLanguage,
  );
}

typedef MediaLanguageMapping = ({String language, Map<int, List<MediaRelatedItem>> voiceActors});

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

  factory RelatedMedia(Map<String, dynamic> map, ImageQuality imageQuality) => RelatedMedia._(
    id: map['node']['id'],
    title: map['node']['title']['userPreferred'],
    imageUrl: map['node']['coverImage'][imageQuality.value],
    relationType: MediaRelationType.from(map['relationType']),
    format: MediaFormat.from(map['node']['format']),
    entryStatus: ListStatus.from(map['node']['mediaListEntry']?['status']),
    releaseStatus: ReleaseStatus.from(map['node']['status']),
    isAnime: map['node']['type'] == 'ANIME',
  );

  final int id;
  final bool isAnime;
  final String title;
  final String imageUrl;
  final MediaRelationType? relationType;
  final MediaFormat? format;
  final ListStatus? entryStatus;
  final ReleaseStatus? releaseStatus;
}

class MediaRelatedItem implements TileModelable {
  const MediaRelatedItem._({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.role,
  });

  factory MediaRelatedItem(Map<String, dynamic> map, String? role) => MediaRelatedItem._(
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
    entryStatus: ListStatus.from(map['status'])!,
    score: (map['score'] ?? 0).toDouble(),
    notes: map['notes'] ?? '',
    userId: map['user']['id'],
    userName: map['user']['name'],
    userAvatar: map['user']['avatar']['large'],
    scoreFormat: ScoreFormat.from(map['user']['mediaListOptions']?['scoreFormat']),
  );

  final ListStatus entryStatus;
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
    final userRating = map['userRating'] == 'RATE_UP'
        ? true
        : map['userRating'] == 'RATE_DOWN'
        ? false
        : null;

    return Recommendation._(
      id: map['mediaRecommendation']['id'],
      rating: map['rating'] ?? 0,
      userRating: userRating,
      title: map['mediaRecommendation']['title']['userPreferred'],
      imageUrl: map['mediaRecommendation']['coverImage'][imageQuality.value],
      isAnime: map['mediaRecommendation']['type'] == 'ANIME',
      releaseYear: map['mediaRecommendation']['startDate']?['year'],
      format: MediaFormat.from(map['mediaRecommendation']['format']),
      entryStatus: ListStatus.from(map['mediaRecommendation']['mediaListEntry']?['status']),
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
  final ListStatus? entryStatus;
}

class MediaInfo {
  MediaInfo._({
    required this.id,
    required this.isAnime,
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
  final bool isAnime;
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
      duration = '${hours != 0 ? '$hours hours ' : ''}${minutes != 0 ? '$minutes mins' : ''}';
    }

    String? season;
    if (map['season'] != null) {
      season = map['season'];
      season = season![0] + season.substring(1).toLowerCase();
      if (map['seasonYear'] != null) season += ' ${map["seasonYear"]}';
    }

    String description = map['description'] ?? '';
    description = description.replaceAll(_forbiddenDescriptionTags, '');

    final model = MediaInfo._(
      id: map['id'],
      isAnime: map['type'] == 'ANIME',
      preferredTitle: map['title']['userPreferred'],
      romajiTitle: map['title']['romaji'],
      englishTitle: map['title']['english'],
      nativeTitle: map['title']['native'],
      synonyms: List<String>.from(map['synonyms'] ?? [], growable: false),
      description: description,
      cover: map['coverImage'][imageQuality.value],
      extraLargeCover: map['coverImage']['extraLarge'],
      banner: map['bannerImage'],
      format: MediaFormat.from(map['format']),
      status: ReleaseStatus.from(map['status']),
      nextEpisode: map['nextAiringEpisode']?['episode'],
      airingAt: DateTimeExtension.tryFromSecondsSinceEpoch(map['nextAiringEpisode']?['airingAt']),
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
          color: link['color'] != null ? ColorExtension.fromHexString(link['color']) : null,
          countryCode: StringExtension.languageToCode(link['language']),
        ));
      }
      model.externalLinks.sort(
        (a, b) =>
            a.type == b.type ? a.site.compareTo(b.site) : a.type.index.compareTo(b.type.index),
      );
    }

    return model;
  }

  /// Unexpected html tags in the description only make rendering harder.
  static final _forbiddenDescriptionTags = RegExp('</?[^bi].?>');
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
    'SOCIAL' => .social,
    'STREAMING' => .streaming,
    _ => .info,
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

  final statusNames = <ListStatus>[];
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

        model.ranks.add(
          MediaRank(
            text: r['type'] == 'RATED'
                ? '#${r["rank"]} Highest Rated $when'
                : '#${r["rank"]} Most Popular $when',
            typeIsScore: r['type'] == 'RATED',
            season: season,
            year: r['year'],
          ),
        );
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

          model.statusNames.insert(index, ListStatus.from(s['status'])!);
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
  threads,
  following,
  activities,
  recommendations,
  statistics,
}

enum MediaType {
  anime('ANIME'),
  manga('MANGA');

  const MediaType(this.value);

  final String value;

  String localize(AppLocalizations l10n) => switch (this) {
    anime => l10n.mediaTypeAnime,
    manga => l10n.mediaTypeManga,
  };
}

enum ReleaseStatus {
  finished('FINISHED'),
  releasing('RELEASING'),
  notYetReleased('NOT_YET_RELEASED'),
  hiatus('HIATUS'),
  cancelled('CANCELLED');

  const ReleaseStatus(this.value);

  final String value;

  static ReleaseStatus? from(String? value) =>
      ReleaseStatus.values.firstWhereOrNull((v) => v.value == value);

  String localize(AppLocalizations l10n) => switch (this) {
    finished => l10n.mediaStatusReleased,
    releasing => l10n.mediaStatusReleasing,
    notYetReleased => l10n.mediaStatusUnreleased,
    hiatus => l10n.mediaStatusHiatus,
    cancelled => l10n.mediaStatusCancelled,
  };
}

enum MediaFormat {
  tv('TV'),
  tvShort('TV_SHORT'),
  movie('MOVIE'),
  special('SPECIAL'),
  ova('OVA'),
  ona('ONA'),
  music('MUSIC'),

  manga('MANGA'),
  novel('NOVEL'),
  oneShot('ONE_SHOT');

  const MediaFormat(this.value);

  final String value;

  static const animeFormats = [tv, tvShort, movie, special, ova, ona, music];
  static const mangaFormats = [manga, novel, oneShot];

  static MediaFormat? from(String? value) =>
      MediaFormat.values.firstWhereOrNull((v) => v.value == value);

  String localize(AppLocalizations l10n) => switch (this) {
    tv => l10n.mediaFormatTv,
    tvShort => l10n.mediaFormatTvShort,
    movie => l10n.mediaFormatMovie,
    special => l10n.mediaFormatSpecial,
    ova => l10n.mediaFormatOva,
    ona => l10n.mediaFormatOna,
    music => l10n.mediaFormatMusic,
    manga => l10n.mediaFormatManga,
    novel => l10n.mediaFormatNovel,
    oneShot => l10n.mediaFormatOneShot,
  };
}

enum MediaSeason {
  winter('WINTER'),
  spring('SPRING'),
  summer('SUMMER'),
  fall('FALL');

  const MediaSeason(this.value);

  final String value;

  static MediaSeason? from(String? value) =>
      MediaSeason.values.firstWhereOrNull((v) => v.value == value);

  String localize(AppLocalizations l10n) => switch (this) {
    winter => l10n.mediaSeasonWinter,
    spring => l10n.mediaSeasonSpring,
    summer => l10n.mediaSeasonSummer,
    fall => l10n.mediaSeasonFall,
  };
}

enum MediaSource {
  original('ORIGINAL'),
  anime('ANIME'),
  manga('MANGA'),
  novel('NOVEL'),
  webNovel('WEB_NOVEL'),
  lightNovel('LIGHT_NOVEL'),
  visualNovel('VISUAL_NOVEL'),
  videoGame('VIDEO_GAME'),
  doujinshi('DOUJINSHI'),
  game('GAME'),
  comic('COMIC'),
  liveAction('LIVE_ACTION'),
  multimediaProject('MULTIMEDIA_PROJECT'),
  pictureBook('PICTURE_BOOK'),
  other('OTHER');

  const MediaSource(this.value);

  final String value;

  static MediaSource? from(String? value) =>
      MediaSource.values.firstWhereOrNull((v) => v.value == value);

  String localize(AppLocalizations l10n) => switch (this) {
    original => l10n.mediaSourceOriginal,
    anime => l10n.mediaSourceAnime,
    manga => l10n.mediaSourceManga,
    novel => l10n.mediaSourceNovel,
    webNovel => l10n.mediaSourceWebNovel,
    lightNovel => l10n.mediaSourceLightNovel,
    visualNovel => l10n.mediaSourceVisualNovel,
    videoGame => l10n.mediaSourceVideoGame,
    doujinshi => l10n.mediaSourceDoujinshi,
    game => l10n.mediaSourceGame,
    comic => l10n.mediaSourceComic,
    liveAction => l10n.mediaSourceLiveAction,
    multimediaProject => l10n.mediaSourceMultimediaProject,
    pictureBook => l10n.mediaSourcePictureBook,
    other => l10n.mediaSourceOther,
  };
}

enum MediaRelationType {
  adaptation('ADAPTATION'),
  prequel('PREQUEL'),
  sequel('SEQUEL'),
  parent('PARENT'),
  sideStory('SIDE_STORY'),
  character('CHARACTER'),
  summary('SUMMARY'),
  alternative('ALTERNATIVE'),
  spinOff('SPIN_OFF'),
  other('OTHER'),
  source('SOURCE'),
  compilation('COMPILATION'),
  contains('CONTAINS');

  const MediaRelationType(this.value);

  final String value;

  static MediaRelationType? from(String? value) =>
      MediaRelationType.values.firstWhereOrNull((v) => v.value == value);

  String localize(AppLocalizations l10n) => switch (this) {
    .adaptation => l10n.mediaRelationTypeAdaptation,
    .prequel => l10n.mediaRelationTypePrequel,
    .sequel => l10n.mediaRelationTypeSequel,
    .parent => l10n.mediaRelationTypeParent,
    .sideStory => l10n.mediaRelationTypeSideStory,
    .character => l10n.mediaRelationTypeCharacter,
    .summary => l10n.mediaRelationTypeSummary,
    .alternative => l10n.mediaRelationTypeAlternative,
    .spinOff => l10n.mediaRelationTypeSpinOff,
    .other => l10n.mediaRelationTypeOther,
    .source => l10n.mediaRelationTypeSource,
    .compilation => l10n.mediaRelationTypeCompilation,
    .contains => l10n.mediaRelationTypeContains,
  };
}

enum OriginCountry {
  japan('JP'),
  china('CN'),
  southKorea('KR'),
  taiwan('TW');

  const OriginCountry(this.code);

  final String code;

  static OriginCountry? fromCode(String? code) =>
      OriginCountry.values.firstWhereOrNull((v) => v.code == code);

  String localize(AppLocalizations l10n) => switch (this) {
    japan => l10n.countryJapan,
    china => l10n.countryChina,
    southKorea => l10n.countrySouthKorea,
    taiwan => l10n.countryTaiwan,
  };
}

enum ScoreFormat {
  point100('POINT_100'),
  point10Decimal('POINT_10_DECIMAL'),
  point10('POINT_10'),
  point5('POINT_5'),
  point3('POINT_3');

  const ScoreFormat(this.value);

  final String value;

  static ScoreFormat from(String? value) =>
      ScoreFormat.values.firstWhere((v) => v.value == value, orElse: () => point10);

  String localize(AppLocalizations l10n) => switch (this) {
    point100 => l10n.mediaScoring100,
    point10Decimal => l10n.mediaScoring10Decimal,
    point10 => l10n.mediaScoring10,
    point5 => l10n.mediaScoring5,
    point3 => l10n.mediaScoring3,
  };
}

enum MediaSort {
  trendingDesc('TRENDING_DESC'),
  popularityDesc('POPULARITY_DESC'),
  scoreDesc('SCORE_DESC'),
  score('SCORE'),
  favoritesDesc('FAVOURITES_DESC'),
  startDateDesc('START_DATE_DESC'),
  startDate('START_DATE'),
  idDesc('ID_DESC'),
  id('ID'),
  titleRomaji('TITLE_ROMAJI'),
  titleEnglish('TITLE_ENGLISH'),
  titleNative('TITLE_NATIVE');

  const MediaSort(this.value);

  final String value;

  String localize(AppLocalizations l10n) => switch (this) {
    trendingDesc => l10n.mediaSortTrending,
    popularityDesc => l10n.mediaSortPopularity,
    scoreDesc => l10n.mediaSortScoreBest,
    score => l10n.mediaSortScoreWorst,
    favoritesDesc => l10n.mediaSortFavourites,
    startDateDesc => l10n.mediaSortReleasedLatest,
    startDate => l10n.mediaSortReleasedEarliest,
    idDesc => l10n.mediaSortAddedLast,
    id => l10n.mediaSortAddedFirst,
    titleRomaji => l10n.mediaSortTitleRomaji,
    titleEnglish => l10n.mediaSortTitleEnglish,
    titleNative => l10n.mediaSortTitleNative,
  };
}

enum EntrySort {
  title,
  titleDesc,
  score,
  scoreDesc,
  updated,
  updatedDesc,
  added,
  addedDesc,
  airing,
  airingDesc,
  startedOn,
  startedOnDesc,
  completedOn,
  completedOnDesc,
  releasedOn,
  releasedOnDesc,
  progress,
  progressDesc,
  avgScore,
  avgScoreDesc,
  repeated,
  repeatedDesc;

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

  String localize(AppLocalizations l10n) => switch (this) {
    title || titleDesc => l10n.listSortTitle,
    score || scoreDesc => l10n.listSortScore,
    updated || updatedDesc => l10n.listSortUpdated,
    added || addedDesc => l10n.listSortAdded,
    airing || airingDesc => l10n.listSortAiring,
    startedOn || startedOnDesc => l10n.listSortStarted,
    completedOn || completedOnDesc => l10n.listSortCompleted,
    releasedOn || releasedOnDesc => l10n.listSortReleased,
    progress || progressDesc => l10n.listSortProgress,
    avgScore || avgScoreDesc => l10n.listSortRating,
    repeated || repeatedDesc => l10n.listSortRepeats,
  };
}
