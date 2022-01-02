import 'package:otraku/models/character_model.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/constants/media_sort.dart';
import 'package:otraku/models/page_model.dart';
import 'package:otraku/models/connection_model.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/scrolling_controller.dart';

class CharacterController extends ScrollingController {
  // GetBuilder ids.
  static const ID_MAIN = 0;
  static const ID_MEDIA = 1;

  CharacterController(this.id);

  final int id;
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

  Future<void> _fetch() async {
    final data = await Client.request(GqlQuery.character, {
      'id': id,
      'withMain': true,
      'withAnime': true,
      'withManga': true,
      'onList': _onList,
      'sort': _sort.name,
    });
    if (data == null) return;

    _model = CharacterModel(data['Character']);
    _initAnime(data['Character'], false);
    _initManga(data['Character'], false);

    update([ID_MAIN, ID_MEDIA]);
  }

  Future<void> refetch() async {
    scrollUpTo(0);

    final body = await Client.request(GqlQuery.character, {
      'id': id,
      'withAnime': true,
      'withManga': true,
      'onList': _onList,
      'sort': _sort.name,
    });
    if (body == null) return;

    _initAnime(body['Character'], true);
    _initManga(body['Character'], true);

    update([ID_MEDIA]);
  }

  @override
  Future<void> fetchPage() async {
    if (_onAnime && !_anime.hasNextPage) return;
    if (!_onAnime && !_manga.hasNextPage) return;

    final data = await Client.request(GqlQuery.character, {
      'id': id,
      'withAnime': _onAnime,
      'withManga': !_onAnime,
      'animePage': _anime.nextPage,
      'mangaPage': _manga.nextPage,
      'sort': _sort.name,
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
    final data =
        await Client.request(GqlMutation.toggleFavourite, {'character': id});
    if (data != null) _model!.isFavourite = !_model!.isFavourite;
    return _model!.isFavourite;
  }

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
        imageUrl: connection['node']['coverImage']['extraLarge'],
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
        imageUrl: connection['node']['coverImage']['extraLarge'],
        type: Explorable.manga,
        subtitle: Convert.clarifyEnum(connection['characterRole']),
      ));

    _manga.append(connections, data['manga']['pageInfo']['hasNextPage']);
  }

  @override
  void onInit() {
    super.onInit();
    if (_model == null) _fetch();
  }
}
