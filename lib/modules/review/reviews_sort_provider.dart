import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/modules/review/review_models.dart';

final reviewsSortProvider =
    NotifierProvider.autoDispose.family<ReviewsSortNotifier, ReviewsSort, int>(
  ReviewsSortNotifier.new,
);

class ReviewsSortNotifier extends AutoDisposeFamilyNotifier<ReviewsSort, int> {
  @override
  ReviewsSort build(arg) => ReviewsSort.CREATED_AT_DESC;

  @override
  ReviewsSort get state => super.state;

  @override
  set state(ReviewsSort newState) => super.state = newState;
}
