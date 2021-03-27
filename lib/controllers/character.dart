import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/enums/media_sort.dart';
import 'package:otraku/models/page_model.dart';
import 'package:otraku/models/person_model.dart';
import 'package:otraku/models/helper_models/connection.dart';

class Character extends GetxController {
  // ***************************************************************************
  // CONSTANTS
  // ***************************************************************************

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
      id
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
        voiceActors(sort: [LANGUAGE]) {id name {full} image {large} language}
        node {id type title {userPreferred} coverImage {large}}
      }
    }
  ''';

  static const _toggleFavouriteMutation = r'''
    mutation ToggleFavouriteCharacter($id: Int) {
      ToggleFavourite(characterId: $id) {
        characters(page: 1, perPage: 1) {pageInfo {currentPage}}
      }
    }
  ''';

  // ***************************************************************************
  // DATA
  // ***************************************************************************

  final int _id;
  Character(this._id);

  final _person = Rx<PersonModel>();
  final _anime = Rx<PageModel<Connection>>();
  final _manga = Rx<PageModel<Connection>>();
  final _onAnime = true.obs;
  final _staffLanguage = 'Japanese'.obs;
  final _availableLanguages = <String>[];
  MediaSort _sort = MediaSort.TRENDING_DESC;

  PersonModel? get person => _person();

  PageModel<Connection>? get anime => _anime();

  PageModel<Connection>? get manga => _manga();

  bool get onAnime => _onAnime()!;

  set onAnime(bool value) => _onAnime.value = value;

  String get staffLanguage => _staffLanguage()!;

  set staffLanguage(String value) => _staffLanguage.value = value;

  int get languageIndex {
    final index = _availableLanguages.indexOf(_staffLanguage()!);
    if (index != -1) return index;
    return 0;
  }

  List<String> get availableLanguages => [..._availableLanguages];

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

    final body = await Client.request(_characterQuery, {
      'id': _id,
      'withPerson': true,
      'withAnime': true,
      'withManga': true,
      'sort': describeEnum(_sort),
    });

    if (body == null) return;

    final data = body['Character'];
    _person(PersonModel(data));
    _initLists(data);
    if (_anime()!.items.isEmpty) _onAnime.value = false;
  }

  Future<void> refetch() async {
    final body = await Client.request(_characterQuery, {
      'id': _person()!.id,
      'withAnime': true,
      'withManga': true,
      'sort': describeEnum(_sort),
    });

    if (body == null) return;

    _initLists(body['Character']);
  }

  Future<void> fetchPage() async {
    if (_onAnime()! && !_anime()!.hasNextPage!) return;
    if (!_onAnime()! && !_manga()!.hasNextPage!) return;

    final body = await Client.request(_characterQuery, {
      'id': _id,
      'withAnime': _onAnime(),
      'withManga': !_onAnime()!,
      'animePage': _anime()!.nextPage,
      'mangaPage': _manga()!.nextPage,
      'sort': describeEnum(_sort)
    });

    if (body == null) return;

    final data = body['Character'];

    final List<Connection> connections = [];
    if (_onAnime()!) {
      for (final connection in data['anime']['edges']) {
        final List<Connection> voiceActors = [];

        for (final va in connection['voiceActors'])
          voiceActors.add(Connection(
            id: va['id'],
            title: va['name']['full'],
            imageUrl: va['image']['large'],
            browsable: Browsable.staff,
            text2: Convert.clarifyEnum(va['language']),
          ));

        connections.add(Connection(
          id: connection['node']['id'],
          title: connection['node']['title']['userPreferred'],
          imageUrl: connection['node']['coverImage']['large'],
          browsable: Browsable.anime,
          text2: Convert.clarifyEnum(connection['characterRole']),
          others: voiceActors,
        ));
      }

      _anime.update((media) {
        media!.append(connections, data['anime']['pageInfo']['hasNextPage']);
      });
    } else {
      for (final connection in data['manga']['edges'])
        connections.add(Connection(
          id: connection['node']['id'],
          title: connection['node']['title']['userPreferred'],
          imageUrl: connection['node']['coverImage']['large'],
          browsable: Browsable.manga,
          text2: Convert.clarifyEnum(connection['characterRole']),
        ));

      _manga.update((media) {
        media!.append(connections, data['manga']['pageInfo']['hasNextPage']);
      });
    }
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

  void _initLists(Map<String, dynamic> data) {
    _availableLanguages.clear();

    List<Connection> connections = [];
    for (final connection in data['anime']['edges']) {
      final voiceActors = <Connection>[];

      for (final va in connection['voiceActors']) {
        final language = Convert.clarifyEnum(va['language']);
        if (!_availableLanguages.contains(language))
          _availableLanguages.add(language!);

        voiceActors.add(Connection(
          id: va['id'],
          title: va['name']['full'],
          imageUrl: va['image']['large'],
          browsable: Browsable.staff,
          text2: language,
        ));
      }

      connections.add(Connection(
        id: connection['node']['id'],
        title: connection['node']['title']['userPreferred'],
        imageUrl: connection['node']['coverImage']['large'],
        browsable: Browsable.anime,
        text2: Convert.clarifyEnum(connection['characterRole']),
        others: voiceActors,
      ));
    }

    if (!_availableLanguages.contains(_staffLanguage()))
      _staffLanguage.value = 'Japanese';

    _anime(PageModel(connections, data['anime']['pageInfo']['hasNextPage'], 2));

    connections = [];
    for (final connection in data['manga']['edges'])
      connections.add(Connection(
        id: connection['node']['id'],
        title: connection['node']['title']['userPreferred'],
        imageUrl: connection['node']['coverImage']['large'],
        browsable: Browsable.manga,
        text2: Convert.clarifyEnum(connection['characterRole']),
      ));

    _manga(PageModel(connections, data['manga']['pageInfo']['hasNextPage'], 2));
  }

  @override
  void onInit() {
    super.onInit();
    fetch();
  }
}
