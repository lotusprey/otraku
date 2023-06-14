import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/modules/character/character_models.dart';
import 'package:otraku/common/models/tile_item.dart';
import 'package:otraku/modules/discover/discover_models.dart';
import 'package:otraku/modules/filter/filter_models.dart';
import 'package:otraku/modules/filter/filter_providers.dart';
import 'package:otraku/modules/home/home_provider.dart';
import 'package:otraku/modules/review/review_models.dart';
import 'package:otraku/modules/review/review_providers.dart';
import 'package:otraku/modules/staff/staff_models.dart';
import 'package:otraku/modules/studio/studio_models.dart';
import 'package:otraku/modules/user/user_models.dart';
import 'package:otraku/common/utils/api.dart';
import 'package:otraku/common/utils/graphql.dart';
import 'package:otraku/common/models/paged.dart';

/// Fetches another page on the discover tab, depending on the selected type.
void discoverLoadMore(WidgetRef ref) =>
    switch (ref.read(discoverFilterProvider).type) {
      DiscoverType.anime => ref.read(discoverAnimeProvider.notifier).fetch(),
      DiscoverType.manga => ref.read(discoverMangaProvider.notifier).fetch(),
      DiscoverType.character =>
        ref.read(discoverCharacterProvider.notifier).fetch(),
      DiscoverType.staff => ref.read(discoverStaffProvider.notifier).fetch(),
      DiscoverType.studio => ref.read(discoverStudioProvider.notifier).fetch(),
      DiscoverType.user => ref.read(discoverUserProvider.notifier).fetch(),
      DiscoverType.review => ref.read(discoverReviewProvider.notifier).fetch(),
    };

final _searchSelector = (String? s) => s == null || s.isEmpty ? null : s;

final discoverAnimeProvider = StateNotifierProvider.autoDispose<
    DiscoverMediaNotifier, AsyncValue<Paged<DiscoverMediaItem>>>(
  (ref) {
    final discoverFilter = ref.watch(discoverFilterProvider);
    return DiscoverMediaNotifier(
      discoverFilter.filter,
      ref.watch(searchProvider(null).select(_searchSelector)),
      discoverFilter.type == DiscoverType.anime &&
          ref.watch(homeProvider.select((s) => s.didLoadDiscover)),
    );
  },
);

final discoverMangaProvider = StateNotifierProvider.autoDispose<
    DiscoverMediaNotifier, AsyncValue<Paged<DiscoverMediaItem>>>(
  (ref) {
    final discoverFilter = ref.watch(discoverFilterProvider);
    return DiscoverMediaNotifier(
      discoverFilter.filter,
      ref.watch(searchProvider(null).select(_searchSelector)),
      discoverFilter.type == DiscoverType.manga &&
          ref.watch(homeProvider.select((s) => s.didLoadDiscover)),
    );
  },
);

final discoverCharacterProvider = StateNotifierProvider.autoDispose<
    DiscoverCharacterNotifier, AsyncValue<Paged<TileItem>>>(
  (ref) => DiscoverCharacterNotifier(
    ref.watch(searchProvider(null).select(_searchSelector)),
    ref.watch(discoverFilterProvider.select((s) => s.birthday)),
    ref.watch(homeProvider.select((s) => s.didLoadDiscover)),
  ),
);

final discoverStaffProvider = StateNotifierProvider.autoDispose<
    DiscoverStaffNotifier, AsyncValue<Paged<TileItem>>>(
  (ref) => DiscoverStaffNotifier(
    ref.watch(searchProvider(null).select(_searchSelector)),
    ref.watch(discoverFilterProvider.select((s) => s.birthday)),
    ref.watch(homeProvider.select((s) => s.didLoadDiscover)),
  ),
);

final discoverStudioProvider = StateNotifierProvider.autoDispose<
    DiscoverStudioNotifier, AsyncValue<Paged<StudioItem>>>(
  (ref) => DiscoverStudioNotifier(
    ref.watch(searchProvider(null).select(_searchSelector)),
    ref.watch(homeProvider.select((s) => s.didLoadDiscover)),
  ),
);

final discoverUserProvider = StateNotifierProvider.autoDispose<
    DiscoverUserNotifier, AsyncValue<Paged<UserItem>>>(
  (ref) => DiscoverUserNotifier(
    ref.watch(searchProvider(null).select(_searchSelector)),
    ref.watch(homeProvider.select((s) => s.didLoadDiscover)),
  ),
);

final discoverReviewProvider = StateNotifierProvider.autoDispose<
    DiscoverReviewNotifier, AsyncValue<Paged<ReviewItem>>>(
  (ref) => DiscoverReviewNotifier(
    ref.watch(reviewSortProvider(null)),
    ref.watch(homeProvider.select((s) => s.didLoadDiscover)),
  ),
);

