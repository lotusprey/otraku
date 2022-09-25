import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/character/character_models.dart';
import 'package:otraku/discover/discover_models.dart';
import 'package:otraku/filter/filter_models.dart';
import 'package:otraku/filter/filter_providers.dart';
import 'package:otraku/review/review_models.dart';
import 'package:otraku/review/review_providers.dart';
import 'package:otraku/staff/staff_models.dart';
import 'package:otraku/studio/studio_models.dart';
import 'package:otraku/user/user_models.dart';
import 'package:otraku/utils/api.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/pagination.dart';
import 'package:otraku/utils/settings.dart';

/// Fetches another page on the discover tab, depending on the selected type.
void discoverLoadMore(WidgetRef ref) {
  final type = ref.read(discoverTypeProvider);
  switch (type) {
    case DiscoverType.anime:
      ref.read(discoverAnimeProvider.notifier).fetch();
      return;
    case DiscoverType.manga:
      ref.read(discoverMangaProvider.notifier).fetch();
      return;
    case DiscoverType.character:
      ref.read(discoverCharacterProvider.notifier).fetch();
      return;
    case DiscoverType.staff:
      ref.read(discoverStaffProvider.notifier).fetch();
      return;
    case DiscoverType.studio:
      ref.read(discoverStudioProvider.notifier).fetch();
      return;
    case DiscoverType.user:
      ref.read(discoverUserProvider.notifier).fetch();
      return;
    case DiscoverType.review:
      ref.read(discoverReviewProvider.notifier).fetch();
      return;
  }
}

final discoverTypeProvider = StateProvider.autoDispose(
  (ref) => Settings().defaultDiscoverType,
);

final _searchSelector = (String? s) => s == null || s.isEmpty ? null : s;

final discoverAnimeProvider = StateNotifierProvider.autoDispose<
    DiscoverMediaNotifier, AsyncValue<Pagination<DiscoverMediaItem>>>(
  (ref) => DiscoverMediaNotifier(
    ref.watch(discoverFilterProvider(true)),
    ref.watch(searchProvider(null).select(_searchSelector)),
  ),
);

final discoverMangaProvider = StateNotifierProvider.autoDispose<
    DiscoverMediaNotifier, AsyncValue<Pagination<DiscoverMediaItem>>>(
  (ref) => DiscoverMediaNotifier(
    ref.watch(discoverFilterProvider(false)),
    ref.watch(searchProvider(null).select(_searchSelector)),
  ),
);

final discoverCharacterProvider = StateNotifierProvider.autoDispose<
    DiscoverCharacterNotifier, AsyncValue<Pagination<CharacterItem>>>(
  (ref) => DiscoverCharacterNotifier(
    ref.watch(searchProvider(null).select(_searchSelector)),
    ref.watch(birthdayFilterProvider),
  ),
);

final discoverStaffProvider = StateNotifierProvider.autoDispose<
    DiscoverStaffNotifier, AsyncValue<Pagination<StaffItem>>>(
  (ref) => DiscoverStaffNotifier(
    ref.watch(searchProvider(null).select(_searchSelector)),
    ref.watch(birthdayFilterProvider),
  ),
);

final discoverStudioProvider = StateNotifierProvider.autoDispose<
    DiscoverStudioNotifier, AsyncValue<Pagination<StudioItem>>>(
  (ref) => DiscoverStudioNotifier(
    ref.watch(searchProvider(null).select(_searchSelector)),
  ),
);

final discoverUserProvider = StateNotifierProvider.autoDispose<
    DiscoverUserNotifier, AsyncValue<Pagination<UserItem>>>(
  (ref) => DiscoverUserNotifier(
    ref.watch(searchProvider(null).select(_searchSelector)),
  ),
);

final discoverReviewProvider = StateNotifierProvider.autoDispose<
    DiscoverReviewNotifier, AsyncValue<Pagination<ReviewItem>>>(
  (ref) => DiscoverReviewNotifier(ref.watch(reviewSortProvider(null))),
);

class DiscoverMediaNotifier
    extends StateNotifier<AsyncValue<Pagination<DiscoverMediaItem>>> {
  DiscoverMediaNotifier(this.filter, this.search)
      : super(const AsyncValue.loading()) {
    fetch();
  }

  final DiscoverFilter filter;
  final String? search;

  Future<void> fetch() async {
    state = await AsyncValue.guard(() async {
      final value = state.valueOrNull ?? Pagination();

      final data = await Api.get(GqlQuery.medias, {
        'page': value.next,
        'type': filter.ofAnime ? 'ANIME' : 'MANGA',
        if (search != null && search!.isNotEmpty) 'search': search,
        ...filter.toMap(),
      });

      final items = <DiscoverMediaItem>[];
      for (final m in data['Page']['media']) {
        items.add(DiscoverMediaItem(m));
      }

      return value.append(
        items,
        data['Page']['pageInfo']['hasNextPage'] ?? false,
      );
    });
  }
}

