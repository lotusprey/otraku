import 'package:flutter/foundation.dart';
import 'package:otraku/models/character_model.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/enums/explorable.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/enums/media_sort.dart';
import 'package:otraku/models/page_model.dart';
import 'package:otraku/models/connection_model.dart';
import 'package:otraku/utils/overscroll_controller.dart';

class CharacterController extends OverscrollController {
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
      name{userPreferred native alternative alternativeSpoiler}
      image{large}
      description(asHtml: true)
      dateOfBirth{year month day}
      gender
      age
      favourites 
      isFavourite
      isFavouriteBlocked
    }
    fragment media on MediaConnection {
      pageInfo {hasNextPage}
      edges {
        characterRole
        voiceActors(sort: [LANGUAGE]) {id name {userPreferred} image {large} language}
        node {id type title {userPreferred} coverImage {large}}
      }
    }
  ''';

  static const _toggleFavouriteMutation = r'''
    mutation ToggleFavouriteCharacter($id: Int) {
      ToggleFavourite(characterId: $id) {
        characters(page: 1, perPage: 1) {nodes{isFavourite}}
      }
    }
  ''';

  // GetBuilder ids.
  static const ID_MAIN = 0;
  static const ID_MEDIA = 1;

  // ***************************************************************************
  // DATA
  // ***************************************************************************

  final int id;
  CharacterController(this.id);

  CharacterModel? _model;
  final _anime = PageModel<ConnectionModel>();
  final _manga = PageModel<ConnectionModel>();
  final _availableLanguages = <String>[];
  bool _onAnime = true;
  int _language = 0;
  MediaSort _sort = MediaSort.TRENDING_DESC;
  bool? _onList;

  CharacterModel? get model => _model;
  List<ConnectionModel> get anime => _anime.items;
  List<ConnectionModel> get manga => _manga.items;
  List<String> get availableLanguages => [..._availableLanguages];

  bool get onAnime => _onAnime;
  set onAnime(bool val) {
    _onAnime = val;
    update([ID_MEDIA]);
  }

  int get language => _language;
  set language(int val) {
    _language = val;
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
  bool get hasNextPage => _onAnime ? _anime.hasNextPage : _manga.hasNextPage;

  // ***************************************************************************
  // FETCHING
  // ***************************************************************************

  Future<void> fetch() async {
    if (_model != null) return;

    final body = await Client.request(_characterQuery, {
      'id': id,
      'withPerson': true,
      'withAnime': true,
      'withManga': true,
      'onList': _onList,
      'sort': describeEnum(_sort),
    });
    if (body == null) return;

    final data = body['Character'];

    _model = CharacterModel(data);
    _initAnime(data, false);
    _initManga(data, false);

    update([ID_MAIN, ID_MEDIA]);
  }

  Future<void> refetch() async {
    scrollUpTo(0);

    final body = await Client.request(_characterQuery, {
      'id': id,
      'withAnime': true,
      'withManga': true,
      'onList': _onList,
      'sort': describeEnum(_sort),
    });
    if (body == null) return;

    _initAnime(body['Character'], true);
    _initManga(body['Character'], true);

    update([ID_MEDIA]);
  }

  @override
  Future<void> fetchPage() async {
    final data = await Client.request(_characterQuery, {
      'id': id,
      'withAnime': _onAnime,
      'withManga': !_onAnime,
      'animePage': _anime.nextPage,
      'mangaPage': _manga.nextPage,
      'sort': describeEnum(_sort),
      'onList': _onList,
    });
    if (data == null) return;

    if (_onAnime)
      _initAnime(data['Character'], false);
    else
      _initManga(data['Character'], false);

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

  void _initAnime(Map<String, dynamic> data, bool clear) {
    if (clear) {
      _availableLanguages.clear();
      _anime.clear();
    }

    final connections = <ConnectionModel>[];
    for (final connection in data['anime']['edges']) {
      final voiceActors = <ConnectionModel>[];

      for (final va in connection['voiceActors']) {
        final language = Convert.clarifyEnum(va['language']);
        if (!_availableLanguages.contains(language))
          _availableLanguages.add(language!);

        voiceActors.add(ConnectionModel(
          id: va['id'],
          title: va['name']['userPreferred'],
          imageUrl: va['image']['large'],
          type: Explorable.staff,
          subtitle: language,
        ));
      }

      connections.add(ConnectionModel(
        id: connection['node']['id'],
        title: connection['node']['title']['userPreferred'],
        imageUrl: connection['node']['coverImage']['large'],
        type: Explorable.anime,
        subtitle: Convert.clarifyEnum(connection['characterRole']),
        other: voiceActors,
      ));
    }

    _anime.append(connections, data['anime']['pageInfo']['hasNextPage']);
  }

  void _initManga(Map<String, dynamic> data, bool clear) {
    if (clear) _manga.clear();

    final connections = <ConnectionModel>[];
    for (final connection in data['manga']['edges'])
      connections.add(ConnectionModel(
        id: connection['node']['id'],
        title: connection['node']['title']['userPreferred'],
        imageUrl: connection['node']['coverImage']['large'],
        type: Explorable.manga,
        subtitle: Convert.clarifyEnum(connection['characterRole']),
      ));

    _manga.append(connections, data['manga']['pageInfo']['hasNextPage']);
  }

  @override
  void onInit() {
    super.onInit();
    fetch();
  }
}
