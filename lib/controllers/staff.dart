import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/enums/media_sort.dart';
import 'package:otraku/models/page_model.dart';
import 'package:otraku/models/person_model.dart';
import 'package:otraku/models/helper_models/connection.dart';

class Staff extends GetxController {
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
      name{full native alternative}
      image{large}
      favourites 
      isFavourite
      description(asHtml: true)
    }
  ''';

  static const _toggleFavouriteMutation = r'''
    mutation ToggleFavouriteStaff($id: Int) {
      ToggleFavourite(staffId: $id) {
        staff(page: 1, perPage: 1) {pageInfo {currentPage}}
      }
    }
  ''';

  // ***************************************************************************
  // DATA
  // ***************************************************************************

  final int _id;
  Staff(this._id);

  final _person = Rx<PersonModel?>(null);
  final _characters = PageModel<Connection>().obs;
  final _roles = PageModel<Connection>().obs;
  final _onCharacters = true.obs;
  MediaSort _sort = MediaSort.TRENDING_DESC;

  PersonModel? get person => _person();

  PageModel get characters => _characters();

  PageModel get roles => _roles();

  bool get onCharacters => _onCharacters();

  set onCharacters(bool value) => _onCharacters.value = value;

  MediaSort get sort => _sort;

  set sort(MediaSort value) {
    _sort = value;
    refetch();
  }

  // ***************************************************************************
  // FETCHING
  // ***************************************************************************

  Future<void> fetch() async {
    if (_person.value != null) return;

    final body = await Client.request(_staffQuery, {
      'id': _id,
      'withPerson': true,
      'withCharacters': true,
      'withStaff': true,
      'sort': describeEnum(_sort),
    });
    if (body == null) return;

    final data = body['Staff'];

    _person(PersonModel(data));
    _initCharacters(data, false);
    _initRoles(data, false);

    if (_characters().items.isEmpty) _onCharacters.value = false;
  }

  Future<void> refetch() async {
    final data = await Client.request(_staffQuery, {
      'id': _id,
      'withCharacters': true,
      'withStaff': true,
      'sort': describeEnum(_sort),
    });
    if (data == null) return;

    _initCharacters(data['Staff'], true);
    _initRoles(data['Staff'], true);
  }

  Future<void> fetchPage() async {
    if (_onCharacters() && !_characters().hasNextPage) return;
    if (!_onCharacters() && !_roles().hasNextPage) return;

    final data = await Client.request(_staffQuery, {
      'id': _id,
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

  Future<bool> toggleFavourite() async =>
      await Client.request(
        _toggleFavouriteMutation,
        {'id': _id},
        popOnErr: false,
      ) !=
      null;

  // ***************************************************************************
  // HELPER FUNCTIONS
  // ***************************************************************************

  void _initCharacters(Map<String, dynamic> data, bool clear) {
    if (clear) _characters().clear();

    final connections = <Connection>[];
    for (final connection in data['characterMedia']['edges'])
      for (final char in connection['characters'])
        connections.add(Connection(
            id: char['id'],
            title: char['name']['full'],
            imageUrl: char['image']['large'],
            browsable: Browsable.character,
            text2: Convert.clarifyEnum(connection['characterRole']),
            others: [
              Connection(
                id: connection['node']['id'],
                title: connection['node']['title']['userPreferred'],
                imageUrl: connection['node']['coverImage']['large'],
                browsable: connection['node']['type'] == 'ANIME'
                    ? Browsable.anime
                    : Browsable.manga,
              ),
            ]));

    _characters.update((c) => c!.append(
          connections,
          data['characterMedia']['pageInfo']['hasNextPage'],
        ));
  }

  void _initRoles(Map<String, dynamic> data, bool clear) {
    if (clear) _roles().clear();

    final connections = <Connection>[];
    for (final connection in data['staffMedia']['edges'])
      connections.add(Connection(
        id: connection['node']['id'],
        title: connection['node']['title']['userPreferred'],
        imageUrl: connection['node']['coverImage']['large'],
        browsable: connection['node']['type'] == 'ANIME'
            ? Browsable.anime
            : Browsable.manga,
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
