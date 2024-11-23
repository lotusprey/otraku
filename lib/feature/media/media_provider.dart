import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/extension/future_extension.dart';
import 'package:otraku/extension/iterable_extension.dart';
import 'package:otraku/extension/string_extension.dart';
import 'package:otraku/feature/discover/discover_model.dart';
import 'package:otraku/feature/edit/edit_model.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/feature/settings/settings_provider.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/feature/viewer/repository_provider.dart';
import 'package:otraku/util/graphql.dart';
import 'package:otraku/util/paged.dart';

final mediaProvider =
    AsyncNotifierProvider.autoDispose.family<MediaNotifier, Media, int>(
  MediaNotifier.new,
);

final mediaConnectionsProvider = AsyncNotifierProvider.autoDispose
    .family<MediaRelationsNotifier, MediaConnections, int>(
  MediaRelationsNotifier.new,
);

final mediaFollowingProvider = AsyncNotifierProvider.family<
    MediaFollowingNotifier, Paged<MediaFollowing>, int>(
  MediaFollowingNotifier.new,
);

class MediaNotifier extends AutoDisposeFamilyAsyncNotifier<Media, int> {
  @override
  FutureOr<Media> build(int arg) async {
    var data = await ref
        .read(repositoryProvider)
        .request(GqlQuery.media, {'id': arg, 'withInfo': true});
    data = data['Media'];

    final imageQuality = ref.read(persistenceProvider).options.imageQuality;

    final relatedMedia = <RelatedMedia>[];
    for (final relation in data['relations']['edges']) {
      if (relation['node'] != null) {
        relatedMedia.add(RelatedMedia(relation, imageQuality));
      }
    }

    final settings = await ref.watch(
      settingsProvider.selectAsync((settings) => settings),
    );

    return Media(
      Edit(data, settings),
      MediaInfo(data, imageQuality),
      MediaStats(data),
      relatedMedia,
    );
  }

  Future<Object?> toggleFavorite() {
    final type = state.valueOrNull?.info.type;
    if (type == null) return Future.value('User not yet loaded');

    return ref.read(repositoryProvider).request(
      GqlMutation.toggleFavorite,
      {(type == DiscoverType.anime ? 'anime' : 'manga'): arg},
    ).getErrorOrNull();
  }
}

