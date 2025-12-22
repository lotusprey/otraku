import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/extension/future_extension.dart';
import 'package:otraku/feature/character/character_item_model.dart';
import 'package:otraku/feature/discover/discover_filter_model.dart';
import 'package:otraku/feature/staff/staff_item_model.dart';
import 'package:otraku/feature/studio/studio_item_model.dart';
import 'package:otraku/feature/user/user_item_model.dart';
import 'package:otraku/feature/discover/discover_filter_provider.dart';
import 'package:otraku/feature/discover/discover_model.dart';
import 'package:otraku/feature/review/review_models.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/feature/viewer/repository_provider.dart';
import 'package:otraku/util/graphql.dart';

final discoverProvider = AsyncNotifierProvider<DiscoverNotifier, DiscoverItems>(
  DiscoverNotifier.new,
);

class DiscoverNotifier extends AsyncNotifier<DiscoverItems> {
  late DiscoverFilter filter;

  @override
  FutureOr<DiscoverItems> build() {
    filter = ref.watch(discoverFilterProvider);
    return switch (filter.type) {
      .anime => _fetchAnime(const DiscoverAnimeItems()),
      .manga => _fetchManga(const DiscoverMangaItems()),
      .character => _fetchCharacters(const DiscoverCharacterItems()),
      .staff => _fetchStaff(const DiscoverStaffItems()),
      .studio => _fetchStudios(const DiscoverStudioItems()),
      .user => _fetchUsers(const DiscoverUserItems()),
      .review => _fetchReviews(const DiscoverReviewItems()),
      .recommendation => _fetchRecommendations(const DiscoverRecommendationItems()),
    };
  }

  Future<void> fetch() async {
    final oldValue = state.value;
    state = await AsyncValue.guard(
      () => switch (filter.type) {
        .anime => _fetchAnime(
          (oldValue is DiscoverAnimeItems) ? oldValue : const DiscoverAnimeItems(),
        ),
        .manga => _fetchManga(
          (oldValue is DiscoverMangaItems) ? oldValue : const DiscoverMangaItems(),
        ),
        .character => _fetchCharacters(
          (oldValue is DiscoverCharacterItems) ? oldValue : const DiscoverCharacterItems(),
        ),
        .staff => _fetchStaff(
          (oldValue is DiscoverStaffItems) ? oldValue : const DiscoverStaffItems(),
        ),
        .studio => _fetchStudios(
          (oldValue is DiscoverStudioItems) ? oldValue : const DiscoverStudioItems(),
        ),
        .user => _fetchUsers(
          (oldValue is DiscoverUserItems) ? oldValue : const DiscoverUserItems(),
        ),
        .review => _fetchReviews(
          (oldValue is DiscoverReviewItems) ? oldValue : const DiscoverReviewItems(),
        ),
        .recommendation => _fetchRecommendations(
          (oldValue is DiscoverRecommendationItems)
              ? oldValue
              : const DiscoverRecommendationItems(),
        ),
      },
    );
  }

  Future<DiscoverItems> _fetchAnime(DiscoverAnimeItems oldValue) async {
    final data = await ref.read(repositoryProvider).request(GqlQuery.mediaPage, {
      'page': oldValue.pages.next,
      'type': 'ANIME',
      if (filter.search.isNotEmpty) ...{
        'search': filter.search,
        ...filter.mediaFilter.toGraphQlVariables(ofAnime: true)..['sort'] = 'SEARCH_MATCH',
      } else
        ...filter.mediaFilter.toGraphQlVariables(ofAnime: true),
    });

    final imageQuality = ref.read(persistenceProvider).options.imageQuality;

    final items = <DiscoverMediaItem>[];
    for (final m in data['Page']['media']) {
      items.add(DiscoverMediaItem(m, imageQuality));
    }

    return DiscoverAnimeItems(
      oldValue.pages.withNext(items, data['Page']['pageInfo']['hasNextPage'] ?? false),
    );
  }

  Future<DiscoverItems> _fetchManga(DiscoverMangaItems oldValue) async {
    final data = await ref.read(repositoryProvider).request(GqlQuery.mediaPage, {
      'page': oldValue.pages.next,
      'type': 'MANGA',
      if (filter.search.isNotEmpty) ...{
        'search': filter.search,
        ...filter.mediaFilter.toGraphQlVariables(ofAnime: false)..['sort'] = 'SEARCH_MATCH',
      } else
        ...filter.mediaFilter.toGraphQlVariables(ofAnime: false),
    });

    final imageQuality = ref.read(persistenceProvider).options.imageQuality;

    final items = <DiscoverMediaItem>[];
    for (final m in data['Page']['media']) {
      items.add(DiscoverMediaItem(m, imageQuality));
    }

    return DiscoverMangaItems(
      oldValue.pages.withNext(items, data['Page']['pageInfo']['hasNextPage'] ?? false),
    );
  }

