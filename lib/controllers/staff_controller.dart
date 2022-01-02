import 'package:otraku/models/staff_model.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/constants/media_sort.dart';
import 'package:otraku/models/page_model.dart';
import 'package:otraku/models/connection_model.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/scrolling_controller.dart';

class StaffController extends ScrollingController {
  // GetBuilder ids.
  static const ID_MAIN = 0;
  static const ID_MEDIA = 1;

  StaffController(this.id);

  final int id;
  StaffModel? _model;
  final _characters = PageModel<ConnectionModel>();
  final _roles = PageModel<ConnectionModel>();
  bool _onCharacters = true;
  MediaSort _sort = MediaSort.POPULARITY_DESC;
  bool? _onList;

  StaffModel? get model => _model;
  List<ConnectionModel> get characters => _characters.items;
  List<ConnectionModel> get roles => _roles.items;

  bool get onCharacters => _onCharacters;
  set onCharacters(bool val) {
    _onCharacters = val;
    update([ID_MEDIA]);
  }

  MediaSort get sort => _sort;
  set sort(MediaSort value) {
    _sort = value;
    refetch();
  }

  bool? get onList => _onList;
  set onList(bool? val) {
    _onList = val;
    refetch();
  }

  Future<void> _fetch() async {
    final data = await Client.request(GqlQuery.staff, {
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
    scrollUpTo(0);

    final data = await Client.request(GqlQuery.staff, {
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

    final data = await Client.request(GqlQuery.staff, {
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
    final data =
        await Client.request(GqlMutation.toggleFavourite, {'staff': id});
    if (data != null) _model!.isFavourite = !_model!.isFavourite;
    return _model!.isFavourite;
  }

  void _initCharacters(Map<String, dynamic> data, bool clear) {
    if (clear) _characters.clear();

    final connections = <ConnectionModel>[];
    for (final connection in data['characterMedia']['edges'])
      for (final char in connection['characters'])
        if (char != null)
          connections.add(ConnectionModel(
              id: char['id'],
              title: char['name']['userPreferred'],
              imageUrl: char['image']['large'],
              type: Explorable.character,
              subtitle: Convert.clarifyEnum(connection['characterRole']),
              other: [
                ConnectionModel(
                  id: connection['node']['id'],
                  title: connection['node']['title']['userPreferred'],
                  imageUrl: connection['node']['coverImage']['extraLarge'],
                  subtitle: Convert.clarifyEnum(connection['node']['format']),
                  type: connection['node']['type'] == 'ANIME'
                      ? Explorable.anime
                      : Explorable.manga,
                ),
              ]));

    _characters.append(
      connections,
      data['characterMedia']['pageInfo']['hasNextPage'],
    );
  }

  void _initRoles(Map<String, dynamic> data, bool clear) {
    if (clear) _roles.clear();

    final connections = <ConnectionModel>[];
    for (final connection in data['staffMedia']['edges'])
      connections.add(ConnectionModel(
        id: connection['node']['id'],
        title: connection['node']['title']['userPreferred'],
        imageUrl: connection['node']['coverImage']['extraLarge'],
        type: connection['node']['type'] == 'ANIME'
            ? Explorable.anime
            : Explorable.manga,
        subtitle: Convert.clarifyEnum(connection['staffRole']),
      ));

    _roles.append(
      connections,
      data['staffMedia']['pageInfo']['hasNextPage'],
    );
  }

  @override
  void onInit() {
    super.onInit();
    if (_model == null) _fetch();
  }
}