class DiscoverCharacterNotifier
    extends StateNotifier<AsyncValue<Pagination<CharacterItem>>> {
  DiscoverCharacterNotifier(this.search, this.isBirthday)
      : super(const AsyncValue.loading()) {
    fetch();
  }

  final String? search;
  final bool isBirthday;

  Future<void> fetch() async {
    state = await AsyncValue.guard(() async {
      final value = state.valueOrNull ?? Pagination();

      final data = await Api.get(GqlQuery.characters, {
        'page': value.next,
        if (search != null && search!.isNotEmpty) 'search': search,
        if (isBirthday) 'isBirthday': true,
      });

      final items = <CharacterItem>[];
      for (final c in data['Page']['characters']) {
        items.add(CharacterItem(c));
      }

      return value.append(
        items,
        data['Page']['pageInfo']['hasNextPage'] ?? false,
      );
    });
  }
}

class DiscoverStaffNotifier
    extends StateNotifier<AsyncValue<Pagination<StaffItem>>> {
  DiscoverStaffNotifier(this.search, this.isBirthday)
      : super(const AsyncValue.loading()) {
    fetch();
  }

  final String? search;
  final bool isBirthday;

  Future<void> fetch() async {
    state = await AsyncValue.guard(() async {
      final value = state.valueOrNull ?? Pagination();

      final data = await Api.get(GqlQuery.staffs, {
        'page': value.next,
        if (search != null && search!.isNotEmpty) 'search': search,
        if (isBirthday) 'isBirthday': true,
      });

      final items = <StaffItem>[];
      for (final s in data['Page']['staff']) {
        items.add(StaffItem(s));
      }

      return value.append(
        items,
        data['Page']['pageInfo']['hasNextPage'] ?? false,
      );
    });
  }
}

class DiscoverStudioNotifier
    extends StateNotifier<AsyncValue<Pagination<StudioItem>>> {
  DiscoverStudioNotifier(this.search) : super(const AsyncValue.loading()) {
    fetch();
  }

  final String? search;

  Future<void> fetch() async {
    state = await AsyncValue.guard(() async {
      final value = state.valueOrNull ?? Pagination();

      final data = await Api.get(GqlQuery.studios, {
        'page': value.next,
        if (search != null && search!.isNotEmpty) 'search': search,
      });

      final items = <StudioItem>[];
      for (final s in data['Page']['studios']) {
        items.add(StudioItem(s));
      }

      return value.append(
        items,
        data['Page']['pageInfo']['hasNextPage'] ?? false,
      );
    });
  }
}

class DiscoverUserNotifier
    extends StateNotifier<AsyncValue<Pagination<UserItem>>> {
  DiscoverUserNotifier(this.search) : super(const AsyncValue.loading()) {
    fetch();
  }

  final String? search;

  Future<void> fetch() async {
    state = await AsyncValue.guard(() async {
      final value = state.valueOrNull ?? Pagination();

      final data = await Api.get(GqlQuery.users, {
        'page': value.next,
        if (search != null && search!.isNotEmpty) 'search': search,
      });

      final items = <UserItem>[];
      for (final u in data['Page']['users']) {
        items.add(UserItem(u));
      }

      return value.append(
        items,
        data['Page']['pageInfo']['hasNextPage'] ?? false,
      );
    });
  }
}

class DiscoverReviewNotifier
    extends StateNotifier<AsyncValue<Pagination<ReviewItem>>> {
  DiscoverReviewNotifier(this.sort) : super(const AsyncValue.loading()) {
    fetch();
  }

  final ReviewSort sort;

  Future<void> fetch() async {
    state = await AsyncValue.guard(() async {
      final value = state.valueOrNull ?? Pagination();

      final data = await Api.get(GqlQuery.reviews, {
        'page': value.next,
        'sort': sort.name,
      });

      final items = <ReviewItem>[];
      for (final r in data['Page']['reviews']) {
        items.add(ReviewItem(r));
      }

      return value.append(
        items,
        data['Page']['pageInfo']['hasNextPage'] ?? false,
      );
    });
  }
}
