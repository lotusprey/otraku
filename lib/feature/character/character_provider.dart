import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/character/character_filter_model.dart';
import 'package:otraku/util/extensions.dart';
import 'package:otraku/feature/character/character_filter_provider.dart';
import 'package:otraku/feature/character/character_model.dart';
import 'package:otraku/feature/discover/discover_models.dart';
import 'package:otraku/model/relation.dart';
import 'package:otraku/feature/viewer/repository_provider.dart';
import 'package:otraku/util/graphql.dart';
import 'package:otraku/util/persistence.dart';
import 'package:otraku/feature/settings/settings_provider.dart';

final characterProvider =
    AsyncNotifierProvider.autoDispose.family<CharacterNotifier, Character, int>(
  CharacterNotifier.new,
);

class CharacterNotifier extends AutoDisposeFamilyAsyncNotifier<Character, int> {
  @override
  FutureOr<Character> build(int arg) async {
    final data = await ref.read(repositoryProvider).request(
      GqlQuery.character,
      {'id': arg, 'withInfo': true},
    );

    final personNaming = await ref.watch(
      settingsProvider.selectAsync((data) => data.personNaming),
    );

    return Character(data['Character'], personNaming);
  }

  Future<Object?> toggleFavorite() {
    return ref.read(repositoryProvider).request(
      GqlMutation.toggleFavorite,
      {'character': arg},
    ).getErrorOrNull();
  }
}

final characterMediaProvider = AsyncNotifierProvider.autoDispose
    .family<CharacterMediaNotifier, CharacterMedia, int>(
  CharacterMediaNotifier.new,
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
      'sort': filter.sort.value,
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

    var data = await ref
        .read(repositoryProvider)
        .request(GqlQuery.character, variables);
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
          imageUrl: a['node']['coverImage'][Persistence().imageQuality.value],
          subtitle: StringUtil.tryNoScreamingSnakeCase(a['characterRole']),
          type: DiscoverType.anime,
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
              type: DiscoverType.staff,
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
          imageUrl: m['node']['coverImage'][Persistence().imageQuality.value],
          subtitle: StringUtil.tryNoScreamingSnakeCase(m['characterRole']),
          type: DiscoverType.manga,
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
