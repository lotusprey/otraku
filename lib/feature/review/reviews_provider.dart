import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/util/paged.dart';
import 'package:otraku/feature/viewer/repository_provider.dart';
import 'package:otraku/util/graphql.dart';
import 'package:otraku/feature/review/review_models.dart';
import 'package:otraku/feature/review/reviews_filter_provider.dart';

final reviewsProvider =
    AsyncNotifierProvider.autoDispose.family<ReviewsNotifier, PagedWithTotal<ReviewItem>, int>(
  ReviewsNotifier.new,
);

class ReviewsNotifier extends AsyncNotifier<PagedWithTotal<ReviewItem>> {
  ReviewsNotifier(this.arg);

  final int arg;

  late ReviewsFilter filter;

  @override
  FutureOr<PagedWithTotal<ReviewItem>> build() {
    filter = ref.watch(reviewsFilterProvider(arg));
    return _fetch(const PagedWithTotal());
  }

  Future<void> fetch() async {
    final oldState = state.value ?? const PagedWithTotal();
    if (!oldState.hasNext) return;
    state = await AsyncValue.guard(() => _fetch(oldState));
  }

  Future<PagedWithTotal<ReviewItem>> _fetch(
    PagedWithTotal<ReviewItem> oldState,
  ) async {
    final data = await ref.read(repositoryProvider).request(
      GqlQuery.reviewPage,
      {
        'userId': arg,
        'page': oldState.next,
        'sort': filter.sort.value,
        if (filter.mediaType != null) 'mediaType': filter.mediaType!.value,
      },
    );

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
