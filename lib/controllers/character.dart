import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:otraku/services/graph_ql.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/enums/media_sort_enum.dart';
import 'package:otraku/models/page_data/loadable_list.dart';
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
        voiceActors(sort: [LANGUAGE]) {
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
  final _anime = Rx<LoadableList<Connection>>();
  final _manga = Rx<LoadableList<Connection>>();
  final _onAnime = true.obs;
  final _staffLanguage = 'Japanese'.obs;
  final List<String> _availableLanguages = [];
  MediaSort _sort = MediaSort.TRENDING_DESC;

  Person get person => _person();

  LoadableList get anime => _anime();

  LoadableList get manga => _manga();

  bool get onAnime => _onAnime();

  set onAnime(bool value) => _onAnime.value = value;

  String get staffLanguage => _staffLanguage();

  set staffLanguage(String value) => _staffLanguage.value = value;

  int get languageIndex {
    final index = _availableLanguages.indexOf(_staffLanguage());
    if (index != -1) return index;
    return 0;
  }

  List<String> get availableLanguages => [..._availableLanguages];

  MediaSort get sort => _sort;

  set sort(MediaSort value) {
    _sort = value;
    refetch();
  }

  Future<void> fetchCharacter(int id) async {
    if (_person.value != null) return;

    final body = await GraphQl.request(_characterQuery, {
      'id': id,
      'withPerson': true,
      'withAnime': true,
      'withManga': true,
      'sort': describeEnum(_sort),
    });

    if (body == null) return;

    final data = body['Character'];

    List<String> altNames = (data['name']['alternative'] as List<dynamic>)
        .map((a) => a.toString())
        .toList();
    if (data['name']['native'] != null)
      altNames.insert(0, data['name']['native']);

    _person(Person(
      id: id,
      browsable: Browsable.character,
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
    final body = await GraphQl.request(_characterQuery, {
      'id': _person().id,
      'withAnime': true,
      'withManga': true,
      'sort': describeEnum(_sort),
    });

    if (body == null) return;

    _initLists(body['Character']);
  }

  Future<void> fetchPage() async {
    final body = await GraphQl.request(_characterQuery, {
      'id': _person().id,
      'withAnime': _onAnime(),
      'withManga': !_onAnime(),
      'animePage': _anime().nextPage,
      'mangaPage': _manga().nextPage,
      'sort': describeEnum(_sort)
    });

    if (body == null) return;

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

  void _initLists(Map<String, dynamic> data) {
    _availableLanguages.clear();

    List<Connection> connections = [];
    for (final connection in data['anime']['edges']) {
      final List<Connection> voiceActors = [];

      for (final va in connection['voiceActors']) {
        final language = clarifyEnum(va['language']);
        if (!_availableLanguages.contains(language))
          _availableLanguages.add(language);

        voiceActors.add(Connection(
          id: va['id'],
          title: va['name']['full'],
          imageUrl: va['image']['large'],
          browsable: Browsable.staff,
          subtitle: language,
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

    if (!_availableLanguages.contains(_staffLanguage()))
      _staffLanguage.value = 'Japanese';

    _anime(LoadableList(
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

    _manga(LoadableList(
      connections,
      data['manga']['pageInfo']['hasNextPage'],
    ));
  }
}
