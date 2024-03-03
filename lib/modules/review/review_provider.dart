import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/modules/review/review_models.dart';
import 'package:otraku/common/utils/api.dart';
import 'package:otraku/common/utils/graphql.dart';

/// Rates a review and returns an error if unsuccessful.
Future<Object?> rateReview(int reviewId, bool? rating) async {
  try {
    await Api.get(GqlMutation.rateReview, {
      'id': reviewId,
      'rating': rating == null
          ? 'NO_VOTE'
          : rating
              ? 'UP_VOTE'
              : 'DOWN_VOTE',
    });
    return null;
  } catch (e) {
    return e;
  }
}

final reviewProvider = FutureProvider.autoDispose.family<Review, int>(
  (ref, arg) async {
    final data = await Api.get(GqlQuery.review, {'id': arg});
    return Review(data['Review']);
  },
);
