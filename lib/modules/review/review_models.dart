import 'package:otraku/common/utils/convert.dart';
import 'package:otraku/common/utils/options.dart';

class ReviewItem {
  ReviewItem._({
    required this.id,
    required this.mediaTitle,
    required this.userName,
    required this.summary,
    required this.rating,
    required this.bannerUrl,
  });

  factory ReviewItem(Map<String, dynamic> map) => ReviewItem._(
        id: map['id'],
        mediaTitle: map['media']['title']['userPreferred'],
        userName: map['user']['name'],
        summary: map['summary'],
        rating: '${map['rating']}/${map['ratingAmount']}',
        bannerUrl: map['media']['bannerImage'],
      );

  final int id;
  final String mediaTitle;
  final String userName;
  final String summary;
  final String rating;
  final String? bannerUrl;
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
        mediaCover: map['media']['coverImage'][Options().imageQuality.value],
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
        viewerRating: map['userRating'] == 'UP_VOTE'
            ? true
            : map['userRating'] == 'DOWN_VOTE'
                ? false
                : null,
      );
}

enum ReviewSort {
  CREATED_AT_DESC,
  CREATED_AT,
  RATING_DESC,
  RATING;

  String get text {
    switch (this) {
      case ReviewSort.CREATED_AT:
        return 'Oldest';
      case ReviewSort.CREATED_AT_DESC:
        return 'Newest';
      case ReviewSort.RATING:
        return 'Lowest Rated';
      case ReviewSort.RATING_DESC:
        return 'Highest Rated';
    }
  }
}
