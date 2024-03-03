import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/models/paged.dart';
import 'package:otraku/common/utils/api.dart';
import 'package:otraku/common/utils/graphql.dart';
import 'package:otraku/modules/review/review_models.dart';

final reviewsProvider = AsyncNotifierProvider.autoDispose
    .family<ReviewsNotifier, PagedWithTotal<ReviewItem>, int>(
  ReviewsNotifier.new,
);

final reviewsSortProvider =
    NotifierProvider.autoDispose.family<ReviewsSortNotifier, ReviewsSort, int>(
  ReviewsSortNotifier.new,
);

class ReviewsNotifier
    extends AutoDisposeFamilyAsyncNotifier<PagedWithTotal<ReviewItem>, int> {
  late ReviewsSort sort;

  @override
  FutureOr<PagedWithTotal<ReviewItem>> build(arg) {
    sort = ref.watch(reviewsSortProvider(arg));
    return _fetch(const PagedWithTotal());
  }

  Future<void> fetch() async {
    final oldState = state.valueOrNull ?? const PagedWithTotal();
    if (!oldState.hasNext) return;
    state = await AsyncValue.guard(() => _fetch(oldState));
  }

  Future<PagedWithTotal<ReviewItem>> _fetch(
    PagedWithTotal<ReviewItem> oldState,
  ) async {
    final data = await Api.get(GqlQuery.reviewPage, {
      'userId': arg,
      'page': oldState.next,
      'sort': sort.name,
    });

    final items = <ReviewItem>[];
    for (final r in data['Page']['reviews']) {
      items.add(ReviewItem(r));
    }

    return oldState.withNext(
      items,
      data['Page']['pageInfo']['hasNextPage'] ?? false,
      data['Page']['pageInfo']['total'] ?? oldState.total,
    );
  }
}

class ReviewsSortNotifier extends AutoDisposeFamilyNotifier<ReviewsSort, int> {
  @override
  ReviewsSort build(arg) => ReviewsSort.CREATED_AT_DESC;

  @override
  ReviewsSort get state => super.state;

  @override
  set state(ReviewsSort newState) => super.state = newState;
}
