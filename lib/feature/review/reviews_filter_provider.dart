import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/review/review_models.dart';

final reviewsFilterProvider = NotifierProvider.autoDispose
    .family<ReviewsFilterNotifier, ReviewsFilter, int>(
  ReviewsFilterNotifier.new,
);

class ReviewsFilterNotifier
    extends AutoDisposeFamilyNotifier<ReviewsFilter, int> {
  @override
  ReviewsFilter build(arg) => const ReviewsFilter();

  @override
  set state(ReviewsFilter newState) => super.state = newState;
}
