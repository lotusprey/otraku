import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:otraku/services/network.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/enums/media_sort.dart';
import 'package:otraku/models/loadable_list.dart';
import 'package:otraku/models/anilist/person.dart';
import 'package:otraku/models/connection.dart';

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

  final _person = Rx<Person>();
  final _characterList = Rx<LoadableList<Connection>>();
  final _roleList = Rx<LoadableList<Connection>>();
  final _onCharacters = true.obs;
  MediaSort _sort = MediaSort.TRENDING_DESC;

  Person get person => _person();

  LoadableList get characterList => _characterList();

  LoadableList get roleList => _roleList();

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

  Future<void> fetchStaff(int id) async {
    if (_person.value != null) return;

    final body = await Network.request(_staffQuery, {
      'id': id,
      'withPerson': true,
      'withCharacters': true,
      'withStaff': true,
      'sort': describeEnum(_sort),
    });

    if (body == null) return;

    final data = body['Staff'];

    List<String> altNames = (data['name']['alternative'] as List<dynamic>)
        .map((a) => a.toString())
        .toList();
    if (data['name']['native'] != null)
      altNames.insert(0, data['name']['native']);

    _person(Person(
      id: id,
      browsable: Browsable.staff,
      isFavourite: data['isFavourite'],
      favourites: data['favourites'],
      fullName: data['name']['full'],
      altNames: altNames,
      imageUrl: data['image']['large'],
      description:
          data['description'].toString().replaceAll(RegExp(r'<[^>]*>'), ''),
    ));

    _initLists(data);
  }

  Future<void> refetch() async {
    final body = await Network.request(_staffQuery, {
      'id': _person().id,
      'withCharacters': true,
      'withStaff': true,
      'sort': describeEnum(_sort),
    });

    if (body == null) return;

    _initLists(body['Staff']);
  }

  Future<void> fetchPage() async {
    final body = await Network.request(_staffQuery, {
      'id': _person().id,
      'withCharacters': _onCharacters(),
      'withStaff': !_onCharacters(),
      'characterPage': _characterList().nextPage,
      'staffPage': _roleList().nextPage,
      'sort': describeEnum(_sort),
    });

    if (body == null) return;

    final data = body['Staff'];

    List<Connection> connections = [];
    if (_onCharacters()) {
      for (final connection in data['characterMedia']['edges']) {
        for (final char in connection['characters']) {
          connections.add(Connection(
              id: char['id'],
              title: char['name']['full'],
              imageUrl: char['image']['large'],
              browsable: Browsable.character,
              subtitle: clarifyEnum(connection['characterRole']),
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
        }
      }

      _characterList.update((list) => list.append(
          connections, data['characterMedia']['pageInfo']['hasNextPage']));
    } else {
      for (final connection in data['staffMedia']['edges']) {
        connections.add(Connection(
          id: connection['node']['id'],
          title: connection['node']['title']['userPreferred'],
          imageUrl: connection['node']['coverImage']['large'],
          browsable: connection['node']['type'] == 'ANIME'
              ? Browsable.anime
              : Browsable.manga,
          subtitle: clarifyEnum(connection['staffRole']),
        ));
      }

      _roleList.update((list) => list.append(
          connections, data['staffMedia']['pageInfo']['hasNextPage']));
    }
  }

  Future<bool> toggleFavourite() async =>
      await Network.request(
        _toggleFavouriteMutation,
        {'id': _person().id},
        popOnError: false,
      ) !=
      null;

  // ***************************************************************************
  // HELPER FUNCTIONS
  // ***************************************************************************

  void _initLists(Map<String, dynamic> data) {
    List<Connection> connections = [];
    for (final connection in data['characterMedia']['edges']) {
      for (final char in connection['characters']) {
        connections.add(Connection(
            id: char['id'],
            title: char['name']['full'],
            imageUrl: char['image']['large'],
            browsable: Browsable.character,
            subtitle: clarifyEnum(connection['characterRole']),
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
      }
    }

    if (connections.isEmpty) _onCharacters.value = false;

    _characterList(LoadableList(
      connections,
      data['characterMedia']['pageInfo']['hasNextPage'],
    ));

    connections = [];
    for (final connection in data['staffMedia']['edges']) {
      connections.add(Connection(
        id: connection['node']['id'],
        title: connection['node']['title']['userPreferred'],
        imageUrl: connection['node']['coverImage']['large'],
        browsable: connection['node']['type'] == 'ANIME'
            ? Browsable.anime
            : Browsable.manga,
        subtitle: clarifyEnum(connection['staffRole']),
      ));
    }

    _roleList(LoadableList(
      connections,
      data['staffMedia']['pageInfo']['hasNextPage'],
    ));
  }
}
