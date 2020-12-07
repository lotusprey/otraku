import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/enums/media_sort_enum.dart';
import 'package:otraku/models/sample_data/browse_result.dart';
import 'package:otraku/models/tuple.dart';
import 'package:otraku/controllers/network_service.dart';

//Manages all browsable media, genres, tags and all the filters
class Explorable extends GetxController {
  // ***************************************************************************
  // CONSTANTS
  // ***************************************************************************

  static const STATUS_IN = 'status_in';
  static const STATUS_NOT_IN = 'status_not_in';
  static const FORMAT_IN = 'format_in';
  static const FORMAT_NOT_IN = 'format_not_in';
  static const ID_NOT_IN = 'id_not_in';
  static const GENRE_IN = 'genre_in';
  static const GENRE_NOT_IN = 'genre_not_in';
  static const TAG_IN = 'tag_in';
  static const TAG_NOT_IN = 'tag_not_in';
  static const IS_ADULT = 'isAdult';
  static const SEARCH = 'search';
  static const TYPE = 'type';
  static const SORT = 'sort';
  static const PAGE = 'page';

  static const _mediaQuery = r'''
    query Media($page: Int, $type: MediaType, $search:String, $status_in: [MediaStatus],
        $status_not_in: [MediaStatus], $format_in: [MediaFormat], $format_not_in: [MediaFormat], 
        $genre_in: [String], $genre_not_in: [String], $tag_in: [String], $tag_not_in: [String], 
        $onList: Boolean, $isAdult: Boolean, $startDate_greater: FuzzyDateInt, 
        $startDate_lesser: FuzzyDateInt, $countryOfOrigin: CountryCode, $source: MediaSource, 
        $season: MediaSeason, $id_not_in: [Int], $sort: [MediaSort]) {
      Page(page: $page, perPage: 30) {
        pageInfo {hasNextPage}
        media(type: $type, search: $search, status_in: $status_in, status_not_in: $status_not_in, 
        format_in: $format_in, format_not_in: $format_not_in, genre_in: $genre_in, 
        genre_not_in: $genre_not_in, tag_in: $tag_in, tag_not_in: $tag_not_in, 
        onList: $onList, isAdult: $isAdult, startDate_greater: $startDate_greater, 
        startDate_lesser: $startDate_lesser, countryOfOrigin: $countryOfOrigin, 
        source: $source, season: $season, id_not_in: $id_not_in, sort: $sort) {
          id
          title {userPreferred}
          coverImage {large}
        }
      }
    }
  ''';

  static const _charactersQuery = r'''
    query Characters($page: Int, $search: String, $id_not_in: [Int]) {
      Page(page: $page, perPage: 30) {
        pageInfo {hasNextPage}
        characters(search: $search, id_not_in: $id_not_in, sort: FAVOURITES_DESC) {
          id
          name {full}
          image {large}
        }
      }
    }
  ''';

  static const _staffQuery = r'''
    query Staff($page: Int, $search: String, $id_not_in: [Int]) {
      Page(page: $page, perPage: 30) {
        pageInfo {hasNextPage}
        staff(search: $search, id_not_in: $id_not_in, sort: FAVOURITES_DESC) {
          id
          name {full}
          image {large}
        }
      }
    }
  ''';

  static const _studiosQuery = r'''
    query Studios($page: Int, $search: String, $id_not_in: [Int]) {
      Page(page: $page, perPage: 30) {
        pageInfo {hasNextPage}
        studios(search: $search, id_not_in: $id_not_in) {
          id
          name
        }
      }
    }
  ''';

  // ***************************************************************************
  // DATA
  // ***************************************************************************

  final _isLoading = false.obs;
  final _hasNextPage = true.obs;
  final _results = List<BrowseResult>().obs;
  final _type = Browsable.anime.obs;
  final _search = ''.obs;
  int _concurrentFetches = 0;
  List<String> _genres;
  Tuple<List<String>, List<String>> _tags;
  Map<String, dynamic> _filters = {
    PAGE: 1,
    TYPE: 'ANIME',
    SORT: describeEnum(MediaSort.TRENDING_DESC),
    ID_NOT_IN: [],
  };

  // ***************************************************************************
  // GETTERS
  // ***************************************************************************

  bool get isLoading => _isLoading();

  bool get hasNextPage => _hasNextPage();

  Browsable get type => _type();

  String get search => _search();

  List<BrowseResult> get results => [..._results()];

  List<String> get genres => [..._genres];

  Tuple<List<String>, List<String>> get tags => _tags;

  // ***************************************************************************
  // FUNCTIONS CONTROLLING QUERY VARIABLES
  // ***************************************************************************

  @override
  void onInit() {
    super.onInit();
    debounce(_search, (_) => fetchData(),
        time: const Duration(milliseconds: 600));
  }

  set type(Browsable value) {
    if (value == null) return;
    _type.value = value;

    if (value == Browsable.anime) _filters[TYPE] = 'ANIME';
    if (value == Browsable.manga) _filters[TYPE] = 'MANGA';

    _filters.remove(FORMAT_IN);
    _filters.remove(FORMAT_NOT_IN);
    fetchData();
  }

  set search(String value) {
    if (value == null) {
      _search.value = '';
    } else {
      _search.value = value.trim();
    }
  }

  dynamic getFilterWithKey(String key) => _filters[key];