class DiscoverMediaNotifier
    extends StateNotifier<AsyncValue<Paged<DiscoverMediaItem>>> {
  DiscoverMediaNotifier(this.filter, this.search, bool shouldLoad)
      : super(const AsyncValue.loading()) {
    if (shouldLoad) fetch();
  }

  final DiscoverMediaFilter filter;
  final String? search;

  Future<void> fetch() async {
    state = await AsyncValue.guard(() async {
      final value = state.valueOrNull ?? const Paged();

      final data = await Api.get(GqlQuery.medias, {
        'page': value.next,
        'type': filter.ofAnime ? 'ANIME' : 'MANGA',
        if (search != null && search!.isNotEmpty) ...{
          'search': search,
          ...filter.toMap()..['sort'] = 'SEARCH_MATCH',
        } else
          ...filter.toMap(),
      });

      final items = <DiscoverMediaItem>[];
      for (final m in data['Page']['media']) {
        items.add(DiscoverMediaItem(m));
      }

      return value.withNext(
        items,
        data['Page']['pageInfo']['hasNextPage'] ?? false,
      );
    });
  }
}

class DiscoverCharacterNotifier
    extends StateNotifier<AsyncValue<Paged<TileItem>>> {
  DiscoverCharacterNotifier(this.search, this.isBirthday, bool shouldLoad)
      : super(const AsyncValue.loading()) {
    if (shouldLoad) fetch();
  }

  final String? search;
  final bool isBirthday;

  Future<void> fetch() async {
    state = await AsyncValue.guard(() async {
      final value = state.valueOrNull ?? const Paged();

      final data = await Api.get(GqlQuery.characters, {
        'page': value.next,
        if (search != null && search!.isNotEmpty) 'search': search,
        if (isBirthday) 'isBirthday': true,
      });

      final items = <TileItem>[];
      for (final c in data['Page']['characters']) {
        items.add(characterItem(c));
      }

      return value.withNext(
        items,
        data['Page']['pageInfo']['hasNextPage'] ?? false,
      );
    });
  }
}

class DiscoverStaffNotifier extends StateNotifier<AsyncValue<Paged<TileItem>>> {
  DiscoverStaffNotifier(this.search, this.isBirthday, bool shouldLoad)
      : super(const AsyncValue.loading()) {
    if (shouldLoad) fetch();
  }

  final String? search;
  final bool isBirthday;

  Future<void> fetch() async {
    state = await AsyncValue.guard(() async {
      final value = state.valueOrNull ?? const Paged();

      final data = await Api.get(GqlQuery.staffs, {
        'page': value.next,
        if (search != null && search!.isNotEmpty) 'search': search,
        if (isBirthday) 'isBirthday': true,
      });

      final items = <TileItem>[];
      for (final s in data['Page']['staff']) {
        items.add(staffItem(s));
      }

      return value.withNext(
        items,
        data['Page']['pageInfo']['hasNextPage'] ?? false,
      );
    });
  }
}

class DiscoverStudioNotifier
    extends StateNotifier<AsyncValue<Paged<StudioItem>>> {
  DiscoverStudioNotifier(this.search, bool shouldLoad)
      : super(const AsyncValue.loading()) {
    if (shouldLoad) fetch();
  }

  final String? search;

  Future<void> fetch() async {
    state = await AsyncValue.guard(() async {
      final value = state.valueOrNull ?? const Paged();

      final data = await Api.get(GqlQuery.studios, {
        'page': value.next,
        if (search != null && search!.isNotEmpty) 'search': search,
      });

      final items = <StudioItem>[];
      for (final s in data['Page']['studios']) {
        items.add(StudioItem(s));
      }

      return value.withNext(
        items,
        data['Page']['pageInfo']['hasNextPage'] ?? false,
      );
    });
  }
}

class DiscoverUserNotifier extends StateNotifier<AsyncValue<Paged<UserItem>>> {
  DiscoverUserNotifier(this.search, bool shouldLoad)
      : super(const AsyncValue.loading()) {
    if (shouldLoad) fetch();
  }

  final String? search;

  Future<void> fetch() async {
    state = await AsyncValue.guard(() async {
      final value = state.valueOrNull ?? const Paged();

      final data = await Api.get(GqlQuery.users, {
        'page': value.next,
        if (search != null && search!.isNotEmpty) 'search': search,
      });

      final items = <UserItem>[];
      for (final u in data['Page']['users']) {
        items.add(UserItem(u));
      }

      return value.withNext(
        items,
        data['Page']['pageInfo']['hasNextPage'] ?? false,
      );
    });
  }
}

class DiscoverReviewNotifier
    extends StateNotifier<AsyncValue<Paged<ReviewItem>>> {
  DiscoverReviewNotifier(this.sort, bool shouldLoad)
      : super(const AsyncValue.loading()) {
    if (shouldLoad) fetch();
  }

  final ReviewSort sort;

  Future<void> fetch() async {
    state = await AsyncValue.guard(() async {
      final value = state.valueOrNull ?? const Paged();

      final data = await Api.get(GqlQuery.reviews, {
        'page': value.next,
        'sort': sort.name,
      });

      final items = <ReviewItem>[];
      for (final r in data['Page']['reviews']) {
        items.add(ReviewItem(r));
      }

      return value.withNext(
        items,
        data['Page']['pageInfo']['hasNextPage'] ?? false,
      );
    });
  }
}
