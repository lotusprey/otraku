import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/models/paged.dart';
import 'package:otraku/modules/viewer/api.dart';
import 'package:otraku/common/utils/graphql.dart';
import 'package:otraku/modules/review/review_models.dart';
import 'package:otraku/modules/review/reviews_sort_provider.dart';

final reviewsProvider = AsyncNotifierProvider.autoDispose
    .family<ReviewsNotifier, PagedWithTotal<ReviewItem>, int>(
  ReviewsNotifier.new,
);

class ReviewsNotifier
    extends AutoDisposeFamilyAsyncNotifier<PagedWithTotal<ReviewItem>, int> {
  late ReviewsFilter filter;

  @override
  FutureOr<PagedWithTotal<ReviewItem>> build(arg) {
    filter = ref.watch(reviewsFilterProvider(arg));
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
      'sort': filter.sort.value,
      if (filter.mediaType != null) 'mediaType': filter.mediaType!.value,
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
