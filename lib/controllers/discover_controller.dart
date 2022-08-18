import 'package:get/get.dart';
import 'package:otraku/constants/discover_type.dart';
import 'package:otraku/filter/filter_models.dart';
import 'package:otraku/models/page_model.dart';
import 'package:otraku/utils/debounce.dart';
import 'package:otraku/models/discover_model.dart';
import 'package:otraku/utils/api.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/settings.dart';

/// Searches and filters items from [DiscoverType]
class DiscoverController extends GetxController {
  static const ID_HEAD = 0;
  static const ID_BODY = 1;
  static const ID_BUTTON = 2;

  final _results = PageModel<DiscoverModel>();
  late final _debounce = Debounce(fetch);
  late var _filter = DiscoverFilter(_type == DiscoverType.anime);
  int _page = 1;
  DiscoverType _type = Settings().defaultDiscoverType;
  String? _search;
  bool _isBirthday = false;
  bool _isLoading = true;
  int _concurrentFetches = 0;

  // A temporary workaround.
  bool canFetch = true;

  // ***************************************************************************
  // GETTERS & SETTERS
  // ***************************************************************************

  bool get hasNextPage => _results.hasNextPage;

  bool get isLoading => _isLoading;

  List<DiscoverModel> get results => _results.items;

  DiscoverType get type => _type;

  DiscoverFilter get filter => _filter;

  String? get search => _search;

  set type(DiscoverType val) {
    if (_type == val) return;
    _type = val;
    _filter.ofAnime = val == DiscoverType.anime;
    update([ID_HEAD, ID_BUTTON]);
    fetch();
  }

  set filter(DiscoverFilter val) {
    _filter = val;
    fetch();
  }

  set search(String? val) {
    val = val?.trimLeft();
    if (_search == val) return;
    final oldVal = _search;
    _search = val;

    if ((oldVal == null) != (val == null)) {
      update([ID_HEAD]);
      if ((oldVal?.isNotEmpty ?? false) || (val?.isNotEmpty ?? false)) fetch();
    } else
      (val?.isEmpty ?? true) ? fetch() : _debounce.run();
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
    if (!canFetch) return;
    _concurrentFetches++;

    if (clean) {
      _isLoading = true;
      _page = 1;
      update([ID_BODY]);
    }

    late String query;
    if (_type == DiscoverType.anime || _type == DiscoverType.manga)
      query = GqlQuery.medias;
    else if (_type == DiscoverType.character)
      query = GqlQuery.characters;
    else if (_type == DiscoverType.staff)
      query = GqlQuery.staffs;
    else if (_type == DiscoverType.studio)
      query = GqlQuery.studios;
    else if (_type == DiscoverType.review)
      query = GqlQuery.reviews;
    else
      query = GqlQuery.users;

    final variables =
        _type != DiscoverType.review ? _filter.toMap() : <String, dynamic>{};
    variables['page'] = _page;
    if (_search?.isNotEmpty ?? false) variables['search'] = _search;

    if (type == DiscoverType.anime)
      variables['type'] = 'ANIME';
    else if (type == DiscoverType.manga)
      variables['type'] = 'MANGA';
    else if (type == DiscoverType.character || type == DiscoverType.staff) {
      if (_isBirthday) variables['isBirthday'] = _isBirthday;
    }

    Map<String, dynamic>? data = await Api.request(query, variables);

    _concurrentFetches--;
    if (data == null || (_concurrentFetches > 0 && clean)) return;

    data = data['Page'];

    final items = <DiscoverModel>[];

    if (data!['media'] != null)
      for (final m in data['media']) items.add(DiscoverModel.media(m));
    else if (data['characters'] != null)
      for (final c in data['characters']) items.add(DiscoverModel.character(c));
    else if (data['staff'] != null)
      for (final s in data['staff']) items.add(DiscoverModel.staff(s));
    else if (data['studios'] != null)
      for (final s in data['studios']) items.add(DiscoverModel.studio(s));
    else if (data['users'] != null)
      for (final u in data['users']) items.add(DiscoverModel.user(u));
    else if (data['reviews'] != null)
      for (final r in data['reviews']) items.add(DiscoverModel.review(r));

    if (clean) _results.clear();
    _results.append(items, data['pageInfo']['hasNextPage']);
    _isLoading = false;
    update([ID_BODY]);
  }

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
