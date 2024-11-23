import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/extension/future_extension.dart';
import 'package:otraku/extension/iterable_extension.dart';
import 'package:otraku/extension/string_extension.dart';
import 'package:otraku/feature/character/character_filter_model.dart';
import 'package:otraku/feature/character/character_filter_provider.dart';
import 'package:otraku/feature/character/character_model.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/feature/viewer/repository_provider.dart';
import 'package:otraku/util/graphql.dart';
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

    final imageQuality = ref.read(persistenceProvider).options.imageQuality;

    var anime = oldState.anime;
    var manga = oldState.manga;
    var languageToVoiceActors = [...oldState.languageToVoiceActors];
    var selectedLanguage = oldState.selectedLanguage;

    if (onAnime == null || onAnime) {
      final map = data['anime'];
      final items = <CharacterRelatedItem>[];
      for (final a in map['edges']) {
        items.add(CharacterRelatedItem.media(
          a['node'],
          StringExtension.tryNoScreamingSnakeCase(a['characterRole']),
          imageQuality,
        ));

        if (a['voiceActors'] != null) {
          for (final va in a['voiceActors']) {
            final l = StringExtension.tryNoScreamingSnakeCase(va['languageV2']);
            if (l == null) continue;

            var languageMapping = languageToVoiceActors.firstWhereOrNull(
              (lm) => lm.language == l,
            );

            if (languageMapping == null) {
              languageMapping = (language: l, voiceActors: {});
              languageToVoiceActors.add(languageMapping);
            }

            final mediaVoiceActors = languageMapping.voiceActors.putIfAbsent(
              items.last.id,
              () => [],
            );

            mediaVoiceActors.add(CharacterRelatedItem.staff(va, l));
          }
        }

        languageToVoiceActors.sort((a, b) {
          if (a.language == 'Japanese') return -1;
          if (b.language == 'Japanese') return 1;
          return a.language.compareTo(b.language);
        });
      }

      anime = anime.withNext(items, map['pageInfo']['hasNextPage'] ?? false);
    }

    if (onAnime == null || !onAnime) {
      final map = data['manga'];
      final items = <CharacterRelatedItem>[];
      for (final m in map['edges']) {
        items.add(CharacterRelatedItem.media(
          m['node'],
          StringExtension.tryNoScreamingSnakeCase(m['characterRole']),
          imageQuality,
        ));
      }

      manga = manga.withNext(items, map['pageInfo']['hasNextPage'] ?? false);
    }

    return CharacterMedia(
      anime: anime,
      manga: manga,
      languageToVoiceActors: languageToVoiceActors,
      selectedLanguage: selectedLanguage,
    );
  }

  void changeLanguage(int selectedLanguage) => state.whenData(
        (data) {
          if (selectedLanguage >= data.languageToVoiceActors.length) return;

          state = AsyncValue.data(CharacterMedia(
            anime: data.anime,
            manga: data.manga,
            languageToVoiceActors: data.languageToVoiceActors,
            selectedLanguage: selectedLanguage,
          ));
        },
      );
}
