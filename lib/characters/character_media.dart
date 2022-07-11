import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/constants/media_sort.dart';
import 'package:otraku/models/relation.dart';
import 'package:otraku/utils/api.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/pagination.dart';
import 'package:otraku/utils/settings.dart';

final characterFilterProvider = StateProvider.autoDispose.family(
  (ref, _) => CharacterFilter(),
);

final characterMediaProvider = ChangeNotifierProvider.autoDispose.family(
  (ref, int id) =>
      CharacterMediaNotifier(id, ref.watch(characterFilterProvider(id))),
);

class CharacterMediaNotifier extends ChangeNotifier {
  CharacterMediaNotifier(this.id, this.filter) {
    fetch();
  }

  final int id;
  final CharacterFilter filter;
  var _state = const AsyncValue<void>.data(null);
  var _anime = Pagination<Relation>();
  var _manga = Pagination<Relation>();

  /// For each language, a list of voice actors
  /// is mapped to the corresponding media's id.
  final _languages = <String, Map<int, List<Relation>>>{};

  /// The currently selected language.
  var _language = '';

  AsyncValue get state => _state;
  Pagination<Relation> get anime => _anime;
  Pagination<Relation> get manga => _manga;
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
  void getMediaAndVoiceActors(
    List<Relation> media,
    List<Relation?> voiceActors,
  ) {
    final byLanguage = _languages[language];
    if (byLanguage == null) {
      media.addAll(_anime.items);
      return;
    }

    for (final a in _anime.items) {
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

  Future<void> fetch() async {
    _state = const AsyncValue.loading();

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
      _state = AsyncValue.error(data.error!, stackTrace: data.stackTrace);
      return;
    } else {
      _state = const AsyncValue.data(null);
    }

    _initAnime(data.value!['anime'], true);
    _initManga(data.value!['manga'], true);

    if (_languages.isNotEmpty) _language = _languages.keys.first;
    notifyListeners();
  }

  void _initAnime(Map<String, dynamic> data, bool clear) {
    if (clear) {
      _anime.items.clear();
      _languages.clear();
    }

    final items = <Relation>[];
    for (final a in data['edges']) {
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
            type: Explorable.staff,
          ));
        }
    }

    _anime.append(items, data['pageInfo']['hasNextPage']);
  }

  void _initManga(Map<String, dynamic> data, bool clear) {
    if (clear) _manga.items.clear();

    final items = <Relation>[];
    for (final m in data['edges'])
      items.add(Relation(
        id: m['node']['id'],
        title: m['node']['title']['userPreferred'],
        imageUrl: m['node']['coverImage'][Settings().imageQuality],
        subtitle: Convert.clarifyEnum(m['characterRole']),
        type: Explorable.manga,
      ));

    _manga.append(items, data['pageInfo']['hasNextPage']);
  }
}

class CharacterFilter {
  CharacterFilter({this.sort = MediaSort.TRENDING_DESC, this.onList});

  final MediaSort sort;
  final bool? onList;

  CharacterFilter copyWith({MediaSort? sort, bool? Function()? onList}) =>
      CharacterFilter(
        sort: sort ?? this.sort,
        onList: onList == null ? this.onList : onList(),
      );
}
