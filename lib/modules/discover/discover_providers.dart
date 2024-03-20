import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/modules/character/character_models.dart';
import 'package:otraku/common/models/tile_item.dart';
import 'package:otraku/modules/discover/discover_models.dart';
import 'package:otraku/modules/review/review_models.dart';
import 'package:otraku/modules/staff/staff_models.dart';
import 'package:otraku/modules/studio/studio_models.dart';
import 'package:otraku/modules/user/user_models.dart';
import 'package:otraku/common/utils/api.dart';
import 'package:otraku/common/utils/graphql.dart';

final discoverProvider = AsyncNotifierProvider<DiscoverNotifier, DiscoverItems>(
  DiscoverNotifier.new,
);

final discoverFilterProvider =
    NotifierProvider<DiscoverFilterNotifier, DiscoverFilter>(
  DiscoverFilterNotifier.new,
);

class DiscoverNotifier extends AsyncNotifier<DiscoverItems> {
  late DiscoverFilter filter;

  @override
  FutureOr<DiscoverItems> build() {
    filter = ref.watch(discoverFilterProvider);
    return switch (filter.type) {
      DiscoverType.Anime => _fetchAnime(const DiscoverAnimeItems()),
      DiscoverType.Manga => _fetchManga(const DiscoverMangaItems()),
      DiscoverType.Character =>
        _fetchCharacters(const DiscoverCharacterItems()),
      DiscoverType.Staff => _fetchStaff(const DiscoverStaffItems()),
      DiscoverType.Studio => _fetchStudios(const DiscoverStudioItems()),
      DiscoverType.User => _fetchUsers(const DiscoverUserItems()),
      DiscoverType.Review => _fetchReviews(const DiscoverReviewItems()),
    };
  }

