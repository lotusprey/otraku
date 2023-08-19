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
import 'package:otraku/common/models/paged.dart';

final discoverFilterProvider = StateProvider.autoDispose(
  (ref) => DiscoverFilter(Options().defaultDiscoverType),
);

final discoverProvider = StateNotifierProvider.autoDispose<DiscoverNotifier,
    AsyncValue<DiscoverItems>>(
  (ref) => DiscoverNotifier(ref.watch(discoverFilterProvider)),
);

class DiscoverNotifier extends StateNotifier<AsyncValue<DiscoverItems>> {
  DiscoverNotifier(this.filter) : super(const AsyncValue.loading()) {
    fetch();
  }

  final DiscoverFilter filter;

  Future<void> fetch() async =>
      state = await AsyncValue.guard(() => switch (filter.type) {
            DiscoverType.anime => _fetchAnime(),
            DiscoverType.manga => _fetchManga(),
            DiscoverType.character => _fetchCharacters(),
            DiscoverType.staff => _fetchStaff(),
            DiscoverType.studio => _fetchStudios(),
            DiscoverType.user => _fetchUsers(),
            DiscoverType.review => _fetchReviews(),
          });

  Future<DiscoverItems> _fetchAnime() async {
    final value = (state.valueOrNull is DiscoverAnimeItems)
        ? (state.valueOrNull as DiscoverAnimeItems).pages
        : const Paged<DiscoverMediaItem>();

    final data = await Api.get(GqlQuery.medias, {
      'page': value.next,
      'type': 'ANIME',
      if (filter.search != null && filter.search!.isNotEmpty) ...{
        'search': filter.search,
        ...filter.mediaFilter.toMap(true)..['sort'] = 'SEARCH_MATCH',
      } else
        ...filter.mediaFilter.toMap(true),
    });

    final items = <DiscoverMediaItem>[];
    for (final m in data['Page']['media']) {
      items.add(DiscoverMediaItem(m));
    }

    return DiscoverAnimeItems(value.withNext(
      items,
      data['Page']['pageInfo']['hasNextPage'] ?? false,
    ));
  }

  Future<DiscoverItems> _fetchManga() async {
    final value = (state.valueOrNull is DiscoverMangaItems)
        ? (state.valueOrNull as DiscoverMangaItems).pages
        : const Paged<DiscoverMediaItem>();

    final data = await Api.get(GqlQuery.medias, {
      'page': value.next,
      'type': 'MANGA',
      if (filter.search != null && filter.search!.isNotEmpty) ...{
        'search': filter.search,
        ...filter.mediaFilter.toMap(false)..['sort'] = 'SEARCH_MATCH',
      } else
        ...filter.mediaFilter.toMap(false),
    });

    final items = <DiscoverMediaItem>[];
    for (final m in data['Page']['media']) {
      items.add(DiscoverMediaItem(m));
    }

    return DiscoverMangaItems(value.withNext(
      items,
      data['Page']['pageInfo']['hasNextPage'] ?? false,
    ));
  }

  Future<DiscoverItems> _fetchCharacters() async {
    final value = (state.valueOrNull is DiscoverCharacterItems)
        ? (state.valueOrNull as DiscoverCharacterItems).pages
        : const Paged<TileItem>();

    final data = await Api.get(GqlQuery.characters, {
      'page': value.next,
      if (filter.search != null && filter.search!.isNotEmpty)
        'search': filter.search,
      if (filter.hasBirthday) 'isBirthday': true,
    });

    final items = <TileItem>[];
    for (final c in data['Page']['characters']) {
      items.add(characterItem(c));
    }

    return DiscoverCharacterItems(value.withNext(
      items,
      data['Page']['pageInfo']['hasNextPage'] ?? false,
    ));
  }

  Future<DiscoverItems> _fetchStaff() async {
    final value = (state.valueOrNull is DiscoverStaffItems)
        ? (state.valueOrNull as DiscoverStaffItems).pages
        : const Paged<TileItem>();

    final data = await Api.get(GqlQuery.staffs, {
      'page': value.next,
      if (filter.search != null && filter.search!.isNotEmpty)
        'search': filter.search,
      if (filter.hasBirthday) 'isBirthday': true,
    });

    final items = <TileItem>[];
    for (final s in data['Page']['staff']) {
      items.add(staffItem(s));
    }

    return DiscoverStaffItems(value.withNext(
      items,
      data['Page']['pageInfo']['hasNextPage'] ?? false,
    ));
  }

  Future<DiscoverItems> _fetchStudios() async {
    final value = (state.valueOrNull is DiscoverStudioItems)
        ? (state.valueOrNull as DiscoverStudioItems).pages
        : const Paged<StudioItem>();

    final data = await Api.get(GqlQuery.studios, {
      'page': value.next,
      if (filter.search != null && filter.search!.isNotEmpty)
        'search': filter.search,
    });

    final items = <StudioItem>[];
    for (final s in data['Page']['studios']) {
      items.add(StudioItem(s));
    }

    return DiscoverStudioItems(value.withNext(
      items,
      data['Page']['pageInfo']['hasNextPage'] ?? false,
    ));
  }

  Future<DiscoverItems> _fetchUsers() async {
    final value = (state.valueOrNull is DiscoverUserItems)
        ? (state.valueOrNull as DiscoverUserItems).pages
        : const Paged<UserItem>();

    final data = await Api.get(GqlQuery.users, {
      'page': value.next,
      if (filter.search != null && filter.search!.isNotEmpty)
        'search': filter.search,
    });

    final items = <UserItem>[];
    for (final u in data['Page']['users']) {
      items.add(UserItem(u));
    }

    return DiscoverUserItems(value.withNext(
      items,
      data['Page']['pageInfo']['hasNextPage'] ?? false,
    ));
  }

  Future<DiscoverItems> _fetchReviews() async {
    final value = (state.valueOrNull is DiscoverReviewItems)
        ? (state.valueOrNull as DiscoverReviewItems).pages
        : const Paged<ReviewItem>();

    final data = await Api.get(GqlQuery.reviews, {
      'page': value.next,
      'sort': filter.reviewSort.name,
    });

    final items = <ReviewItem>[];
    for (final r in data['Page']['reviews']) {
      items.add(ReviewItem(r));
    }

    return DiscoverReviewItems(value.withNext(
      items,
      data['Page']['pageInfo']['hasNextPage'] ?? false,
    ));
  }
}
