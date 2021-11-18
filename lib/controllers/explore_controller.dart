import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/home_controller.dart';
import 'package:otraku/enums/explorable.dart';
import 'package:otraku/models/page_model.dart';
import 'package:otraku/models/tag_model.dart';
import 'package:otraku/utils/filterable.dart';
import 'package:otraku/models/explorable_model.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/overscroll_controller.dart';

// Searches and filters items from the Explorable enum
class ExploreController extends OverscrollController implements Filterable {
  final _isLoading = true.obs;
  final _results = PageModel<ExplorableModel>().obs;
  final _search = ''.obs;
  final _genres = <String>[];
  final _tags = <String, List<TagModel>>{};
  final _type = HomeController.localSettings.defaultExplorable.obs;
  int _concurrentFetches = 0;
  Map<String, dynamic> _filters = {
    Filterable.PAGE: 1,
    Filterable.TYPE: 'ANIME',
    Filterable.ID_NOT_IN: [],
    Filterable.SORT:
        describeEnum(HomeController.localSettings.defaultExploreSort),
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
  // FILTERING
  // ***************************************************************************

  set type(Explorable value) {
    _type.value = value;

    if (value == Explorable.anime)
      _filters[Filterable.TYPE] = 'ANIME';
    else if (value == Explorable.manga) _filters[Filterable.TYPE] = 'MANGA';

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
      scrollUpTo(0);
    }

    String query;
    if (_type.value == Explorable.anime || _type.value == Explorable.manga)
      query = GqlQuery.medias;
    else if (_type.value == Explorable.character)
      query = GqlQuery.characters;
    else if (_type.value == Explorable.staff)
      query = GqlQuery.staffs;
    else if (_type.value == Explorable.studio)
      query = GqlQuery.studios;
    else if (_type.value == Explorable.review)
      query = GqlQuery.reviews;
    else
      query = GqlQuery.users;

    Map<String, dynamic>? data = await Client.request(
      query,
      {..._filters, if (_search() != '') 'search': _search()},
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

  @override
  void onInit() {
    super.onInit();

    const query = '''
        query Filters {
          Viewer {options {displayAdultContent}}
          GenreCollection
          MediaTagCollection {name description category isGeneralSpoiler}
        }
      ''';

    Client.request(query).then((data) {
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

      _filters[Filterable.TYPE] =
          _type() == Explorable.manga ? 'MANGA' : 'ANIME';

      fetch();
    });

    _search.firstRebuild = false;
    debounce<String>(
      _search,
      (_) => fetch(),
      time: const Duration(milliseconds: 600),
    );
  }
}
