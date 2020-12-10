import 'package:get/get.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/enums/media_list_status_enum.dart';
import 'package:otraku/models/date_time_mapping.dart';
import 'package:otraku/controllers/network_service.dart';
import 'package:otraku/models/page_data/media_overview.dart';
import 'package:otraku/models/sample_data/related_media.dart';
import 'package:otraku/models/tuple.dart';

class Media extends GetxController {
  static const _mediaQuery = r'''
    query Media($id: Int) {
      Media(id: $id) {
        type
        title {userPreferred english romaji native}
        synonyms
        coverImage {extraLarge}
        bannerImage
        isFavourite
        favourites
        mediaListEntry {status}
        nextAiringEpisode {episode timeUntilAiring}
        description
        format
        status(version: 2)
        episodes
        duration
        chapters
        volumes
        season
        seasonYear
        averageScore
        meanScore
        popularity
        startDate {year month day}
        endDate {year month day}
        genres
        studios {edges {isMain node {id name}}}
        source
        hashtag
        countryOfOrigin
        relations {
          edges {
            relationType(version: 2)
            node {
              id
              type
              format
              title {userPreferred} 
              status(version: 2)
              coverImage {large}
            }
          }
        }
      }
    }
  ''';

  static const OVERVIEW = 0;
  static const RELATIONS = 1;
  static const SOCIAL = 2;
  static const REL_MEDIA = 0;
  static const REL_CHARACTERS = 1;
  static const REL_STAFF = 2;

  final _tab = OVERVIEW.obs;
  final _relationsTab = REL_MEDIA.obs;
  final _overview = Rx<MediaOverview>();
  final _mediaRelations = List<RelatedMedia>().obs;

  int get tab => _tab();

  set tab(int value) => _tab.value = value;

  int get relationsTab => _relationsTab();

  set relationsTab(int value) => _relationsTab.value = value;

  MediaOverview get overview => _overview();

  List<RelatedMedia> get mediaRelations => _mediaRelations();

  Future<void> fetchOverview(int id) async {
    if (_overview.value != null) return;

    final result = await NetworkService.request(_mediaQuery, {'id': id});

    if (result == null) return null;
    final data = result['Media'];

    String duration;
    if (data['duration'] != null) {
      int time = data['duration'];
      int hours = time ~/ 60;
      int minutes = time % 60;
      duration = (hours != 0 ? '$hours hours, ' : '') + '$minutes mins';
    }

    String season;
    if (data['season'] != null) {
      season = data['season'];
      season = season[0] + season.substring(1).toLowerCase();
      if (data['seasonYear'] != null) {
        season += ' ${data["seasonYear"]}';
      }
    }

    List<int> studioId = [];
    List<String> studioName = [];
    List<int> producerId = [];
    List<String> producerName = [];
    if (data['studios'] != null) {
      final List<dynamic> companies = data['studios']['edges'];
      for (final company in companies) {
        if (company['isMain']) {
          studioId.add(company['node']['id']);
          studioName.add(company['node']['name']);
        } else {
          producerId.add(company['node']['id']);
          producerName.add(company['node']['name']);
        }
      }
    }

    _overview(MediaOverview(
      id: id,
      browsable: data['type'] == 'ANIME' ? Browsable.anime : Browsable.manga,
      isFavourite: data['isFavourite'],
      favourites: data['favourites'],
      preferredTitle: data['title']['userPreferred'],
      romajiTitle: data['title']['romaji'],
      englishTitle: data['title']['english'],
      nativeTitle: data['title']['native'],
      synonyms: List<String>.from(data['synonyms']),
      cover: data['coverImage']['extraLarge'] ?? data['coverImage']['large'],
      banner: data['bannerImage'],
      description: data['description'] != null
          ? data['description'].replaceAll(RegExp(r'<[^>]*>'), '')
          : null,
      format: clarifyEnum(data['format']),
      status: clarifyEnum(data['status']),
      entryStatus: data['mediaListEntry'] != null
          ? stringToEnum(
              data['mediaListEntry']['status'].toString(),
              MediaListStatus.values,
            )
          : null,
      nextEpisode: data['nextAiringEpisode'] != null
          ? data['nextAiringEpisode']['episode']
          : null,
      timeUntilAiring: data['nextAiringEpisode'] != null
          ? secondsToTime(data['nextAiringEpisode']['timeUntilAiring'])
          : null,
      episodes: data['episodes'],
      duration: duration,
      chapters: data['chapters'],
      volumes: data['volumes'],
      startDate:
          data['startDate'] != null ? mapToDateString(data['startDate']) : null,
      endDate:
          data['endDate'] != null ? mapToDateString(data['endDate']) : null,
      season: season,
      averageScore:
          data['averageScore'] != null ? '${data["averageScore"]}%' : null,
      meanScore: data['meanScore'] != null ? '${data["meanScore"]}%' : null,
      popularity: data['popularity'],
      genres: List<String>.from(data['genres']),
      studios: Tuple(studioId, studioName),
      producers: Tuple(producerId, producerName),
      source: clarifyEnum(data['source']),
      hashtag: data['hashtag'],
      countryOfOrigin: data['countryOfOrigin'],
    ));

    List<RelatedMedia> mediaRel = [];
    for (final relation in data['relations']['edges']) {
      mediaRel.add(RelatedMedia(
        id: relation['node']['id'],
        title: relation['node']['title']['userPreferred'],
        relationType: clarifyEnum(relation['relationType']),
        format: clarifyEnum(relation['node']['format']),
        status: clarifyEnum(relation['node']['status']),
        imageUrl: relation['node']['coverImage']['large'],
        browsable: relation['node']['type'] == 'ANIME'
            ? Browsable.anime
            : Browsable.manga,
      ));
    }

    _mediaRelations.addAll(mediaRel);
  }
}
