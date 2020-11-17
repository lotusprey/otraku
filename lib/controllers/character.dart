import 'package:get/get.dart';
import 'package:otraku/controllers/network_service.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/models/page_data/connection_list.dart';
import 'package:otraku/models/page_data/person.dart';
import 'package:otraku/models/sample_data/connection.dart';

class Character extends GetxController {
  static const _characterQuery = r'''
    query Character($id: Int, $sort: [MediaSort], $animePage: Int = 1, $mangaPage: Int = 1, 
        $onList: Boolean, $withPerson: Boolean = false, $withAnime: Boolean = false, $withManga: Boolean = false) {
      Character(id: $id) {
        ...person @include(if: $withPerson)
        anime: media(page: $animePage, type: ANIME, onList: $onList, sort: $sort) 
          @include(if: $withAnime) {...media}
        manga: media(page: $mangaPage, type: MANGA, onList: $onList, sort: $sort) 
          @include(if: $withManga) {...media}
      }
    }
    fragment person on Character {
      name{full native alternative}
      image{large}
      favourites 
      isFavourite
      description(asHtml: true)
    }
    fragment media on MediaConnection {
      pageInfo {hasNextPage}
      edges {
        characterRole
        voiceActors {
          id
          name {full}
          image {large}
          language
        }
        node {
          id
          type
          title {userPreferred}
          coverImage {large}
        }
      }
    }
  ''';

  final _person = Rx<Person>();
  final _anime = Rx<ConnectionList>();
  final _manga = Rx<ConnectionList>();
  final _onAnime = true.obs;

  Person get person => _person();

  ConnectionList get anime => _anime();

  ConnectionList get manga => _manga();

  bool get onAnime => _onAnime();

  set onAnime(bool value) => _onAnime.value = value;

  Future<void> fetchCharacter(int id) async {
    final body = await NetworkService.request(
      _characterQuery,
      {'id': id, 'withPerson': true, 'withAnime': true, 'withManga': true},
    );

    if (body == null) return null;

    final data = body['Character'];

    List<String> altNames = (data['name']['alternative'] as List<dynamic>)
        .map((a) => a.toString())
        .toList();
    if (data['name']['native'] != null)
      altNames.insert(0, data['name']['native']);

    _person(Person(
      id: id,
      browsable: Browsable.characters,
      isFavourite: data['isFavourite'],
      favourites: data['favourites'],
      fullName: data['name']['full'],
      altNames: altNames,
      imageUrl: data['image']['large'],
      description:
          data['description'].toString().replaceAll(RegExp(r'<[^>]*>'), ''),
    ));

    List<Connection> connections = [];
    for (final connection in data['anime']['edges']) {
      final List<Connection> voiceActors = [];

      for (final va in connection['voiceActors']) {
        voiceActors.add(Connection(
          id: va['id'],
          title: va['name']['full'],
          imageUrl: va['image']['large'],
          browsable: Browsable.staff,
          subtitle: clarifyEnum(va['language']),
        ));
      }

      connections.add(Connection(
        id: connection['node']['id'],
        title: connection['node']['title']['userPreferred'],
        imageUrl: connection['node']['coverImage']['large'],
        browsable: Browsable.anime,
        subtitle: clarifyEnum(connection['characterRole']),
        others: voiceActors,
      ));
    }

    _anime(ConnectionList(
      connections,
      data['anime']['pageInfo']['hasNextPage'],
    ));

    connections = [];
    for (final connection in data['manga']['edges'])
      connections.add(Connection(
        id: connection['node']['id'],
        title: connection['node']['title']['userPreferred'],
        imageUrl: connection['node']['coverImage']['large'],
        browsable: Browsable.manga,
        subtitle: clarifyEnum(connection['characterRole']),
      ));

    _manga(ConnectionList(
      connections,
      data['manga']['pageInfo']['hasNextPage'],
    ));
  }

  Future<void> fetchPage() async {
    final body = await NetworkService.request(_characterQuery, {
      'id': _person().id,
      'withAnime': _onAnime(),
      'withManga': !_onAnime(),
      'animePage': _anime().nextPage,
      'mangaPage': _manga().nextPage,
    });

    if (body == null) return null;

    final data = body['Character'];

    final List<Connection> connections = [];
    if (_onAnime()) {
      for (final connection in data['anime']['edges']) {
        final List<Connection> voiceActors = [];

        for (final va in connection['voiceActors']) {
          voiceActors.add(Connection(
            id: va['id'],
            title: va['name']['full'],
            imageUrl: va['image']['large'],
            browsable: Browsable.staff,
            subtitle: clarifyEnum(va['language']),
          ));
        }

        connections.add(Connection(
          id: connection['node']['id'],
          title: connection['node']['title']['userPreferred'],
          imageUrl: connection['node']['coverImage']['large'],
          browsable: Browsable.anime,
          subtitle: clarifyEnum(connection['characterRole']),
          others: voiceActors,
        ));
      }

      _anime.update((media) {
        media.append(connections, data['anime']['pageInfo']['hasNextPage']);
      });
    } else {
      for (final connection in data['manga']['edges'])
        connections.add(Connection(
          id: connection['node']['id'],
          title: connection['node']['title']['userPreferred'],
          imageUrl: connection['node']['coverImage']['large'],
          browsable: Browsable.manga,
          subtitle: clarifyEnum(connection['characterRole']),
        ));

      _manga.update((media) {
        media.append(connections, data['manga']['pageInfo']['hasNextPage']);
      });
    }
  }
}