  Future<void> fetch() async {
    final oldValue = state.valueOrNull;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => switch (filter.type) {
          DiscoverType.Anime => _fetchAnime(
              (oldValue is DiscoverAnimeItems)
                  ? oldValue
                  : const DiscoverAnimeItems(),
            ),
          DiscoverType.Manga => _fetchManga(
              (oldValue is DiscoverMangaItems)
                  ? oldValue
                  : const DiscoverMangaItems(),
            ),
          DiscoverType.Character => _fetchCharacters(
              (oldValue is DiscoverCharacterItems)
                  ? oldValue
                  : const DiscoverCharacterItems(),
            ),
          DiscoverType.Staff => _fetchStaff(
              (oldValue is DiscoverStaffItems)
                  ? oldValue
                  : const DiscoverStaffItems(),
            ),
          DiscoverType.Studio => _fetchStudios(
              (oldValue is DiscoverStudioItems)
                  ? oldValue
                  : const DiscoverStudioItems(),
            ),
          DiscoverType.User => _fetchUsers(
              (oldValue is DiscoverUserItems)
                  ? oldValue
                  : const DiscoverUserItems(),
            ),
          DiscoverType.Review => _fetchReviews(
              (oldValue is DiscoverReviewItems)
                  ? oldValue
                  : const DiscoverReviewItems(),
            ),
        });
  }

  Future<DiscoverItems> _fetchAnime(DiscoverAnimeItems oldValue) async {
    final data = await Api.get(GqlQuery.mediaPage, {
      'page': oldValue.pages.next,
      'type': 'ANIME',
      if (filter.search.isNotEmpty) ...{
        'search': filter.search,
        ...filter.mediaFilter.toMap(true)..['sort'] = 'SEARCH_MATCH',
      } else
        ...filter.mediaFilter.toMap(true),
    });

    final items = <DiscoverMediaItem>[];
    for (final m in data['Page']['media']) {
      items.add(DiscoverMediaItem(m));
    }

    return DiscoverAnimeItems(oldValue.pages.withNext(
      items,
      data['Page']['pageInfo']['hasNextPage'] ?? false,
    ));
  }

  Future<DiscoverItems> _fetchManga(DiscoverMangaItems oldValue) async {
    final data = await Api.get(GqlQuery.mediaPage, {
      'page': oldValue.pages.next,
      'type': 'MANGA',
      if (filter.search.isNotEmpty) ...{
        'search': filter.search,
        ...filter.mediaFilter.toMap(false)..['sort'] = 'SEARCH_MATCH',
      } else
        ...filter.mediaFilter.toMap(false),
    });

    final items = <DiscoverMediaItem>[];
    for (final m in data['Page']['media']) {
      items.add(DiscoverMediaItem(m));
    }

    return DiscoverMangaItems(oldValue.pages.withNext(
      items,
      data['Page']['pageInfo']['hasNextPage'] ?? false,
    ));
  }

  Future<DiscoverItems> _fetchCharacters(
      DiscoverCharacterItems oldValue) async {
    final data = await Api.get(GqlQuery.characterPage, {
      'page': oldValue.pages.next,
      if (filter.search.isNotEmpty) 'search': filter.search,
      if (filter.hasBirthday) 'isBirthday': true,
    });

    final items = <TileItem>[];
    for (final c in data['Page']['characters']) {
      items.add(characterItem(c));
    }

    return DiscoverCharacterItems(oldValue.pages.withNext(
      items,
      data['Page']['pageInfo']['hasNextPage'] ?? false,
    ));
  }

  Future<DiscoverItems> _fetchStaff(DiscoverStaffItems oldValue) async {
    final data = await Api.get(GqlQuery.staffPage, {
      'page': oldValue.pages.next,
      if (filter.search.isNotEmpty) 'search': filter.search,
      if (filter.hasBirthday) 'isBirthday': true,
    });

    final items = <TileItem>[];
    for (final s in data['Page']['staff']) {
      items.add(staffItem(s));
    }

    return DiscoverStaffItems(oldValue.pages.withNext(
      items,
      data['Page']['pageInfo']['hasNextPage'] ?? false,
    ));
  }

  Future<DiscoverItems> _fetchStudios(DiscoverStudioItems oldValue) async {
    final data = await Api.get(GqlQuery.studioPage, {
      'page': oldValue.pages.next,
      if (filter.search.isNotEmpty) 'search': filter.search,
    });

    final items = <StudioItem>[];
    for (final s in data['Page']['studios']) {
      items.add(StudioItem(s));
    }

    return DiscoverStudioItems(oldValue.pages.withNext(
      items,
      data['Page']['pageInfo']['hasNextPage'] ?? false,
    ));
  }

  Future<DiscoverItems> _fetchUsers(DiscoverUserItems oldValue) async {
    final data = await Api.get(GqlQuery.userPage, {
      'page': oldValue.pages.next,
      if (filter.search.isNotEmpty) 'search': filter.search,
    });

    final items = <UserItem>[];
    for (final u in data['Page']['users']) {
      items.add(UserItem(u));
    }

    return DiscoverUserItems(oldValue.pages.withNext(
      items,
      data['Page']['pageInfo']['hasNextPage'] ?? false,
    ));
  }

  Future<DiscoverItems> _fetchReviews(DiscoverReviewItems oldValue) async {
    final data = await Api.get(GqlQuery.reviewPage, {
      'page': oldValue.pages.next,
      'sort': filter.reviewSort.name,
    });

    final items = <ReviewItem>[];
    for (final r in data['Page']['reviews']) {
      items.add(ReviewItem(r));
    }

    return DiscoverReviewItems(oldValue.pages.withNext(
      items,
      data['Page']['pageInfo']['hasNextPage'] ?? false,
    ));
  }
}

class DiscoverFilterNotifier extends Notifier<DiscoverFilter> {
  @override
  DiscoverFilter build() => DiscoverFilter(Options().defaultDiscoverType);

  @override
  DiscoverFilter get state => super.state;

  @override
  set state(DiscoverFilter newState) => super.state = state;

  DiscoverFilter update(DiscoverFilter Function(DiscoverFilter) callback) =>
      super.state = callback(state);
}
