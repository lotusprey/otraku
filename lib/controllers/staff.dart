import 'package:get/get.dart';
import 'package:otraku/controllers/network_service.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/models/page_data/connection_list.dart';
import 'package:otraku/models/page_data/person.dart';
import 'package:otraku/models/sample_data/connection.dart';

class Staff extends GetxController {
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

  final _person = Rx<Person>();
  final _characterList = Rx<ConnectionList>();
  final _roleList = Rx<ConnectionList>();
  final _onCharacters = true.obs;

  Person get person => _person();

  ConnectionList get characterList => _characterList();

  ConnectionList get roleList => _roleList();

  bool get onCharacters => _onCharacters();

  set onCharacters(bool value) => _onCharacters.value = value;

  Future<void> fetchStaff(int id) async {
    final body = await NetworkService.request(_staffQuery, {
      'id': id,
      'withPerson': true,
      'withCharacters': true,
      'withStaff': true,
    });

    if (body == null) return null;

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

    List<Connection> connections = [];
    for (final connection in data['characterMedia']['edges']) {
      for (final char in connection['characters']) {
        connections.add(Connection(
            id: char['id'],
            title: char['name']['full'],
            imageUrl: char['image']['large'],
            browsable: Browsable.characters,
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

    _characterList(ConnectionList(
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

    _roleList(ConnectionList(
      connections,
      data['staffMedia']['pageInfo']['hasNextPage'],
    ));
  }

  Future<void> fetchPage() async {
    final body = await NetworkService.request(_staffQuery, {
      'id': _person().id,
      'withCharacters': _onCharacters(),
      'withStaff': !_onCharacters(),
      'characterPage': _characterList().nextPage,
      'staffPage': _roleList().nextPage,
    });

    if (body == null) return null;

    final data = body['Staff'];

    List<Connection> connections = [];
    if (_onCharacters()) {
      for (final connection in data['characterMedia']['edges']) {
        for (final char in connection['characters']) {
          connections.add(Connection(
              id: char['id'],
              title: char['name']['full'],
              imageUrl: char['image']['large'],
              browsable: Browsable.characters,
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
}
