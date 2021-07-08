import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:otraku/models/staff_model.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/enums/explorable.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/enums/media_sort.dart';
import 'package:otraku/models/page_model.dart';
import 'package:otraku/models/connection_model.dart';
import 'package:otraku/utils/scroll_x_controller.dart';

class StaffController extends ScrollxController {
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
            }
            characters {
              id
              name {full}
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
      name{first middle last native alternative}
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

  // ***************************************************************************
  // DATA
  // ***************************************************************************

  final int id;
  StaffController(this.id);

  StaffModel? _model;
  final _characters = PageModel<ConnectionModel>().obs;
  final _roles = PageModel<ConnectionModel>().obs;
  final _onCharacters = true.obs;
  MediaSort _sort = MediaSort.POPULARITY_DESC;

  StaffModel? get model => _model;
  PageModel<ConnectionModel> get characters => _characters();
  PageModel<ConnectionModel> get roles => _roles();
  bool get onCharacters => _onCharacters();
  set onCharacters(bool value) => _onCharacters.value = value;
  MediaSort get sort => _sort;
  set sort(MediaSort value) {
    _sort = value;
    refetch();
  }

  @override
  bool get hasNextPage =>
      _onCharacters() ? _characters().hasNextPage : _roles().hasNextPage;

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
      'sort': describeEnum(_sort),
    });
    if (body == null) return;

    final data = body['Staff'];

    _model = StaffModel(data);
    update();

    _initCharacters(data, false);
    _initRoles(data, false);

    if (_characters().items.isEmpty) _onCharacters.value = false;
  }

  Future<void> refetch() async {
    final data = await Client.request(_staffQuery, {
      'id': id,
      'withCharacters': true,
      'withStaff': true,
      'sort': describeEnum(_sort),
    });
    if (data == null) return;

    _initCharacters(data['Staff'], true);
    _initRoles(data['Staff'], true);
  }

  @override
  Future<void> fetchPage() async {
    final data = await Client.request(_staffQuery, {
      'id': id,
      'withCharacters': _onCharacters(),
      'withStaff': !_onCharacters(),
      'characterPage': _characters().nextPage,
      'staffPage': _roles().nextPage,
      'sort': describeEnum(_sort),
    });
    if (data == null) return;

    if (_onCharacters())
      _initCharacters(data['Staff'], false);
    else
      _initRoles(data['Staff'], false);
  }

  Future<bool> toggleFavourite() async {
    final data = await Client.request(
      _toggleFavouriteMutation,
      {'id': id},
      popOnErr: false,
    );
    if (data != null) _model!.isFavourite = !_model!.isFavourite;
    return _model!.isFavourite;
  }

  // ***************************************************************************
  // HELPER FUNCTIONS
  // ***************************************************************************

  void _initCharacters(Map<String, dynamic> data, bool clear) {
    if (clear) _characters().clear();

    final connections = <ConnectionModel>[];
    for (final connection in data['characterMedia']['edges'])
      for (final char in connection['characters'])
        if (char != null)
          connections.add(ConnectionModel(
              id: char['id'],
              title: char['name']['full'],
              imageUrl: char['image']['large'],
              browsable: Explorable.character,
              text2: Convert.clarifyEnum(connection['characterRole']),
              others: [
                ConnectionModel(
                  id: connection['node']['id'],
                  title: connection['node']['title']['userPreferred'],
                  imageUrl: connection['node']['coverImage']['large'],
                  browsable: connection['node']['type'] == 'ANIME'
                      ? Explorable.anime
                      : Explorable.manga,
                ),
              ]));

    _characters.update((c) => c!.append(
          connections,
          data['characterMedia']['pageInfo']['hasNextPage'],
        ));
  }

  void _initRoles(Map<String, dynamic> data, bool clear) {
    if (clear) _roles().clear();

    final connections = <ConnectionModel>[];
    for (final connection in data['staffMedia']['edges'])
      connections.add(ConnectionModel(
        id: connection['node']['id'],
        title: connection['node']['title']['userPreferred'],
        imageUrl: connection['node']['coverImage']['large'],
        browsable: connection['node']['type'] == 'ANIME'
            ? Explorable.anime
            : Explorable.manga,
        text2: Convert.clarifyEnum(connection['staffRole']),
      ));

    _roles.update((r) => r!.append(
          connections,
          data['staffMedia']['pageInfo']['hasNextPage'],
        ));
  }

  @override
  void onInit() {
    super.onInit();
    fetch();
  }
}
