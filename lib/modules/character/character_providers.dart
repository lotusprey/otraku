import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/utils/extensions.dart';
import 'package:otraku/modules/character/character_models.dart';
import 'package:otraku/modules/discover/discover_models.dart';
import 'package:otraku/common/models/relation.dart';
import 'package:otraku/common/utils/api.dart';
import 'package:otraku/common/utils/graphql.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/modules/settings/settings_model.dart';
import 'package:otraku/modules/settings/settings_provider.dart';

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

    final settings =
        ref.watch(settingsProvider).valueOrNull ?? Settings.empty();
    return Character(data['Character'], settings.personNaming);
  },
);

final characterMediaProvider = AsyncNotifierProvider.autoDispose
    .family<CharacterMediaNotifier, CharacterMedia, int>(
  CharacterMediaNotifier.new,
);

final characterFilterProvider = NotifierProvider.autoDispose
    .family<CharacterFilterNotifier, CharacterFilter, int>(
  CharacterFilterNotifier.new,
);

class CharacterMediaNotifier
    extends AutoDisposeFamilyAsyncNotifier<CharacterMedia, int> {
  late CharacterFilter filter;

  @override
  FutureOr<CharacterMedia> build(arg) async {
    filter = ref.watch(characterFilterProvider(arg));
    return await _fetch(const CharacterMedia(), null);
  }

  Future<void> fetch(bool onAnime) async {
    final oldState = state.valueOrNull ?? const CharacterMedia();
    if (onAnime) {
      if (!oldState.anime.hasNext) return;
    } else {
      if (!oldState.manga.hasNext) return;
    }
    state = await AsyncValue.guard(() => _fetch(oldState, onAnime));
  }

  Future<CharacterMedia> _fetch(CharacterMedia oldState, bool? onAnime) async {
    final variables = {
      'id': arg,
      'onList': filter.inLists,
      'sort': filter.sort.name,
    };

    if (onAnime == null) {
      variables['withAnime'] = true;
      variables['withManga'] = true;
    } else if (onAnime) {
      variables['withAnime'] = true;
      variables['page'] = oldState.anime.next;
    } else if (!onAnime) {
      variables['withManga'] = true;
      variables['page'] = oldState.manga.next;
    }

    var data = await Api.get(GqlQuery.character, variables);
    data = data['Character'];

    var anime = oldState.anime;
    var manga = oldState.manga;
    var languageToVoiceActors = {...oldState.languageToVoiceActors};
    var language = oldState.language;

    if (onAnime == null || onAnime) {
      final map = data['anime'];
      final items = <Relation>[];
      for (final a in map['edges']) {
        items.add(Relation(
          id: a['node']['id'],
          title: a['node']['title']['userPreferred'],
          imageUrl: a['node']['coverImage'][Options().imageQuality.value],
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

        if (language.isEmpty && languageToVoiceActors.isNotEmpty) {
          language = languageToVoiceActors.keys.first;
        }

        anime = anime.withNext(items, map['pageInfo']['hasNextPage'] ?? false);
      }
    }

    if (onAnime == null || !onAnime) {
      final map = data['manga'];
      final items = <Relation>[];
      for (final m in map['edges']) {
        items.add(Relation(
          id: m['node']['id'],
          title: m['node']['title']['userPreferred'],
          imageUrl: m['node']['coverImage'][Options().imageQuality.value],
          subtitle: StringUtil.tryNoScreamingSnakeCase(m['characterRole']),
          type: DiscoverType.Manga,
        ));
      }

      manga = manga.withNext(items, map['pageInfo']['hasNextPage'] ?? false);
    }

    return CharacterMedia(
      anime: anime,
      manga: manga,
      languageToVoiceActors: languageToVoiceActors,
      language: language,
    );
  }

  void changeLanguage(String language) => state = state.whenData(
        (data) => CharacterMedia(
          anime: data.anime,
          manga: data.manga,
          languageToVoiceActors: data.languageToVoiceActors,
          language: language,
        ),
      );
}

class CharacterFilterNotifier
    extends AutoDisposeFamilyNotifier<CharacterFilter, int> {
  @override
  CharacterFilter build(arg) => CharacterFilter();

  @override
  set state(CharacterFilter newState) => super.state = newState;
}
