import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/enums/media_sort_enum.dart';
import 'package:otraku/services/filterable.dart';
import 'package:otraku/models/sample_data/browse_result.dart';
import 'package:otraku/models/tuple.dart';
import 'package:otraku/services/graph_ql.dart';

// Searches and filters items from the Browsable enum
class Explorer extends GetxController implements Filterable {
  // ***************************************************************************
  // CONSTANTS
  // ***************************************************************************

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
          id title {userPreferred} coverImage {large}
        }
      }
    }
  ''';

  static const _charactersQuery = r'''
    query Characters($page: Int, $search: String, $id_not_in: [Int]) {
      Page(page: $page, perPage: 30) {
        pageInfo {hasNextPage}
        characters(search: $search, id_not_in: $id_not_in, sort: FAVOURITES_DESC) {
          id name {full} image {large}
        }
      }
    }
  ''';

  static const _staffQuery = r'''
    query Staff($page: Int, $search: String, $id_not_in: [Int]) {
      Page(page: $page, perPage: 30) {
        pageInfo {hasNextPage}
        staff(search: $search, id_not_in: $id_not_in, sort: FAVOURITES_DESC) {
          id name {full} image {large}
        }
      }
    }
  ''';

  static const _studiosQuery = r'''
    query Studios($page: Int, $search: String, $id_not_in: [Int]) {
      Page(page: $page, perPage: 30) {
        pageInfo {hasNextPage}
        studios(search: $search, id_not_in: $id_not_in) {id name}
      }
    }
  ''';

  static const _usersQuery = r'''
    query Users($page: Int, $search: String) {
      Page(page: $page, perPage: 30) {
        pageInfo {hasNextPage}
        users(search: $search) {id name avatar {large}}
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
    Filterable.PAGE: 1,
    Filterable.TYPE: 'ANIME',
    Filterable.SORT: describeEnum(MediaSort.TRENDING_DESC),
    Filterable.ID_NOT_IN: [],
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

    if (value == Browsable.anime) _filters[Filterable.TYPE] = 'ANIME';
    if (value == Browsable.manga) _filters[Filterable.TYPE] = 'MANGA';

    _filters.remove(Filterable.FORMAT_IN);
    fetchData();
  }

  set search(String value) {
    if (value == null) {
      _search.value = '';
    } else {
      _search.value = value.trim();
    }
  }

  @override
  dynamic getFilterWithKey(String key) => _filters[key];

  @override
  void setFilterWithKey(
    String key, {
    dynamic value,
    bool update = false,
  }) {
    if (value == null ||
        (value is List && value.isEmpty) ||
        (value is String && value.trim().isEmpty)) {
      _filters.remove(key);
    } else {
      _filters[key] = value;
    }

    if (update) fetchData();
  }

  @override
  void clearAllFilters({bool update = true}) => clearFiltersWithKeys([
        Filterable.STATUS_IN,
        Filterable.FORMAT_IN,
        Filterable.GENRE_IN,
        Filterable.GENRE_NOT_IN,
        Filterable.TAG_IN,
        Filterable.TAG_NOT_IN,
        Filterable.ON_LIST,
      ], update: update);

  @override
  void clearFiltersWithKeys(List<String> keys, {bool update = true}) {
    for (final key in keys) {
      _filters.remove(key);
    }

    if (update) fetchData();
  }

  @override
  bool anyActiveFilterFrom(List<String> keys) {
    for (final key in keys) if (_filters.containsKey(key)) return true;
    return false;
  }

  void loadMore() {
    _filters[Filterable.PAGE]++;
    fetchData(clean: false);
  }

  // ***************************************************************************
  // DATA FETCHING
  // ***************************************************************************

  Future<void> fetchData({bool clean = true}) async {
    _concurrentFetches++;

    if (clean) {
      _isLoading.value = true;
      _filters[Filterable.ID_NOT_IN] = [];
      _filters[Filterable.PAGE] = 1;
    }

    final currentType = _type.value;
    String query;
    Map<String, dynamic> variables;

    if (currentType == Browsable.anime || currentType == Browsable.manga) {
      query = _mediaQuery;
      variables = {..._filters};
    } else {
      variables = {
        Filterable.PAGE: _filters[Filterable.PAGE],
        Filterable.SEARCH: _filters[Filterable.SEARCH],
        Filterable.ID_NOT_IN: _filters[Filterable.ID_NOT_IN],
      };

      if (currentType == Browsable.character) {
        query = _charactersQuery;
      } else if (currentType == Browsable.staff) {
        query = _staffQuery;
      } else if (currentType == Browsable.studio) {
        query = _studiosQuery;
      } else {
        query = _usersQuery;
      }
    }

    if (_search() != null && _search() != '') variables['search'] = _search();

    final data = await GraphQl.request(
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
        (_filters[Filterable.ID_NOT_IN] as List<dynamic>).add(m['id']);
      }
    } else if (currentType == Browsable.character) {
      for (final c in data['Page']['characters'] as List<dynamic>) {
        loaded.add(BrowseResult(
          id: c['id'],
          title: c['name']['full'],
          imageUrl: c['image']['large'],
          browsable: currentType,
        ));
        (_filters[Filterable.ID_NOT_IN] as List<dynamic>).add(c['id']);
      }
    } else if (currentType == Browsable.staff) {
      for (final c in data['Page']['staff'] as List<dynamic>) {
        loaded.add(BrowseResult(
          id: c['id'],
          title: c['name']['full'],
          imageUrl: c['image']['large'],
          browsable: currentType,
        ));
        (_filters[Filterable.ID_NOT_IN] as List<dynamic>).add(c['id']);
      }
    } else if (currentType == Browsable.studio) {
      for (final s in data['Page']['studios'] as List<dynamic>) {
        loaded.add(BrowseResult(
          id: s['id'],
          title: s['name'],
          browsable: currentType,
        ));
        (_filters[Filterable.ID_NOT_IN] as List<dynamic>).add(s['id']);
      }
    } else {
      for (final u in data['Page']['users'] as List<dynamic>) {
        loaded.add(BrowseResult(
          id: u['id'],
          title: u['name'],
          imageUrl: u['avatar']['large'],
          browsable: currentType,
        ));
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

    final data = await GraphQl.request(query, null, popOnError: false);

    if (data == null) return;

    if (!data['Viewer']['options']['displayAdultContent'])
      _filters[Filterable.IS_ADULT] = false;

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
      (_filters[Filterable.ID_NOT_IN] as List<dynamic>).add(m['id']);
    }

    _results.assignAll(loaded);

    _isLoading.value = false;
  }
}
