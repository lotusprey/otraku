import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/settings.dart';

final reviewProvider = StateNotifierProvider.autoDispose
    .family<ReviewNotifier, AsyncValue<Review>, int>(
  (ref, id) => ReviewNotifier(id),
);

class ReviewNotifier extends StateNotifier<AsyncValue<Review>> {
  ReviewNotifier(int id) : super(const AsyncValue.loading()) {
    _fetch(id);
  }

  Future<void> _fetch(int id) async {
    state = await AsyncValue.guard(() async {
      final data = await Client.get(GqlQuery.review, {'id': id});
      if (data['Review'] == null) throw StateError('Review data is empty.');
      return Review(data['Review']);
    });
  }

  /// Rate a review: [true] for "agree", [false]
  /// for "disagree" and null for "unvote".
  Future<void> rate(bool? rating) async {
    if (!state.hasValue || state.isLoading) return;
    final value = state.value!;

    state = await AsyncValue.guard(() async {
      final data = await Client.get(GqlMutation.rateReview, {
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

class Review {
  Review._({
    required this.id,
    required this.userId,
    required this.mediaId,
    required this.userName,
    required this.userAvatar,
    required this.mediaTitle,
    required this.mediaCover,
    required this.banner,
    required this.summary,
    required this.text,
    required this.createdAt,
    required this.siteUrl,
    required this.score,
    required this.rating,
    required this.totalRating,
    required this.viewerRating,
  });

  factory Review(Map<String, dynamic> map) => Review._(
        id: map['id'],
        userId: map['user']['id'],
        mediaId: map['media']['id'],
        userName: map['user']['name'] ?? '',
        userAvatar: map['user']['avatar']['large'],
        mediaTitle: map['media']['title']['userPreferred'] ?? '',
        mediaCover: map['media']['coverImage'][Settings().imageQuality],
        banner: map['media']['bannerImage'],
        summary: map['summary'] ?? '',
        text: map['body'] ?? '',
        createdAt: Convert.millisToStr(map['createdAt']),
        siteUrl: map['siteUrl'],
        score: map['score'] ?? 0,
        rating: map['rating'] ?? 0,
        totalRating: map['ratingAmount'] ?? 0,
        viewerRating: map['userRating'] == 'UP_VOTE'
            ? true
            : map['userRating'] == 'DOWN_VOTE'
                ? false
                : null,
      );

  final int id;
  final int userId;
  final int mediaId;
  final String userName;
  final String? userAvatar;
  final String mediaTitle;
  final String? mediaCover;
  final String? banner;
  final String summary;
  final String text;
  final String createdAt;
  final String siteUrl;
  final int score;
  final int rating;
  final int totalRating;
  final bool? viewerRating;

  Review copyWith(Map<String, dynamic> map) => Review._(
        id: id,
        userId: userId,
        mediaId: mediaId,
        userName: userName,
        userAvatar: userAvatar,
        mediaTitle: mediaTitle,
        mediaCover: mediaCover,
        banner: banner,
        summary: summary,
        text: text,
        createdAt: createdAt,
        siteUrl: siteUrl,
        score: score,
        rating: map['rating'] ?? rating,
        totalRating: map['ratingAmount'] ?? totalRating,
        viewerRating: map['userRating'],
      );
}
