import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/review/review_models.dart';
import 'package:otraku/utils/api.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/common/pagination.dart';

final reviewProvider = StateNotifierProvider.autoDispose
    .family<ReviewNotifier, AsyncValue<Review>, int>(
  (ref, id) => ReviewNotifier(id),
);

final reviewSortProvider = StateProvider.autoDispose.family<ReviewSort, int?>(
  (ref, _) => ReviewSort.CREATED_AT_DESC,
);

final reviewsProvider = StateNotifierProvider.autoDispose
    .family<ReviewsNotifier, AsyncValue<Pagination<ReviewItem>>, int>(
  (ref, userId) =>
      ReviewsNotifier(userId, ref.watch(reviewSortProvider(userId))),
);

class ReviewNotifier extends StateNotifier<AsyncValue<Review>> {
  ReviewNotifier(int id) : super(const AsyncValue.loading()) {
    _fetch(id);
  }

  Future<void> _fetch(int id) async {
    state = await AsyncValue.guard(() async {
      final data = await Api.get(GqlQuery.review, {'id': id});
      if (data['Review'] == null) throw StateError('Review data is empty.');
      return Review(data['Review']);
    });
  }

  /// Rate a review: `true` for "agree", `false`
  /// for "disagree" and null for "unvote".
  Future<void> rate(bool? rating) async {
    if (!state.hasValue || state.isLoading) return;
    final value = state.value!;

    state = await AsyncValue.guard(() async {
      final data = await Api.get(GqlMutation.rateReview, {
        'id': value.id,
        'rating': rating == null
            ? 'NO_VOTE'
            : rating
                ? 'UP_VOTE'
                : 'DOWN_VOTE',
      });
      if (data['RateReview'] == null) throw StateError('Review data is empty.');
      return value.copyWith(data['RateReview']);
    });
  }
}

class ReviewsNotifier
    extends StateNotifier<AsyncValue<Pagination<ReviewItem>>> {
  ReviewsNotifier(this.userId, this.sort) : super(const AsyncValue.loading()) {
    fetch();
  }

  final int userId;
  final ReviewSort sort;

  int _reviewCount = 0;
  int get reviewCount => _reviewCount;

  Future<void> fetch() async {
    state = await AsyncValue.guard(() async {
      final value = state.valueOrNull ?? Pagination();

      final data = await Api.get(GqlQuery.reviews, {
        'userId': userId,
        'page': value.next,
        'sort': sort.name,
      });

      final items = <ReviewItem>[];
      for (final r in data['Page']['reviews']) {
        items.add(ReviewItem(r));
      }

      _reviewCount = data['Page']['pageInfo']?['total'] ?? 0;

      return value.append(
        items,
        data['Page']['pageInfo']['hasNextPage'] ?? false,
      );
    });
  }
}
