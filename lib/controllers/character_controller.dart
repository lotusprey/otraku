import 'package:otraku/models/character_model.dart';
import 'package:otraku/models/relation.dart';
import 'package:otraku/utils/api.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/constants/media_sort.dart';
import 'package:otraku/models/page_model.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/pagination_controller.dart';
import 'package:otraku/utils/scrolling_controller.dart';
import 'package:otraku/utils/settings.dart';

class CharacterController extends ScrollingController {
  // GetBuilder ids.
  static const ID_MAIN = 0;
  static const ID_MEDIA = 1;

  CharacterController(this.id);

  final int id;
  CharacterModel? _model;
  final _anime = PageModel<Relation>();
  final _manga = PageModel<Relation>();
  final _voiceActors = <String, Map<int, List<Relation>>>{};
  final _languages = <String>[];
  bool _onAnime = true;
  int _langIndex = 0;
  MediaSort _sort = MediaSort.TRENDING_DESC;
  bool? _onList;

  CharacterModel? get model => _model;
  List<Relation> get anime => _anime.items;
  List<Relation> get manga => _manga.items;
  List<String> get languages => _languages;

  bool get onAnime => _onAnime;
  set onAnime(bool val) {
    _onAnime = val;
    update([ID_MEDIA]);
  }

  MediaSort get sort => _sort;
  bool? get onList => _onList;
  int get langIndex => _langIndex;
  set langIndex(int val) {
    _langIndex = val;
    update([ID_MEDIA]);
  }

  void filter(int langIndexVal, MediaSort sortVal, bool? onListVal) {
    final mustRefetch = sortVal != _sort || onListVal != _onList;

    if (langIndexVal != _langIndex) {
      _langIndex = langIndexVal;
      if (!mustRefetch) update([ID_MEDIA]);
    }

    if (mustRefetch) {
      _sort = sortVal;
      _onList = onListVal;
      refetch();
    }
  }

  Future<void> _fetch() async {
    final data = await Api.request(GqlQuery.character, {
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
    scrollCtrl.scrollToTop();

    final body = await Api.request(GqlQuery.character, {
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

    final data = await Api.request(GqlQuery.character, {
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
        await Api.request(GqlMutation.toggleFavorite, {'character': id});
    if (data != null) _model!.isFavourite = !_model!.isFavourite;
    return _model!.isFavourite;
  }

  void selectMediaAndVoiceActors(
    List<Relation> mediaList,
    List<Relation?> voiceActorList,
  ) {
    if (languages.isEmpty || _langIndex >= languages.length) return;

    final byLanguage = _voiceActors[languages[_langIndex]];
    if (byLanguage == null) {
      mediaList.addAll(_anime.items);
      return;
    }

    for (final a in _anime.items) {
      final vas = byLanguage[a.id];
      if (vas == null || vas.isEmpty) {
        mediaList.add(a);
        voiceActorList.add(null);
        continue;
      }

      for (final va in vas) {
        mediaList.add(a);
        voiceActorList.add(va);
      }
    }
  }

  void _initAnime(Map<String, dynamic> data, bool clear) {
    if (clear) {
      _languages.clear();
      _anime.clear();
      _voiceActors.clear();
    }

    final items = <Relation>[];
    for (final a in data['anime']['edges']) {
      items.add(Relation(
        id: a['node']['id'],
        title: a['node']['title']['userPreferred'],
        imageUrl: a['node']['coverImage'][Settings().imageQuality],
        subtitle: Convert.clarifyEnum(a['characterRole']),
        type: Explorable.anime,
      ));

      if (a['voiceActors'] != null)
        for (final va in a['voiceActors']) {
          final l = Convert.clarifyEnum(va['languageV2']);
          if (l == null) continue;

          if (!_languages.contains(l)) _languages.add(l);

          final currentLanguage = _voiceActors.putIfAbsent(
            l,
            () => <int, List<Relation>>{},
          );

          final currentMedia = currentLanguage.putIfAbsent(
            items.last.id,
            () => [],
          );

          currentMedia.add(Relation(
            id: va['id'],
            title: va['name']['userPreferred'],
            imageUrl: va['image']['large'],
            subtitle: l,
            type: Explorable.staff,
          ));
        }
    }

    _anime.append(items, data['anime']['pageInfo']['hasNextPage']);
  }

  void _initManga(Map<String, dynamic> data, bool clear) {
    if (clear) _manga.clear();

    final items = <Relation>[];
    for (final m in data['manga']['edges'])
      items.add(Relation(
        id: m['node']['id'],
        title: m['node']['title']['userPreferred'],
        imageUrl: m['node']['coverImage'][Settings().imageQuality],
        subtitle: Convert.clarifyEnum(m['characterRole']),
        type: Explorable.manga,
      ));

    _manga.append(items, data['manga']['pageInfo']['hasNextPage']);
  }

  @override
  void onInit() {
    super.onInit();
    if (_model == null) _fetch();
  }
}
