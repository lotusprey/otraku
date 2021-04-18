import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/enums/media_sort.dart';
import 'package:otraku/models/tag_model.dart';
import 'package:otraku/utils/filterable.dart';
import 'package:otraku/models/helper_models/browse_result_model.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/scroll_x_controller.dart';

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
          id type title {userPreferred} coverImage {large}
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
  final _results = <BrowseResultModel>[].obs;
  final _type = Browsable.anime.obs;
  final _search = ''.obs;
  final _genres = <String>[];
  final _tags = <String, List<TagModel>>{};
  int _concurrentFetches = 0;
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

  Map<String, List<TagModel>> get tags => _tags;

  // ***************************************************************************
  // FUNCTIONS CONTROLLING QUERY VARIABLES
  // ***************************************************************************

  set type(Browsable value) {
    _type.value = value;

    if (value == Browsable.anime) _filters[Filterable.TYPE] = 'ANIME';
    if (value == Browsable.manga) _filters[Filterable.TYPE] = 'MANGA';

    _filters.remove(Filterable.FORMAT_IN);
    fetch();
  }

  set search(String value) => _search.value = value.trim();

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

    String query;
    switch (_type.value) {
      case Browsable.anime:
      case Browsable.manga:
        query = _mediaQuery;
        break;
      case Browsable.character:
        query = _charactersQuery;
        break;
      case Browsable.staff:
        query = _staffQuery;
        break;
      case Browsable.studio:
        query = _studiosQuery;
        break;
      case Browsable.user:
        query = _usersQuery;
        break;
      case Browsable.review:
        query = _reviewsQuery;
        break;
    }

    Map<String, dynamic>? data = await Client.request(
      query,
      {..._filters, if (_search() != '') 'search': _search()},
      popOnErr: false,
    );

    _concurrentFetches--;
    if (data == null || _concurrentFetches > 0) return;

    data = data['Page'];
    _hasNextPage.value = data!['pageInfo']['hasNextPage'];

    final List<BrowseResultModel> items = [];
    final List<dynamic> idNotIn = _filters[Filterable.ID_NOT_IN];

    if (data['media'] != null)
      for (final m in data['media']) {
        items.add(BrowseResultModel.media(m));
        idNotIn.add(m['id']);
      }
    else if (data['characters'] != null)
      for (final c in data['characters']) {
        items.add(BrowseResultModel.character(c));
        idNotIn.add(c['id']);
      }
    else if (data['staff'] != null)
      for (final s in data['staff']) {
        items.add(BrowseResultModel.staff(s));
        idNotIn.add(s['id']);
      }
    else if (data['studios'] != null)
      for (final s in data['studios']) {
        items.add(BrowseResultModel.studio(s));
        idNotIn.add(s['id']);
      }
    else if (data['users'] != null)
      for (final u in data['users']) items.add(BrowseResultModel.user(u));
    else if (data['reviews'] != null)
      for (final r in data['reviews']) items.add(BrowseResultModel.review(r));

    if (clean) {
      scrollTo(0);
      _results.assignAll(items);
      _isLoading.value = false;
    } else
      _results.addAll(items);
  }

  Future<void> fetchPage() async => fetch(clean: false);

  //Fetches genres, tags and initial media
  Future<void> fetchInitial() async {
    _isLoading.value = true;

    const query = '''
        query Filters {
          Viewer {options {displayAdultContent}}
          GenreCollection
          MediaTagCollection {name description category isGeneralSpoiler}
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

    for (final g in data['GenreCollection']) _genres.add(g.toString());

    for (final t in data['MediaTagCollection']) {
      final category = t['category'] ?? 'Other';
      if (!_tags.containsKey(category))
        _tags[category] = [TagModel(t)];
      else
        _tags[category]!.add(TagModel(t));
    }

    final loaded = <BrowseResultModel>[];
    final List<dynamic> idNotIn = _filters[Filterable.ID_NOT_IN];

    for (final a in data['Page']['media']) {
      loaded.add(BrowseResultModel.anime(a));
      idNotIn.add(a['id']);
    }

    _results.assignAll(loaded);
    _isLoading.value = false;
  }

  @override
  void onInit() {
    super.onInit();
    fetchInitial();
    _search.firstRebuild = false;
    debounce(_search, (dynamic _) => fetch(),
        time: const Duration(milliseconds: 600));
  }
}