  Future<DiscoverItems> _fetchCharacters(DiscoverCharacterItems oldValue) async {
    final data = await ref.read(repositoryProvider).request(GqlQuery.characterPage, {
      'page': oldValue.pages.next,
      if (filter.search.isNotEmpty) 'search': filter.search,
      if (filter.hasBirthday) 'isBirthday': true,
    });

    final items = <CharacterItem>[];
    for (final c in data['Page']['characters']) {
      items.add(CharacterItem(c));
    }

    return DiscoverCharacterItems(
      oldValue.pages.withNext(items, data['Page']['pageInfo']['hasNextPage'] ?? false),
    );
  }

  Future<DiscoverItems> _fetchStaff(DiscoverStaffItems oldValue) async {
    final data = await ref.read(repositoryProvider).request(GqlQuery.staffPage, {
      'page': oldValue.pages.next,
      if (filter.search.isNotEmpty) 'search': filter.search,
      if (filter.hasBirthday) 'isBirthday': true,
    });

    final items = <StaffItem>[];
    for (final s in data['Page']['staff']) {
      items.add(StaffItem(s));
    }

    return DiscoverStaffItems(
      oldValue.pages.withNext(items, data['Page']['pageInfo']['hasNextPage'] ?? false),
    );
  }

  Future<DiscoverItems> _fetchStudios(DiscoverStudioItems oldValue) async {
    final data = await ref.read(repositoryProvider).request(GqlQuery.studioPage, {
      'page': oldValue.pages.next,
      if (filter.search.isNotEmpty) 'search': filter.search,
    });

    final items = <StudioItem>[];
    for (final s in data['Page']['studios']) {
      items.add(StudioItem(s));
    }

    return DiscoverStudioItems(
      oldValue.pages.withNext(items, data['Page']['pageInfo']['hasNextPage'] ?? false),
    );
  }

  Future<DiscoverItems> _fetchUsers(DiscoverUserItems oldValue) async {
    final data = await ref.read(repositoryProvider).request(GqlQuery.userPage, {
      'page': oldValue.pages.next,
      if (filter.search.isNotEmpty) 'search': filter.search,
    });

    final items = <UserItem>[];
    for (final u in data['Page']['users']) {
      items.add(UserItem(u));
    }

    return DiscoverUserItems(
      oldValue.pages.withNext(items, data['Page']['pageInfo']['hasNextPage'] ?? false),
    );
  }

  Future<DiscoverItems> _fetchReviews(DiscoverReviewItems oldValue) async {
    final data = await ref.read(repositoryProvider).request(GqlQuery.reviewPage, {
      'page': oldValue.pages.next,
      'sort': filter.reviewsFilter.sort.value,
      if (filter.reviewsFilter.mediaType != null)
        'mediaType': filter.reviewsFilter.mediaType!.value,
    });

    final items = <ReviewItem>[];
    for (final r in data['Page']['reviews']) {
      items.add(ReviewItem(r));
    }

    return DiscoverReviewItems(
      oldValue.pages.withNext(items, data['Page']['pageInfo']['hasNextPage'] ?? false),
    );
  }

  Future<DiscoverItems> _fetchRecommendations(DiscoverRecommendationItems oldValue) async {
    final data = await ref.read(repositoryProvider).request(GqlQuery.recommendationsPage, {
      'page': oldValue.pages.next,
      'sort': filter.recommendationsFilter.sort.value,
      if (filter.recommendationsFilter.inLists != null)
        'onList': filter.recommendationsFilter.inLists,
    });

    final imageQuality = ref.read(persistenceProvider).options.imageQuality;

    final items = <DiscoverRecommendationItem>[];
    for (final r in data['Page']['recommendations']) {
      items.add(DiscoverRecommendationItem(r, imageQuality));
    }

    return DiscoverRecommendationItems(
      oldValue.pages.withNext(items, data['Page']['pageInfo']['hasNextPage'] ?? false),
    );
  }

  Future<Object?> rateRecommendation(int mediaId, int recommendedMediaId, bool? rating) {
    return ref.read(repositoryProvider).request(GqlMutation.rateRecommendation, {
      'id': mediaId,
      'recommendedId': recommendedMediaId,
      'rating': rating == null
          ? 'NO_RATING'
          : rating
          ? 'RATE_UP'
          : 'RATE_DOWN',
    }).getErrorOrNull();
  }
}
