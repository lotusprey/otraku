import 'package:otraku/constants/explorable.dart';
import 'package:otraku/models/filter_model.dart';
import 'package:otraku/models/page_model.dart';
import 'package:otraku/models/tag_collection_model.dart';
import 'package:otraku/utils/debounce.dart';
import 'package:otraku/models/explorable_model.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/scrolling_controller.dart';

// Searches and filters items from the Explorable enum
class ExploreController extends ScrollingController {
  static const ID_HEAD = 0;
  static const ID_BODY = 1;
  static const ID_BUTTON = 2;

  // ***************************************************************************
  // DATA
  // ***************************************************************************

  late final filters = ExploreFilterModel(_onFilterChange);
  late final TagCollectionModel tagCollection;
  final _results = PageModel<ExplorableModel>();
  late final _debounce = Debounce(fetch);
  bool _isLoading = true;
  int _concurrentFetches = 0;
  bool _searchMode = false;

  // ***************************************************************************
  // GETTERS & SETTERS
  // ***************************************************************************

  bool get hasNextPage => _results.hasNextPage;

  bool get isLoading => _isLoading;

  List<ExplorableModel> get results => _results.items;

  bool get searchMode => _searchMode;

  set searchMode(bool val) {
    if (searchMode == val) return;
    _searchMode = val;
    update([ID_HEAD]);
    if (filters.search.isNotEmpty) filters.search = '';
  }

  void _onFilterChange({
    bool content = false,
    bool frame = false,
    bool meta = false,
  }) {
    if (meta && filters.search.isNotEmpty) {
      _debounce.run();
      return;
    }

    if (frame) update([ID_HEAD, ID_BUTTON]);
    fetch();
  }

  // ***************************************************************************
  // FETCHING
  // ***************************************************************************

  Future<void> fetch({bool clean = true}) async {
    _concurrentFetches++;

    if (clean) {
      _isLoading = true;
      filters.page = 1;
      scrollUpTo(0);
      update([ID_BODY]);
    }

    late String query;
    if (filters.type == Explorable.anime || filters.type == Explorable.manga)
      query = GqlQuery.medias;
    else if (filters.type == Explorable.character)
      query = GqlQuery.characters;
    else if (filters.type == Explorable.staff)
      query = GqlQuery.staffs;
    else if (filters.type == Explorable.studio)
      query = GqlQuery.studios;
    else if (filters.type == Explorable.review)
      query = GqlQuery.reviews;
    else
      query = GqlQuery.users;

    Map<String, dynamic>? data = await Client.request(query, filters.toMap());

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
    filters.page++;
    await fetch(clean: false);
  }

  @override
  void onInit() {
    super.onInit();

    const query = '''
        query Filters {
          Viewer {options {displayAdultContent}}
          GenreCollection
          MediaTagCollection {id name description category isGeneralSpoiler}
        }
      ''';

    Client.request(query).then((data) {
      if (data == null) return;

      if (data['Viewer']?['options']?['displayAdultContent'] == false)
        filters.isAdult = false;

      tagCollection = TagCollectionModel(data);

      fetch();
    });
  }
}