  void setFilterWithKey(
    String key, {
    dynamic value,
    bool refetch = false,
  }) {
    if (value == null ||
        (value is List && value.isEmpty) ||
        (value is String && value.trim().isEmpty)) {
      _filters.remove(key);
    } else {
      _filters[key] = value;
    }

    if (refetch) fetchData();
  }

  void clearAllFilters({bool fetch = true}) => clearFiltersWithKeys([
        STATUS_IN,
        STATUS_NOT_IN,
        FORMAT_IN,
        FORMAT_NOT_IN,
        GENRE_IN,
        GENRE_NOT_IN,
        TAG_IN,
        TAG_NOT_IN,
      ], fetch: fetch);

  void clearFiltersWithKeys(List<String> keys, {bool fetch = true}) {
    for (final key in keys) {
      _filters.remove(key);
    }

    if (fetch) fetchData();
  }

  bool anyActiveFilterFrom(List<String> keys) {
    for (final key in keys) {
      if (_filters.containsKey(key)) return true;
    }
    return false;
  }

  void loadMore() {
    _filters[PAGE]++;
    fetchData(clean: false);
  }

  // ***************************************************************************
  // DATA FETCHING
  // ***************************************************************************

  Future<void> fetchData({bool clean = true}) async {
    _concurrentFetches++;

    if (clean) {
      _isLoading.value = true;
      _filters[ID_NOT_IN] = [];
      _filters[PAGE] = 1;
    }

    final currentType = _type.value;
    String query;
    Map<String, dynamic> variables;

    if (currentType == Browsable.anime || currentType == Browsable.manga) {
      query = _mediaQuery;
      variables = {..._filters};
    } else {
      variables = {
        PAGE: _filters[PAGE],
        SEARCH: _filters[SEARCH],
        ID_NOT_IN: _filters[ID_NOT_IN],
      };

      if (currentType == Browsable.characters) {
        query = _charactersQuery;
      } else if (currentType == Browsable.staff) {
        query = _staffQuery;
      } else {
        query = _studiosQuery;
      }
    }

    if (_search() != null && _search() != '') variables['search'] = _search();

    final data = await NetworkService.request(
      query,
      variables,
      popOnError: false,
    );

    _concurrentFetches--;
    if (data == null || _concurrentFetches > 0) return;

    _hasNextPage.value = data['Page']['pageInfo']['hasNextPage'];

    List<BrowseResult> loaded = [];

    if (currentType == Browsable.anime || currentType == Browsable.manga) {
      for (final m in data['Page']['media'] as List<dynamic>) {
        loaded.add(BrowseResult(
          id: m['id'],
          title: m['title']['userPreferred'],
          imageUrl: m['coverImage']['large'],
          browsable: currentType,
        ));
        (_filters[ID_NOT_IN] as List<dynamic>).add(m['id']);
      }
    } else if (currentType == Browsable.characters) {
      for (final c in data['Page']['characters'] as List<dynamic>) {
        loaded.add(BrowseResult(
          id: c['id'],
          title: c['name']['full'],
          imageUrl: c['image']['large'],
          browsable: currentType,
        ));
        (_filters[ID_NOT_IN] as List<dynamic>).add(c['id']);
      }
    } else if (currentType == Browsable.staff) {
      for (final c in data['Page']['staff'] as List<dynamic>) {
        loaded.add(BrowseResult(
          id: c['id'],
          title: c['name']['full'],
          imageUrl: c['image']['large'],
          browsable: currentType,
        ));
        (_filters[ID_NOT_IN] as List<dynamic>).add(c['id']);
      }
    } else {
      for (final s in data['Page']['studios'] as List<dynamic>) {
        loaded.add(BrowseResult(
          id: s['id'],
          title: s['name'],
          browsable: currentType,
        ));
        (_filters[ID_NOT_IN] as List<dynamic>).add(s['id']);
      }
    }

    if (clean) {
      _results.assignAll(loaded);
      _isLoading.value = false;
    } else {
      _results.addAll(loaded);
    }
  }

  //Fetches genres, tags and initial media
  Future<void> fetchInitial() async {
    _isLoading.value = true;

    final query = '''
        query Filters {
          Viewer {options {displayAdultContent}}
          GenreCollection
          MediaTagCollection {name description}
          Page(page: 1, perPage: 30) {
            media(sort: TRENDING_DESC, type: ANIME) {
              id
              title {userPreferred}
              coverImage {large}
            }
          }
        }
      ''';

    final data = await NetworkService.request(query, null, popOnError: false);

    if (data == null) return;

    if (!data['Viewer']['options']['displayAdultContent'])
      _filters[IS_ADULT] = false;

    _genres = (data['GenreCollection'] as List<dynamic>)
        .map((g) => g.toString())
        .toList();

    _tags = Tuple([], []);
    for (final tag in data['MediaTagCollection']) {
      _tags.item1.add(tag['name']);
      _tags.item2.add(tag['description']);
    }

    List<BrowseResult> loaded = [];

    for (final m in data['Page']['media'] as List<dynamic>) {
      loaded.add(BrowseResult(
        id: m['id'],
        title: m['title']['userPreferred'],
        imageUrl: m['coverImage']['large'],
        browsable: Browsable.anime,
      ));
      (_filters[ID_NOT_IN] as List<dynamic>).add(m['id']);
    }

    _results.assignAll(loaded);

    _isLoading.value = false;
  }
}
