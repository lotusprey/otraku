import 'package:otraku/models/relation_model.dart';
import 'package:otraku/models/staff_model.dart';
import 'package:otraku/utils/api.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/constants/media_sort.dart';
import 'package:otraku/models/page_model.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/pagination_controller.dart';
import 'package:otraku/utils/scrolling_controller.dart';
import 'package:otraku/utils/settings.dart';

class StaffController extends ScrollingController {
  // GetBuilder ids.
  static const ID_MAIN = 0;
  static const ID_MEDIA = 1;

  StaffController(this.id);

  final int id;
  StaffModel? _model;
  final _media = <RelationModel>[];
  final _characters = PageModel<RelationModel>();
  final _roles = PageModel<RelationModel>();
  bool _onCharacters = true;
  MediaSort _sort = MediaSort.START_DATE_DESC;
  bool? _onList;

  StaffModel? get model => _model;
  List<RelationModel> get media => _media;
  List<RelationModel> get characters => _characters.items;
  List<RelationModel> get roles => _roles.items;

  bool get onCharacters => _onCharacters;
  set onCharacters(bool val) {
    _onCharacters = val;
    update([ID_MEDIA]);
  }

  MediaSort get sort => _sort;
  bool? get onList => _onList;

  void filter(MediaSort sortVal, bool? onListVal) {
    if (sortVal == _sort && onListVal == _onList) return;
    _sort = sortVal;
    _onList = onListVal;
    refetch();
  }

  Future<void> _fetch() async {
    final data = await Api.request(GqlQuery.staff, {
      'id': id,
      'withMain': true,
      'withCharacters': true,
      'withStaff': true,
      'onList': _onList,
      'sort': _sort.name,
    });
    if (data == null) return;

    _model = StaffModel(data['Staff']);
    _initCharacters(data['Staff'], false);
    _initRoles(data['Staff'], false);

    update([ID_MAIN, ID_MEDIA]);
  }

  Future<void> refetch() async {
    scrollCtrl.scrollUpTo(0);

    final data = await Api.request(GqlQuery.staff, {
      'id': id,
      'withCharacters': true,
      'withStaff': true,
      'onList': _onList,
      'sort': _sort.name,
    });
    if (data == null) return;

    _initCharacters(data['Staff'], true);
    _initRoles(data['Staff'], true);

    update([ID_MEDIA]);
  }

  @override
  Future<void> fetchPage() async {
    if (_onCharacters && !_characters.hasNextPage) return;
    if (!_onCharacters && !_roles.hasNextPage) return;

    final data = await Api.request(GqlQuery.staff, {
      'id': id,
      'withCharacters': _onCharacters,
      'withStaff': !_onCharacters,
      'characterPage': _characters.nextPage,
      'staffPage': _roles.nextPage,
      'sort': _sort.name,
      'onList': _onList,
    });
    if (data == null) return;

    if (_onCharacters)
      _initCharacters(data['Staff'], false);
    else
      _initRoles(data['Staff'], false);

    update([ID_MEDIA]);
  }

  Future<bool> toggleFavourite() async {
    final data = await Api.request(GqlMutation.toggleFavorite, {'staff': id});
    if (data != null) _model!.isFavourite = !_model!.isFavourite;
    return _model!.isFavourite;
  }

  void _initCharacters(Map<String, dynamic> data, bool clear) {
    if (clear) {
      _characters.clear();
      _media.clear();
    }

    final items = <RelationModel>[];
    for (final m in data['characterMedia']['edges'])
      for (final c in m['characters']) {
        if (c == null) continue;

        _media.add(RelationModel(
          id: m['node']['id'],
          title: m['node']['title']['userPreferred'],
          imageUrl: m['node']['coverImage'][Settings().imageQuality],
          subtitle: Convert.clarifyEnum(m['node']['format']),
          type: m['node']['type'] == 'ANIME'
              ? Explorable.anime
              : Explorable.manga,
        ));

        items.add(RelationModel(
          id: c['id'],
          title: c['name']['userPreferred'],
          imageUrl: c['image']['large'],
          type: Explorable.character,
          subtitle: Convert.clarifyEnum(m['characterRole']),
        ));
      }

    _characters.append(
      items,
      data['characterMedia']['pageInfo']['hasNextPage'],
    );
  }

  void _initRoles(Map<String, dynamic> data, bool clear) {
    if (clear) _roles.clear();

    final items = <RelationModel>[];
    for (final s in data['staffMedia']['edges'])
      items.add(RelationModel(
        id: s['node']['id'],
        title: s['node']['title']['userPreferred'],
        imageUrl: s['node']['coverImage'][Settings().imageQuality],
        subtitle: s['staffRole'],
        type:
            s['node']['type'] == 'ANIME' ? Explorable.anime : Explorable.manga,
      ));

    _roles.append(
      items,
      data['staffMedia']['pageInfo']['hasNextPage'],
    );
  }

  @override
  void onInit() {
    super.onInit();
    if (_model == null) _fetch();
  }
}