class MediaRelationsNotifier
    extends AutoDisposeFamilyAsyncNotifier<MediaConnections, int> {
  @override
  FutureOr<MediaConnections> build(arg) =>
      _fetch(const MediaConnections(), null);

  Future<void> fetch(MediaTab tab) async {
    final oldState = state.valueOrNull ?? const MediaConnections();
    state = switch (tab) {
      MediaTab.info ||
      MediaTab.relations ||
      MediaTab.following ||
      MediaTab.statistics =>
        state,
      MediaTab.characters => oldState.characters.hasNext
          ? await AsyncValue.guard(() => _fetch(oldState, tab))
          : state,
      MediaTab.staff => oldState.staff.hasNext
          ? await AsyncValue.guard(() => _fetch(oldState, tab))
          : state,
      MediaTab.reviews => oldState.reviews.hasNext
          ? await AsyncValue.guard(() => _fetch(oldState, tab))
          : state,
      MediaTab.recommendations => oldState.recommendations.hasNext
          ? await AsyncValue.guard(() => _fetch(oldState, tab))
          : state,
    };
  }

  Future<MediaConnections> _fetch(
      MediaConnections oldState, MediaTab? tab) async {
    final variables = <String, dynamic>{'id': arg};
    if (tab == null) {
      variables['withRecommendations'] = true;
      variables['withCharacters'] = true;
      variables['withStaff'] = true;
      variables['withReviews'] = true;
    } else if (tab == MediaTab.recommendations) {
      variables['withRecommendations'] = true;
      variables['page'] = oldState.recommendations.next;
    } else if (tab == MediaTab.characters) {
      variables['withCharacters'] = true;
      variables['page'] = oldState.characters.next;
    } else if (tab == MediaTab.staff) {
      variables['withStaff'] = true;
      variables['page'] = oldState.staff.next;
    } else if (tab == MediaTab.reviews) {
      variables['withReviews'] = true;
      variables['page'] = oldState.reviews.next;
    }

    var data = await ref.read(repositoryProvider).request(
          GqlQuery.media,
          variables,
        );
    data = data['Media'];

    final imageQuality = ref.read(persistenceProvider).options.imageQuality;

    var characters = oldState.characters;
    var staff = oldState.staff;
    var reviews = oldState.reviews;
    var recommendations = oldState.recommendations;
    var languageToVoiceActors = [...oldState.languageToVoiceActors];
    var selectedLanguage = oldState.selectedLanguage;

    if (tab == null || tab == MediaTab.characters) {
      final map = data['characters'];
      final items = <MediaRelatedItem>[];
      for (final c in map['edges']) {
        final role = StringExtension.tryNoScreamingSnakeCase(c['role']);
        items.add(MediaRelatedItem(c['node'], role));

        if (c['voiceActors'] == null) continue;

        for (final va in c['voiceActors']) {
          final l = StringExtension.tryNoScreamingSnakeCase(va['languageV2']);
          if (l == null) continue;

          var languageMapping = languageToVoiceActors.firstWhereOrNull(
            (lm) => lm.language == l,
          );

          if (languageMapping == null) {
            languageMapping = (language: l, voiceActors: {});
            languageToVoiceActors.add(languageMapping);
          }

          final characterVoiceActors = languageMapping.voiceActors.putIfAbsent(
            items.last.id,
            () => [],
          );

          characterVoiceActors.add(MediaRelatedItem(va, l));
        }
      }

      languageToVoiceActors.sort((a, b) {
        if (a.language == 'Japanese') return -1;
        if (b.language == 'Japanese') return 1;
        return a.language.compareTo(b.language);
      });

      characters = characters.withNext(
        items,
        map['pageInfo']['hasNextPage'] ?? false,
      );
    }

    if (tab == null || tab == MediaTab.staff) {
      final map = data['staff'];
      final items = <MediaRelatedItem>[];
      for (final s in map['edges']) {
        items.add(MediaRelatedItem(s['node'], s['role']));
      }

      staff = staff.withNext(items, map['pageInfo']['hasNextPage'] ?? false);
    }

    if (tab == null || tab == MediaTab.reviews) {
      final map = data['reviews'];
      final items = <RelatedReview>[];
      for (final r in map['nodes']) {
        final item = RelatedReview.maybe(r);
        if (item != null) items.add(item);
      }

      reviews = reviews.withNext(
        items,
        map['pageInfo']['hasNextPage'] ?? false,
      );
    }

    if (tab == null || tab == MediaTab.recommendations) {
      final map = data['recommendations'];
      final items = <Recommendation>[];
      for (final r in map['nodes']) {
        if (r['mediaRecommendation'] != null) {
          items.add(Recommendation(r, imageQuality));
        }
      }

      recommendations = recommendations.withNext(
        items,
        map['pageInfo']['hasNextPage'] ?? false,
      );
    }

    return oldState.copyWith(
      recommendations: recommendations,
      characters: characters,
      staff: staff,
      reviews: reviews,
      languageToVoiceActors: languageToVoiceActors,
      selectedLanguage: selectedLanguage,
    );
  }

  void changeLanguage(int selectedLanguage) => state.whenData(
        (data) {
          if (selectedLanguage >= data.languageToVoiceActors.length) return;

          state = AsyncValue.data(MediaConnections(
            recommendations: data.recommendations,
            characters: data.characters,
            staff: data.staff,
            reviews: data.reviews,
            languageToVoiceActors: data.languageToVoiceActors,
            selectedLanguage: selectedLanguage,
          ));
        },
      );

  Future<Object?> rateRecommendation(int recId, bool? rating) {
    return ref.read(repositoryProvider).request(
      GqlMutation.rateRecommendation,
      {
        'id': arg,
        'recommendedId': recId,
        'rating': rating == null
            ? 'NO_RATING'
            : rating
                ? 'RATE_UP'
                : 'RATE_DOWN',
      },
    ).getErrorOrNull();
  }
}

class MediaFollowingNotifier
    extends FamilyAsyncNotifier<Paged<MediaFollowing>, int> {
  @override
  FutureOr<Paged<MediaFollowing>> build(arg) => _fetch(const Paged());

  Future<void> fetch() async {
    final oldState = state.valueOrNull ?? const Paged();
    if (!oldState.hasNext) return;
    state = await AsyncValue.guard(() => _fetch(oldState));
  }

  Future<Paged<MediaFollowing>> _fetch(Paged<MediaFollowing> oldState) async {
    final data = await ref.read(repositoryProvider).request(
      GqlQuery.mediaFollowing,
      {'mediaId': arg, 'page': oldState.next},
    );

    final items = <MediaFollowing>[];
    for (final f in data['Page']['mediaList']) {
      items.add(MediaFollowing(f));
    }

    return oldState.withNext(
      items,
      data['Page']['pageInfo']['hasNextPage'] ?? false,
    );
  }
}
