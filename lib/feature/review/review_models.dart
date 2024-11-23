import 'package:otraku/extension/date_time_extension.dart';
import 'package:otraku/feature/viewer/persistence_model.dart';
import 'package:otraku/util/markdown.dart';
import 'package:otraku/feature/media/media_models.dart';

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

  factory Review(Map<String, dynamic> map, ImageQuality imageQuality) =>
      Review._(
        id: map['id'],
        userId: map['user']['id'],
        mediaId: map['media']['id'],
        userName: map['user']['name'] ?? '',
        userAvatar: map['user']['avatar']['large'],
        mediaTitle: map['media']['title']['userPreferred'] ?? '',
        mediaCover: map['media']['coverImage'][imageQuality.value],
        banner: map['media']['bannerImage'],
        summary: map['summary'] ?? '',
        text: parseMarkdown(map['body'] ?? ''),
        createdAt:
            DateTimeExtension.formattedDateTimeFromSeconds(map['createdAt']),
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
  int rating;
  int totalRating;
  bool? viewerRating;
}

class ReviewsFilter {
  const ReviewsFilter({this.mediaType, this.sort = ReviewsSort.createdAtDesc});

  final MediaType? mediaType;
  final ReviewsSort sort;

  ReviewsFilter copyWith({
    MediaType? Function()? mediaType,
    ReviewsSort? sort,
  }) =>
      ReviewsFilter(
        mediaType: mediaType == null ? this.mediaType : mediaType(),
        sort: sort ?? this.sort,
      );
}

enum ReviewsSort {
  createdAtDesc('Newest', 'CREATED_AT_DESC'),
  createdAt('Oldest', 'CREATED_AT'),
  ratingDesc('Highest Rated', 'RATING_DESC'),
  rating('Lowest Rated', 'RATING');

  const ReviewsSort(this.label, this.value);

  final String label;
  final String value;
}
