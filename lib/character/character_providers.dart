import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/character/character_models.dart';
import 'package:otraku/discover/discover_models.dart';
import 'package:otraku/common/relation.dart';
import 'package:otraku/utils/api.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/common/paged.dart';
import 'package:otraku/utils/options.dart';

/// Favorite/Unfavorite character. Returns `true` if successful.
Future<bool> toggleFavoriteCharacter(int characterId) async {
  try {
    await Api.get(GqlMutation.toggleFavorite, {'character': characterId});
    return true;
  } catch (_) {
    return false;
  }
}

final characterProvider = FutureProvider.autoDispose.family(
  (ref, int id) async {
    final data = await Api.get(
      GqlQuery.character,
      {'id': id, 'withInfo': true},
    );
    return Character(data['Character']);
  },
);

final characterFilterProvider =
    StateProvider.autoDispose.family((ref, _) => CharacterFilter());

final characterMediaProvider = ChangeNotifierProvider.autoDispose.family(
  (ref, int id) =>
      CharacterMediaNotifier(id, ref.watch(characterFilterProvider(id))),
);

class CharacterMediaNotifier extends ChangeNotifier {
  CharacterMediaNotifier(this.id, this.filter) {
    _fetch();
  }

  final int id;
  final CharacterFilter filter;
  var _anime = const AsyncValue<Paged<Relation>>.loading();
  var _manga = const AsyncValue<Paged<Relation>>.loading();

  /// For each language, a list of voice actors
  /// is mapped to the corresponding media's id.
  final _languages = <String, Map<int, List<Relation>>>{};

  /// The currently selected language.
  var _language = '';

  AsyncValue<Paged<Relation>> get anime => _anime;
  AsyncValue<Paged<Relation>> get manga => _manga;
  Iterable<String> get languages => _languages.keys;
  String get language => _language;
  set language(String l) {
    _language = l;
    notifyListeners();
  }

  /// Fill [media] and [voiceActors] lists, based on the currently selected
  /// [language]. The lists must end up with equal [length] or if an incorrect
  /// [language] is selected, [voiceActors] should be empty. If there are
  /// multiple VAs for a media, add the corresponding media item in [media]
  /// enough times to compensate. If there are no VAs to a media, compensate
  /// with one `null` item in [voiceActors].
  void getAnimeAndVoiceActors(
    List<Relation> media,
    List<Relation?> voiceActors,
  ) {
    final anime = _anime.valueOrNull?.items;
    if (anime == null || anime.isEmpty) return;

    final byLanguage = _languages[_language];
    if (byLanguage == null) {
      media.addAll(anime);
      return;
    }

    for (final a in anime) {
      final vas = byLanguage[a.id];
      if (vas == null || vas.isEmpty) {
        media.add(a);
        voiceActors.add(null);
        continue;
      }

      for (final va in vas) {
        media.add(a);
        voiceActors.add(va);
      }
    }
  }

  Future<void> _fetch() async {
    final data = await AsyncValue.guard<Map<String, dynamic>>(() async {
      final data = await Api.get(GqlQuery.character, {
        'id': id,
        'withAnime': true,
        'withManga': true,
        'onList': filter.onList,
        'sort': filter.sort.name,
      });
      return data['Character'];
    });

    if (data.hasError) {
      _anime = AsyncValue.error(data.error!, data.stackTrace!);
      _manga = AsyncValue.error(data.error!, data.stackTrace!);
      return;
    }

    _anime = const AsyncValue.data(Paged());
    _manga = const AsyncValue.data(Paged());

    _initAnime(data.value!['anime']);
    _initManga(data.value!['manga']);

    if (_languages.isNotEmpty) _language = _languages.keys.first;
    notifyListeners();
  }

  Future<void> fetchPage(bool ofAnime) async {
    final value = ofAnime ? _anime.valueOrNull : _manga.valueOrNull;
    if (value == null || !value.hasNext) return;

    final data = await AsyncValue.guard<Map<String, dynamic>>(() async {
      final data = await Api.get(GqlQuery.character, {
        'id': id,
        'withAnime': ofAnime,
        'withManga': !ofAnime,
        'onList': filter.onList,
        'sort': filter.sort.name,
        'page': value.next,
      });
      return data['Character'];
    });

    if (data.hasError) {
      ofAnime
          ? _anime = AsyncValue.error(data.error!, data.stackTrace!)
          : _manga = AsyncValue.error(data.error!, data.stackTrace!);
      return;
    }

    ofAnime
        ? _initAnime(data.value!['anime'])
        : _initManga(data.value!['manga']);
    notifyListeners();
  }

  void _initAnime(Map<String, dynamic> data) {
    var value = _anime.valueOrNull;
    if (value == null) return;

    final items = <Relation>[];
    for (final a in data['edges']) {
      items.add(Relation(
        id: a['node']['id'],
        title: a['node']['title']['userPreferred'],
        imageUrl: a['node']['coverImage'][Options().imageQuality.value],
        subtitle: Convert.clarifyEnum(a['characterRole']),
        type: DiscoverType.anime,
      ));

      if (a['voiceActors'] != null) {
        for (final va in a['voiceActors']) {
          final l = Convert.clarifyEnum(va['languageV2']);
          if (l == null) continue;

          final currentLanguage = _languages.putIfAbsent(
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
            type: DiscoverType.staff,
          ));
        }
      }
    }

    value = value.withNext(items, data['pageInfo']['hasNextPage']);
    _anime = AsyncValue.data(value);
  }

  void _initManga(Map<String, dynamic> data) {
    var value = _manga.valueOrNull;
    if (value == null) return;

    final items = <Relation>[];
    for (final m in data['edges']) {
      items.add(Relation(
        id: m['node']['id'],
        title: m['node']['title']['userPreferred'],
        imageUrl: m['node']['coverImage'][Options().imageQuality.value],
        subtitle: Convert.clarifyEnum(m['characterRole']),
        type: DiscoverType.manga,
      ));
    }

    value = value.withNext(items, data['pageInfo']['hasNextPage']);
    _manga = AsyncValue.data(value);
  }
}
