import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/models/paged.dart';
import 'package:otraku/common/models/relation.dart';
import 'package:otraku/common/utils/api.dart';
import 'package:otraku/common/utils/extensions.dart';
import 'package:otraku/common/utils/graphql.dart';
import 'package:otraku/common/utils/image_quality.dart';
import 'package:otraku/modules/character/character_models.dart';
import 'package:otraku/modules/discover/discover_models.dart';

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

final characterMediaProvider = StateNotifierProvider.autoDispose
    .family<CharacterMediaNotifier, CharacterMedia, int>(
  (ref, int id) =>
      CharacterMediaNotifier(id, ref.watch(characterFilterProvider(id))),
);

class CharacterMediaNotifier extends StateNotifier<CharacterMedia> {
  CharacterMediaNotifier(this.id, this.filter) : super(const CharacterMedia()) {
    _fetch(null);
  }

  final int id;
  final CharacterFilter filter;

  Future<void> fetch(bool onAnime) => _fetch(onAnime);

  Future<void> _fetch(bool? onAnime) async {
    final variables = <String, dynamic>{
      'id': id,
      'onList': filter.onList,
      'sort': filter.sort.name,
    };

    if (onAnime == null) {
      variables['withAnime'] = true;
      variables['withManga'] = true;
    } else if (onAnime) {
      if (!(state.anime.valueOrNull?.hasNext ?? true)) return;
      variables['withAnime'] = true;
      variables['page'] = state.anime.valueOrNull?.next ?? 1;
    } else if (!onAnime) {
      if (!(state.manga.valueOrNull?.hasNext ?? true)) return;
      variables['withManga'] = true;
      variables['page'] = state.manga.valueOrNull?.next ?? 1;
    }

    final data = await AsyncValue.guard<Map<String, dynamic>>(() async {
      final data = await Api.get(GqlQuery.character, variables);
      return data['Character'];
    });

    var anime = state.anime;
    var manga = state.manga;
    var languageToVoiceActors = state.languageToVoiceActors;
    var language = state.language;

    if (onAnime == null || onAnime) {
      anime = await AsyncValue.guard(() {
        if (data.hasError) throw data.error!;
        final map = data.value!['anime'];
        final value = anime.valueOrNull ?? const Paged();

        /// The map could be immutable, so a copy is made.
        languageToVoiceActors = {...state.languageToVoiceActors};

        final items = <Relation>[];
        for (final a in map['edges']) {
          items.add(Relation(
            id: a['node']['id'],
            title: a['node']['title']['userPreferred'],
            imageUrl: a['node']['coverImage'][imageQuality],
            subtitle: StringUtil.tryNoScreamingSnakeCase(a['characterRole']),
            type: DiscoverType.Anime,
          ));

          if (a['voiceActors'] != null) {
            for (final va in a['voiceActors']) {
              final l = StringUtil.tryNoScreamingSnakeCase(va['languageV2']);
              if (l == null) continue;

              final currentLanguage = languageToVoiceActors.putIfAbsent(
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
                type: DiscoverType.Staff,
              ));
            }
          }
        }

        if (language.isEmpty && languageToVoiceActors.isNotEmpty) {
          language = languageToVoiceActors.keys.first;
        }

        return Future.value(value.withNext(
          items,
          map['pageInfo']['hasNextPage'] ?? false,
        ));
      });
    }

    if (onAnime == null || !onAnime) {
      manga = await AsyncValue.guard(() {
        if (data.hasError) throw data.error!;
        final map = data.value!['manga'];
        final value = manga.valueOrNull ?? const Paged();

        final items = <Relation>[];
        for (final m in map['edges']) {
          items.add(Relation(
            id: m['node']['id'],
            title: m['node']['title']['userPreferred'],
            imageUrl: m['node']['coverImage'][imageQuality],
            subtitle: StringUtil.tryNoScreamingSnakeCase(m['characterRole']),
            type: DiscoverType.Manga,
          ));
        }

        return Future.value(value.withNext(
          items,
          map['pageInfo']['hasNextPage'] ?? false,
        ));
      });
    }

    state = CharacterMedia(
      anime: anime,
      manga: manga,
      languageToVoiceActors: languageToVoiceActors,
      language: language,
    );
  }

  void changeLanguage(String language) => state = CharacterMedia(
        anime: state.anime,
        manga: state.manga,
        languageToVoiceActors: state.languageToVoiceActors,
        language: language,
      );
}
