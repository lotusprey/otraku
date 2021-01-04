import 'package:get/get.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/enums/list_status.dart';
import 'package:otraku/models/date_time_mapping.dart';
import 'package:otraku/services/graph_ql.dart';
import 'package:otraku/models/loadable_list.dart';
import 'package:otraku/models/media_overview.dart';
import 'package:otraku/models/connection.dart';
import 'package:otraku/models/anilist/related_media.dart';
import 'package:otraku/models/tuple.dart';

class Media extends GetxController {
  // ***************************************************************************
  // CONSTANTS
  // ***************************************************************************

  static const _mediaQuery = r'''
    query Media($id: Int, $withMain: Boolean = false, $withCharacters: Boolean = false, 
        $withStaff: Boolean = false, $characterPage: Int = 1, $staffPage: Int = 1) {
      Media(id: $id) {
        ...main @include(if: $withMain)
        ...characters @include(if: $withCharacters)
        ...staff @include(if: $withStaff)
      }
    }
    fragment main on Media {
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
    fragment characters on Media {
      characters(page: $characterPage, sort: [ROLE, ID]) {
        pageInfo {hasNextPage}
        edges {
          role
          voiceActors {id name{full} language image{large}}
          node {id name{full} image{large}}
        }
      }
    }
    fragment staff on Media {
      staff(page: $staffPage) {
        pageInfo {hasNextPage}
        edges {role node {id name{full} image{large}}}
      }
    }
  ''';

  static const _toggleFavouriteAnimeMutation = r'''
    mutation ToggleFavouriteAnime($id: Int) {
      ToggleFavourite(animeId: $id) {
        anime(page: 1, perPage: 1) {pageInfo {currentPage}}
      }
    }
  ''';

  static const _toggleFavouriteMangaMutation = r'''
    mutation ToggleFavouriteManga($id: Int) {
      ToggleFavourite(mangaId: $id) {
        manga(page: 1, perPage: 1) {pageInfo {currentPage}}
      }
    }
  ''';

  static const OVERVIEW = 0;
  static const RELATIONS = 1;
  static const SOCIAL = 2;
  static const REL_MEDIA = 0;
  static const REL_CHARACTERS = 1;
  static const REL_STAFF = 2;

  // ***************************************************************************
  // DATA
  // ***************************************************************************

  final _tab = OVERVIEW.obs;
  final _relationsTab = REL_MEDIA.obs;
  final _overview = Rx<MediaOverview>();
  final _otherMedia = List<RelatedMedia>().obs;
  final _characters = Rx<LoadableList<Connection>>();
  final _staff = Rx<LoadableList<Connection>>();
  final _staffLanguage = 'Japanese'.obs;
  final List<String> _availableLanguages = [];

  int get tab => _tab();

  set tab(int value) => _tab.value = value;

  int get relationsTab => _relationsTab();

  set relationsTab(int value) {
    _relationsTab.value = value;
    if (value == REL_CHARACTERS && _characters() == null)
      fetchRelationPage(true);
    if (value == REL_STAFF && _staff() == null) fetchRelationPage(false);
  }

  MediaOverview get overview => _overview();

  List<RelatedMedia> get otherMedia => _otherMedia();

  LoadableList get characters => _characters();

  LoadableList get staff => _staff();

  String get staffLanguage => _staffLanguage();

  set staffLanguage(String value) => _staffLanguage.value = value;

  int get languageIndex {
    final index = _availableLanguages.indexOf(_staffLanguage());
    if (index != -1) return index;
    return 0;
  }

  List<String> get availableLanguages => [..._availableLanguages];

  // ***************************************************************************
  // FETCHING
  // ***************************************************************************

  Future<void> fetchOverview(int id) async {
    if (_overview.value != null) return;

    final result = await GraphQl.request(_mediaQuery, {
      'id': id,
      'withMain': true,
    });

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
              ListStatus.values,
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

    _otherMedia.addAll(mediaRel);
  }

  Future<void> fetchRelationPage(bool ofCharacters) async {
    final result = await GraphQl.request(_mediaQuery, {
      'id': overview.id,
      'withCharacters': ofCharacters,
      'withStaff': !ofCharacters,
      'characterPage': _characters()?.nextPage,
      'staffPage': _staff()?.nextPage,
    });

    if (result == null) return null;
    final data = result['Media'];

    List<Connection> items = [];
    if (ofCharacters) {
      for (final connection in data['characters']['edges']) {
        final List<Connection> voiceActors = [];

        for (final va in connection['voiceActors']) {
          final language = clarifyEnum(va['language']);
          if (!_availableLanguages.contains(language))
            _availableLanguages.add(language);

          voiceActors.add(Connection(
            id: va['id'],
            title: va['name']['full'],
            imageUrl: va['image']['large'],
            browsable: Browsable.staff,
            subtitle: language,
          ));
        }

        items.add(Connection(
          id: connection['node']['id'],
          title: connection['node']['name']['full'],
          subtitle: clarifyEnum(connection['role']),
          imageUrl: connection['node']['image']['large'],
          others: voiceActors,
          browsable: Browsable.character,
        ));
      }

      if (_characters() == null)
        _characters(
          LoadableList(items, data['characters']['pageInfo']['hasNextPage']),
        );
      else
        _characters.update((list) =>
            list.append(items, data['characters']['pageInfo']['hasNextPage']));
    } else {
      for (final connection in data['staff']['edges']) {
        items.add(Connection(
          id: connection['node']['id'],
          title: connection['node']['name']['full'],
          subtitle: connection['role'],
          imageUrl: connection['node']['image']['large'],
          browsable: Browsable.staff,
        ));
      }

      if (_staff() == null)
        _staff(
          LoadableList(items, data['staff']['pageInfo']['hasNextPage']),
        );
      else
        _staff.update((list) =>
            list.append(items, data['staff']['pageInfo']['hasNextPage']));
    }
  }

  Future<bool> toggleFavourite() async =>
      await GraphQl.request(
        _overview().browsable == Browsable.anime
            ? _toggleFavouriteAnimeMutation
            : _toggleFavouriteMangaMutation,
        {'id': _overview().id},
        popOnError: false,
      ) !=
      null;
}
