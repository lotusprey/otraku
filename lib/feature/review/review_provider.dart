import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/extension/future_extension.dart';
import 'package:otraku/feature/review/review_models.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/feature/viewer/repository_provider.dart';
import 'package:otraku/util/graphql.dart';

final reviewProvider =
    AsyncNotifierProvider.autoDispose.family<ReviewNotifier, Review, int>(
  ReviewNotifier.new,
);

class ReviewNotifier extends AutoDisposeFamilyAsyncNotifier<Review, int> {
  @override
  FutureOr<Review> build(arg) async {
    final data = await ref
        .read(repositoryProvider)
        .request(GqlQuery.review, {'id': arg});

    return Review(
      data['Review'],
      ref.read(persistenceProvider).options.imageQuality,
    );
  }

  Future<Object?> rate(bool? rating) {
    return ref.read(repositoryProvider).request(
      GqlMutation.rateReview,
      {
        'id': arg,
        'rating': rating == null
            ? 'NO_VOTE'
            : rating
                ? 'UP_VOTE'
                : 'DOWN_VOTE',
      },
    ).getErrorOrNull();
  }
}
