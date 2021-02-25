import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/enums/media_sort.dart';
import 'package:otraku/helpers/filterable.dart';
import 'package:otraku/models/browse_result_model.dart';
import 'package:otraku/helpers/client.dart';
import 'package:otraku/helpers/scroll_x_controller.dart';

// Searches and filters items from the Browsable enum
class Explorer extends ScrollxController implements Filterable {
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

  static const _reviewsQuery = r'''
    query Reviews($page: Int) {
      Page(page: $page, perPage: 30) {
        pageInfo {hasNextPage}
        reviews(sort: CREATED_AT_DESC) {
          id
          summary 
          body(asHtml: true)
          rating
          ratingAmount
          media {id type title{userPreferred} bannerImage}
          user {id name}
        }
      }
    }
  ''';

  // ***************************************************************************
  // DATA
  // ***************************************************************************

  final _isLoading = true.obs;
  final _hasNextPage = true.obs;
  final _results = List<BrowseResultModel>().obs;
  final _type = Browsable.anime.obs;
  final _search = ''.obs;
  int _concurrentFetches = 0;
  List<String> _genres;
  Map<String, String> _tags;
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

  List<BrowseResultModel> get results => [..._results()];

  List<String> get genres => [..._genres];

  Map<String, String> get tags => _tags;

  // ***************************************************************************
  // FUNCTIONS CONTROLLING QUERY VARIABLES
  // ***************************************************************************

  set type(Browsable value) {
    if (value == null) return;
    _type.value = value;

    if (value == Browsable.anime) _filters[Filterable.TYPE] = 'ANIME';
    if (value == Browsable.manga) _filters[Filterable.TYPE] = 'MANGA';

    _filters.remove(Filterable.FORMAT_IN);
    fetch();
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

    if (update) fetch();
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

    if (update) fetch();
  }

  @override
  bool anyActiveFilterFrom(List<String> keys) {
    for (final key in keys) if (_filters.containsKey(key)) return true;
    return false;
  }

  void loadMore() {
    _filters[Filterable.PAGE]++;
    fetch(clean: false);
  }

  // ***************************************************************************
  // DATA FETCHING
  // ***************************************************************************

  Future<void> fetch({bool clean = true}) async {
    _concurrentFetches++;

    if (clean) {
      _isLoading.value = true;
      _filters[Filterable.ID_NOT_IN] = [];
      _filters[Filterable.PAGE] = 1;
    }

    final currentType = _type.value;
    String query;

    if (currentType == Browsable.anime || currentType == Browsable.manga) {
      query = _mediaQuery;
    } else {
      if (currentType == Browsable.character)
        query = _charactersQuery;
      else if (currentType == Browsable.staff)
        query = _staffQuery;
      else if (currentType == Browsable.studio)
        query = _studiosQuery;
      else if (currentType == Browsable.user)
        query = _usersQuery;
      else
        query = _reviewsQuery;
    }

    final data = await Client.request(
      query,
      {..._filters, if (_search() != '') 'search': _search()},
      popOnErr: false,
    );

    _concurrentFetches--;
    if (data == null || _concurrentFetches > 0) return;

    _hasNextPage.value = data['Page']['pageInfo']['hasNextPage'];

    final List<BrowseResultModel> loaded = [];

    if (currentType == Browsable.anime || currentType == Browsable.manga)
      for (final m in data['Page']['media']) {
        loaded.add(BrowseResultModel(
          id: m['id'],
          text1: m['title']['userPreferred'],
          imageUrl: m['coverImage']['large'],
          browsable: currentType,
        ));
        (_filters[Filterable.ID_NOT_IN] as List<dynamic>).add(m['id']);
      }
    else if (currentType == Browsable.character)
      for (final c in data['Page']['characters']) {
        loaded.add(BrowseResultModel(
          id: c['id'],
          text1: c['name']['full'],
          imageUrl: c['image']['large'],
          browsable: currentType,
        ));
        (_filters[Filterable.ID_NOT_IN] as List<dynamic>).add(c['id']);
      }
    else if (currentType == Browsable.staff)
      for (final c in data['Page']['staff']) {
        loaded.add(BrowseResultModel(
          id: c['id'],
          text1: c['name']['full'],
          imageUrl: c['image']['large'],
          browsable: currentType,
        ));
        (_filters[Filterable.ID_NOT_IN] as List<dynamic>).add(c['id']);
      }
    else if (currentType == Browsable.studio)
      for (final s in data['Page']['studios']) {
        loaded.add(BrowseResultModel(
          id: s['id'],
          text1: s['name'],
          browsable: currentType,
        ));
        (_filters[Filterable.ID_NOT_IN] as List<dynamic>).add(s['id']);
      }
    else if (currentType == Browsable.user)
      for (final u in data['Page']['users'])
        loaded.add(BrowseResultModel(
          id: u['id'],
          text1: u['name'],
          imageUrl: u['avatar']['large'],
          browsable: currentType,
        ));
    else
      for (final r in data['Page']['reviews'])
        loaded.add(BrowseResultModel(
          id: r['id'],
          text1:
              'Review of ${r['media']['title']['userPreferred']} by ${r['user']['name']}',
          text2: r['summary'],
          text3: '${r['rating']}/${r['ratingAmount']}',
          imageUrl: r['media']['bannerImage'],
          browsable: currentType,
        ));

    if (clean) {
      scrollTo(0);
      _results.assignAll(loaded);
      _isLoading.value = false;
    } else {
      _results.addAll(loaded);
    }
  }

  //Fetches genres, tags and initial media
  Future<void> fetchInitial() async {
    _isLoading.value = true;

    const query = '''
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

    final data = await Client.request(query, null, popOnErr: false);

    if (data == null) return;

    if (!data['Viewer']['options']['displayAdultContent'])
      _filters[Filterable.IS_ADULT] = false;

    _genres = (data['GenreCollection'] as List<dynamic>)
        .map((g) => g.toString())
        .toList();

    _tags = {};
    for (final tag in data['MediaTagCollection'])
      _tags[tag['name']] = tag['description'];

    List<BrowseResultModel> loaded = [];

    for (final m in data['Page']['media']) {
      loaded.add(BrowseResultModel(
        id: m['id'],
        text1: m['title']['userPreferred'],
        imageUrl: m['coverImage']['large'],
        browsable: Browsable.anime,
      ));
      (_filters[Filterable.ID_NOT_IN] as List<dynamic>).add(m['id']);
    }

    _results.assignAll(loaded);
    _isLoading.value = false;
  }

  @override
  void onInit() {
    super.onInit();
    fetchInitial();
    _search.firstRebuild = false;
    debounce(_search, (_) => fetch(), time: const Duration(milliseconds: 600));
  }
}
