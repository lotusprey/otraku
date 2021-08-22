import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:otraku/enums/explorable.dart';
import 'package:otraku/enums/media_sort.dart';
import 'package:otraku/models/page_model.dart';
import 'package:otraku/models/tag_model.dart';
import 'package:otraku/utils/filterable.dart';
import 'package:otraku/models/explorable_model.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/overscroll_controller.dart';

// Searches and filters items from the Explorable enum
class ExploreController extends OverscrollController implements Filterable {
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
  final _results = PageModel<ExplorableModel>().obs;
  final _type = Explorable.anime.obs;
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

  @override
  bool get hasNextPage => _results().hasNextPage;

  bool get isLoading => _isLoading();

  Explorable get type => _type();

  String get search => _search();

  List<ExplorableModel> get results => _results().items;

  List<String> get genres => [..._genres];

  Map<String, List<TagModel>> get tags => _tags;

  // ***************************************************************************
  // FUNCTIONS CONTROLLING QUERY VARIABLES
  // ***************************************************************************

  set type(Explorable value) {
    _type.value = value;

    if (value == Explorable.anime) _filters[Filterable.TYPE] = 'ANIME';
    if (value == Explorable.manga) _filters[Filterable.TYPE] = 'MANGA';

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
        Filterable.ON_LIST,
        Filterable.COUNTRY,
        Filterable.STATUS_IN,
        Filterable.FORMAT_IN,
        Filterable.GENRE_IN,
        Filterable.GENRE_NOT_IN,
        Filterable.TAG_IN,
        Filterable.TAG_NOT_IN,
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

  // ***************************************************************************
  // FETCHING
  // ***************************************************************************

  Future<void> fetch({bool clean = true}) async {
    _concurrentFetches++;

    if (clean) {
      _isLoading.value = true;
      _filters[Filterable.ID_NOT_IN] = [];
      _filters[Filterable.PAGE] = 1;
      scrollTo(0);
    }

    String query;
    switch (_type.value) {
      case Explorable.anime:
      case Explorable.manga:
        query = _mediaQuery;
        break;
      case Explorable.character:
        query = _charactersQuery;
        break;
      case Explorable.staff:
        query = _staffQuery;
        break;
      case Explorable.studio:
        query = _studiosQuery;
        break;
      case Explorable.user:
        query = _usersQuery;
        break;
      case Explorable.review:
        query = _reviewsQuery;
        break;
    }

    Map<String, dynamic>? data = await Client.request(
      query,
      {..._filters, if (_search() != '') 'search': _search()},
      popOnErr: false,
    );

    _concurrentFetches--;
    if (data == null || (_concurrentFetches > 0 && clean)) return;

    data = data['Page'];

    final items = <ExplorableModel>[];
    final List<dynamic> idNotIn = _filters[Filterable.ID_NOT_IN];

    if (data!['media'] != null)
      for (final m in data['media']) {
        items.add(ExplorableModel.media(m));
        idNotIn.add(m['id']);
      }
    else if (data['characters'] != null)
      for (final c in data['characters']) {
        items.add(ExplorableModel.character(c));
        idNotIn.add(c['id']);
      }
    else if (data['staff'] != null)
      for (final s in data['staff']) {
        items.add(ExplorableModel.staff(s));
        idNotIn.add(s['id']);
      }
    else if (data['studios'] != null)
      for (final s in data['studios']) {
        items.add(ExplorableModel.studio(s));
        idNotIn.add(s['id']);
      }
    else if (data['users'] != null)
      for (final u in data['users']) items.add(ExplorableModel.user(u));
    else if (data['reviews'] != null)
      for (final r in data['reviews']) items.add(ExplorableModel.review(r));

    if (clean)
      _results.update((r) {
        r!.clear();
        r.append(items, data!['pageInfo']['hasNextPage']);
      });
    else
      _results.update(
        (r) => r!.append(items, data!['pageInfo']['hasNextPage']),
      );

    _isLoading.value = false;
  }

  @override
  Future<void> fetchPage() async {
    _filters[Filterable.PAGE]++;
    await fetch(clean: false);
  }

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

    final items = <ExplorableModel>[];
    final List<dynamic> idNotIn = _filters[Filterable.ID_NOT_IN];

    for (final a in data['Page']['media']) {
      items.add(ExplorableModel.anime(a));
      idNotIn.add(a['id']);
    }

    _results.update((r) => r!.append(items, true));
    _isLoading.value = false;
  }

  @override
  void onInit() {
    super.onInit();
    fetchInitial();
    _search.firstRebuild = false;
    debounce<String>(
      _search,
      (_) => fetch(),
      time: const Duration(milliseconds: 600),
    );
  }
}
