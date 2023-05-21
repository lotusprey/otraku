import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/modules/discover/discover_models.dart';
import 'package:otraku/modules/edit/edit_model.dart';
import 'package:otraku/modules/media/media_models.dart';
import 'package:otraku/common/models/relation.dart';
import 'package:otraku/modules/settings/settings_provider.dart';
import 'package:otraku/common/utils/api.dart';
import 'package:otraku/common/utils/convert.dart';
import 'package:otraku/common/utils/graphql.dart';
import 'package:otraku/common/models/paged.dart';

Future<bool> toggleFavoriteMedia(int id, bool isAnime) async {
  try {
    await Api.get(
      GqlMutation.toggleFavorite,
      {(isAnime ? 'anime' : 'manga'): id},
    );
    return true;
  } catch (_) {
    return false;
  }
}

Future<bool> rateRecommendation(int mediaId, int recId, bool? rating) async {
  try {
    await Api.get(GqlMutation.rateRecommendation, {
      'id': mediaId,
      'recommendedId': recId,
      'rating': rating == null
          ? 'NO_RATING'
          : rating
              ? 'RATE_UP'
              : 'RATE_DOWN',
    });
    return true;
  } catch (_) {
    return false;
  }
}

final mediaProvider = FutureProvider.autoDispose.family<Media, int>(
  (ref, mediaId) async {
    var data = await Api.get(GqlQuery.media, {'id': mediaId, 'withInfo': true});
    data = data['Media'];

    final relatedMedia = <RelatedMedia>[];
    for (final relation in data['relations']['edges']) {
      if (relation['node'] != null) relatedMedia.add(RelatedMedia(relation));
    }

    return Media(
      Edit(data, ref.watch(settingsProvider.notifier).value),
      MediaInfo(data),
      MediaStats(data),
      relatedMedia,
    );
  },
);

final mediaRelationsProvider = StateNotifierProvider.autoDispose
    .family<MediaRelationsNotifier, MediaRelations, int>(
  (ref, int mediaId) => MediaRelationsNotifier(mediaId),
);

class MediaRelationsNotifier extends StateNotifier<MediaRelations> {
  MediaRelationsNotifier(this.mediaId) : super(const MediaRelations()) {
    _fetch(null);
  }

  final int mediaId;

  Future<void> fetch(MediaTab tab) => _fetch(tab);

  Future<void> _fetch(MediaTab? tab) async {
    if (tab == MediaTab.info ||
        tab == MediaTab.relations ||
        tab == MediaTab.statistics) {
      return;
    }

    final variables = <String, dynamic>{'id': mediaId};
    if (tab == null) {
      variables['withRecommendations'] = true;
      variables['withCharacters'] = true;
      variables['withStaff'] = true;
      variables['withReviews'] = true;
    } else if (tab == MediaTab.recommendations) {
      if (!(state.recommendations.valueOrNull?.hasNext ?? true)) return;
      variables['withRecommendations'] = true;
      variables['page'] = state.recommendations.valueOrNull?.next ?? 1;
    } else if (tab == MediaTab.characters) {
      if (!(state.characters.valueOrNull?.hasNext ?? true)) return;
      variables['withCharacters'] = true;
      variables['page'] = state.characters.valueOrNull?.next ?? 1;
    } else if (tab == MediaTab.staff) {
      if (!(state.staff.valueOrNull?.hasNext ?? true)) return;
      variables['withStaff'] = true;
      variables['page'] = state.staff.valueOrNull?.next ?? 1;
    } else if (tab == MediaTab.reviews) {
      if (!(state.reviews.valueOrNull?.hasNext ?? true)) return;
      variables['withReviews'] = true;
      variables['page'] = state.reviews.valueOrNull?.next ?? 1;
    }

    final data = await AsyncValue.guard<Map<String, dynamic>>(() async {
      final data = await Api.get(GqlQuery.media, variables);
      return data['Media'];
    });

    var recommended = state.recommendations;
    var characters = state.characters;
    var staff = state.staff;
    var reviews = state.reviews;
    var languageToVoiceActors = state.languageToVoiceActors;
    var language = state.language;

    if (tab == null || tab == MediaTab.recommendations) {
      recommended = await AsyncValue.guard(() {
        if (data.hasError) throw data.error!;
        final map = data.value!['recommendations'];
        final value = recommended.valueOrNull ?? const Paged();

        final items = <Recommendation>[];
        for (final r in map['nodes']) {
          if (r['mediaRecommendation'] != null) items.add(Recommendation(r));
        }

        return Future.value(
          value.withNext(items, map['pageInfo']['hasNextPage'] ?? false),
        );
      });
    }

    if (tab == null || tab == MediaTab.characters) {
      characters = await AsyncValue.guard(() {
        if (data.hasError) throw data.error!;
        final map = data.value!['characters'];
        final value = characters.valueOrNull ?? const Paged();

        /// The map could be immutable, so a copy is made.
        languageToVoiceActors = {...state.languageToVoiceActors};

        final items = <Relation>[];
        for (final c in map['edges']) {
          items.add(Relation(
            id: c['node']['id'],
            title: c['node']['name']['userPreferred'],
            imageUrl: c['node']['image']['large'],
            subtitle: Convert.clarifyEnum(c['role']),
            type: DiscoverType.character,
          ));

          if (c['voiceActors'] == null) continue;

          for (final va in c['voiceActors']) {
            final l = Convert.clarifyEnum(va['languageV2']);
            if (l == null) continue;

            final currentLanguage = languageToVoiceActors.putIfAbsent(
              l,
              () => <int, List<Relation>>{},
            );

            final currentCharacter = currentLanguage.putIfAbsent(
              items.last.id,
              () => [],
            );

            currentCharacter.add(Relation(
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

        return Future.value(
          value.withNext(items, map['pageInfo']['hasNextPage'] ?? false),
        );
      });
    }

    if (tab == null || tab == MediaTab.staff) {
      staff = await AsyncValue.guard(() {
        if (data.hasError) throw data.error!;
        final map = data.value!['staff'];
        final value = staff.valueOrNull ?? const Paged();

        final items = <Relation>[];
        for (final s in map['edges']) {
          items.add(Relation(
            id: s['node']['id'],
            title: s['node']['name']['userPreferred'],
            imageUrl: s['node']['image']['large'],
            subtitle: s['role'],
            type: DiscoverType.staff,
          ));
        }

        return Future.value(
          value.withNext(items, map['pageInfo']['hasNextPage'] ?? false),
        );
      });
    }

    if (tab == null || tab == MediaTab.reviews) {
      reviews = await AsyncValue.guard(() {
        if (data.hasError) throw data.error!;
        final map = data.value!['reviews'];
        final value = reviews.valueOrNull ?? const Paged();

        final items = <RelatedReview>[];
        for (final r in map['nodes']) {
          final item = RelatedReview.maybe(r);
          if (item != null) items.add(item);
        }

        return Future.value(
          value.withNext(items, map['pageInfo']['hasNextPage'] ?? false),
        );
      });
    }

    state = MediaRelations(
      recommendations: recommended,
      characters: characters,
      staff: staff,
      reviews: reviews,
      languageToVoiceActors: languageToVoiceActors,
      language: language,
    );
  }

  void changeLanguage(String language) => state = MediaRelations(
        recommendations: state.recommendations,
        characters: state.characters,
        staff: state.staff,
        reviews: state.reviews,
        languageToVoiceActors: state.languageToVoiceActors,
        language: language,
      );
}
