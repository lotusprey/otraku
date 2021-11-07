import 'package:flutter/foundation.dart';
import 'package:otraku/models/staff_model.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/enums/explorable.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/enums/media_sort.dart';
import 'package:otraku/models/page_model.dart';
import 'package:otraku/models/connection_model.dart';
import 'package:otraku/utils/overscroll_controller.dart';

class StaffController extends OverscrollController {
  // ***************************************************************************
  // CONSTANTS
  // ***************************************************************************

  static const _staffQuery = r'''
    query Staff($id: Int, $sort: [MediaSort], $characterPage: Int = 1, $staffPage: Int = 1, 
        $onList: Boolean, $withPerson: Boolean = false, $withCharacters: Boolean = false, $withStaff: Boolean = false) {
      Staff(id: $id) {
        ...person @include(if: $withPerson)
        characterMedia(page: $characterPage, sort: $sort, onList: $onList) @include(if: $withCharacters) {
          pageInfo {hasNextPage}
          edges {
            characterRole
            node {
              id
              type
              title {userPreferred}
              coverImage {large}
              format
            }
            characters {
              id
              name {userPreferred}
              image {large}
            }
          }
        }
        staffMedia(page: $staffPage, sort: $sort, onList: $onList) @include(if: $withStaff) {
          pageInfo {hasNextPage}
          edges {
            staffRole
            node {
              id
              type
              title {userPreferred}
              coverImage {large}
            }
          }
        }
      }
    }
    fragment person on Staff {
      id
      name{userPreferred native alternative}
      image{large}
      description(asHtml: true)
      languageV2
      primaryOccupations
      dateOfBirth{year month day}
      dateOfDeath{year month day}
      gender
      age
      yearsActive
      homeTown
      favourites 
      isFavourite
      isFavouriteBlocked
    }
  ''';

  static const _toggleFavouriteMutation = r'''
    mutation ToggleFavouriteStaff($id: Int) {
      ToggleFavourite(staffId: $id) {
        staff(page: 1, perPage: 1) {nodes{isFavourite}}
      }
    }
  ''';

  // GetBuilder id.
  static const ID_MAIN = 0;
  static const ID_MEDIA = 1;

  // ***************************************************************************
  // DATA
  // ***************************************************************************

  final int id;
  StaffController(this.id);

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

  @override
  bool get hasNextPage =>
      _onCharacters ? _characters.hasNextPage : _roles.hasNextPage;

  // ***************************************************************************
  // FETCHING
  // ***************************************************************************

  Future<void> fetch() async {
    if (_model != null) return;

    final body = await Client.request(_staffQuery, {
      'id': id,
      'withPerson': true,
      'withCharacters': true,
      'withStaff': true,
      'onList': _onList,
      'sort': describeEnum(_sort),
    });
    if (body == null) return;

    final data = body['Staff'];

    _model = StaffModel(data);
    _initCharacters(data, false);
    _initRoles(data, false);

    update([ID_MAIN, ID_MEDIA]);
  }

  Future<void> refetch() async {
    scrollUpTo(0);

    final data = await Client.request(_staffQuery, {
      'id': id,
      'withCharacters': true,
      'withStaff': true,
      'onList': _onList,
      'sort': describeEnum(_sort),
    });
    if (data == null) return;

    _initCharacters(data['Staff'], true);
    _initRoles(data['Staff'], true);

    update([ID_MEDIA]);
  }

  @override
  Future<void> fetchPage() async {
    final data = await Client.request(_staffQuery, {
      'id': id,
      'withCharacters': _onCharacters,
      'withStaff': !_onCharacters,
      'characterPage': _characters.nextPage,
      'staffPage': _roles.nextPage,
      'sort': describeEnum(_sort),
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
    final data = await Client.request(_toggleFavouriteMutation, {'id': id});
    if (data != null) _model!.isFavourite = !_model!.isFavourite;
    return _model!.isFavourite;
  }

  // ***************************************************************************
  // HELPER FUNCTIONS
  // ***************************************************************************

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
                  imageUrl: connection['node']['coverImage']['large'],
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
        imageUrl: connection['node']['coverImage']['large'],
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
    fetch();
  }
}
