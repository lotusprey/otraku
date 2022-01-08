import 'package:otraku/constants/explorable.dart';
import 'package:otraku/models/page_model.dart';
import 'package:otraku/models/tag_model.dart';
import 'package:otraku/utils/debounce.dart';
import 'package:otraku/utils/filterable.dart';
import 'package:otraku/models/explorable_model.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/utils/scrolling_controller.dart';

// Searches and filters items from the Explorable enum
class ExploreController extends ScrollingController implements Filterable {
  // ***************************************************************************
  // CONSTANTS
  // ***************************************************************************

  static const ID_HEAD = 0;
  static const ID_BODY = 1;
  static const ID_BUTTON = 2;

  // ***************************************************************************
  // DATA
  // ***************************************************************************

  final _results = PageModel<ExplorableModel>();
  final _genres = <String>[];
  final _tags = <String, List<TagModel>>{};
  String _search = '';
  Explorable _type = Settings().defaultExplorable;
  late final _debounce = Debounce(fetch);
  bool _isLoading = true;
  int _concurrentFetches = 0;
  bool _searchMode = false;
  Map<String, dynamic> _filters = {
    Filterable.PAGE: 1,
    Filterable.TYPE: 'ANIME',
    Filterable.SORT: Settings().defaultExploreSort.name,
  };

  // ***************************************************************************
  // GETTERS & SETTERS
  // ***************************************************************************

  bool get hasNextPage => _results.hasNextPage;

  bool get isLoading => _isLoading;

  Explorable get type => _type;

  String get search => _search;

  bool get searchMode => _searchMode;

  List<ExplorableModel> get results => _results.items;

  List<String> get genres => [..._genres];

  Map<String, List<TagModel>> get tags => _tags;

  // ***************************************************************************
  // FILTERING
  // ***************************************************************************

  set type(Explorable value) {
    _type = value;
    update([ID_HEAD, ID_BUTTON]);

    if (value == Explorable.anime)
      _filters[Filterable.TYPE] = 'ANIME';
    else if (value == Explorable.manga) _filters[Filterable.TYPE] = 'MANGA';

    _filters.remove(Filterable.FORMAT_IN);
    fetch();
  }

  set search(String value) {
    _search = value.trim();
    _debounce.run();
  }

  set searchMode(bool val) {
    if (searchMode == val) return;
    _searchMode = val;
    update([ID_HEAD]);
    if (_filters[Filterable.SEARCH] != null)
      setFilterWithKey(Filterable.SEARCH, update: true);
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
      _isLoading = true;
      _filters[Filterable.PAGE] = 1;
      scrollUpTo(0);
      update([ID_BODY]);
    }

    String query;
    if (_type == Explorable.anime || _type == Explorable.manga)
      query = GqlQuery.medias;
    else if (_type == Explorable.character)
      query = GqlQuery.characters;
    else if (_type == Explorable.staff)
      query = GqlQuery.staffs;
    else if (_type == Explorable.studio)
      query = GqlQuery.studios;
    else if (_type == Explorable.review)
      query = GqlQuery.reviews;
    else
      query = GqlQuery.users;

    Map<String, dynamic>? data = await Client.request(
      query,
      {..._filters, if (_search != '') 'search': _search},
    );

    _concurrentFetches--;
    if (data == null || (_concurrentFetches > 0 && clean)) return;

    data = data['Page'];

    final items = <ExplorableModel>[];

    if (data!['media'] != null)
      for (final m in data['media']) items.add(ExplorableModel.media(m));
    else if (data['characters'] != null)
      for (final c in data['characters'])
        items.add(ExplorableModel.character(c));
    else if (data['staff'] != null)
      for (final s in data['staff']) items.add(ExplorableModel.staff(s));
    else if (data['studios'] != null)
      for (final s in data['studios']) items.add(ExplorableModel.studio(s));
    else if (data['users'] != null)
      for (final u in data['users']) items.add(ExplorableModel.user(u));
    else if (data['reviews'] != null)
      for (final r in data['reviews']) items.add(ExplorableModel.review(r));

    if (clean) _results.clear();
    _results.append(items, data['pageInfo']['hasNextPage']);
    _isLoading = false;
    update([ID_BODY]);
  }

  @override
  Future<void> fetchPage() async {
    if (!_results.hasNextPage) return;
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

      _filters[Filterable.TYPE] = _type == Explorable.manga ? 'MANGA' : 'ANIME';

      fetch();
    });
  }
}
