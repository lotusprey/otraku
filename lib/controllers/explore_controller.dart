import 'package:otraku/constants/explorable.dart';
import 'package:otraku/models/filter_model.dart';
import 'package:otraku/models/page_model.dart';
import 'package:otraku/utils/debounce.dart';
import 'package:otraku/models/explorable_model.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/scrolling_controller.dart';
import 'package:otraku/utils/settings.dart';

// Searches and filters items from the Explorable enum
class ExploreController extends ScrollingController {
  static const ID_HEAD = 0;
  static const ID_BODY = 1;
  static const ID_BUTTON = 2;

  late final filters = ExploreFilterModel(fetch);
  final _results = PageModel<ExplorableModel>();
  late final _debounce = Debounce(fetch);
  int _page = 1;
  Explorable _type = Settings().defaultExplorable;
  String _search = '';
  bool _isBirthday = false;
  bool _isLoading = true;
  int _concurrentFetches = 0;
  bool _searchMode = false;

  // ***************************************************************************
  // GETTERS & SETTERS
  // ***************************************************************************

  bool get hasNextPage => _results.hasNextPage;

  bool get isLoading => _isLoading;

  List<ExplorableModel> get results => _results.items;

  Explorable get type => _type;

  String get search => _search;

  set type(Explorable val) {
    if (_type == val) return;
    _type = val;
    filters.formats.clear();
    update([ID_HEAD, ID_BUTTON]);
    fetch();
  }

  set search(String val) {
    val = val.trimLeft();
    if (_search == val) return;
    _search = val;
    _search.isEmpty ? fetch() : _debounce.run();
  }

  bool get searchMode => _searchMode;

  set searchMode(bool val) {
    if (searchMode == val) return;
    _searchMode = val;
    _search = '';
    update([ID_HEAD]);
  }

  bool get isBirthday => _isBirthday;

  set isBirthday(bool val) {
    if (_isBirthday == val) return;
    _isBirthday = val;
    fetch();
  }

  // ***************************************************************************
  // FETCHING
  // ***************************************************************************

  Future<void> fetch({bool clean = true}) async {
    _concurrentFetches++;

    if (clean) {
      _isLoading = true;
      _page = 1;
      scrollUpTo(0);
      update([ID_BODY]);
    }

    late String query;
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

    final variables = filters.toMap();
    variables['page'] = _page;
    if (_search.isNotEmpty) variables['search'] = _search;

    if (type == Explorable.anime)
      variables['type'] = 'ANIME';
    else if (type == Explorable.manga)
      variables['type'] = 'MANGA';
    else if (type == Explorable.character || type == Explorable.staff) {
      if (_isBirthday) variables['isBirthday'] = _isBirthday;
    }

    Map<String, dynamic>? data = await Client.request(query, variables);

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
    _page++;
    await fetch(clean: false);
  }

  @override
  void onInit() {
    super.onInit();
    fetch();
  }
}
