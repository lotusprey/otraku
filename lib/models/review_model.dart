import 'package:otraku/enums/browsable.dart';
import 'package:otraku/utils/convert.dart';

class ReviewModel {
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
  final int score;
  final Browsable browsable;
  int rating;
  int totalRating;
  bool? viewerRating;

  ReviewModel._({
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
    required this.score,
    required this.rating,
    required this.totalRating,
    required this.viewerRating,
    required this.browsable,
  });

  factory ReviewModel(Map<String, dynamic> map) => ReviewModel._(
        id: map['id'],
        userId: map['user']['id'],
        mediaId: map['media']['id'],
        userName: map['user']['name'] ?? '',
        userAvatar: map['user']['avatar']['large'],
        mediaTitle: map['media']['title']['userPreferred'] ?? '',
        mediaCover: map['media']['coverImage']['large'],
        banner: map['media']['bannerImage'],
        summary: map['summary'] ?? '',
        text: map['body'] ?? '',
        createdAt: Convert.millisToTimeStr(map['createdAt']),
        score: map['score'] ?? 0,
        rating: map['rating'] ?? 0,
        totalRating: map['ratingAmount'] ?? 0,
        viewerRating: map['userRating'] == 'UP_VOTE'
            ? true
            : map['userRating'] == 'DOWN_VOTE'
                ? false
                : null,
        browsable:
            map['media']['type'] == 'ANIME' ? Browsable.anime : Browsable.manga,
      );

  void updateRating(final Map<String, dynamic> map) {
    rating = map['rating'] ?? 0;
    totalRating = map['ratingAmount'] ?? 0;
    viewerRating = map['userRating'] == 'UP_VOTE'
        ? true
        : map['userRating'] == 'DOWN_VOTE'
            ? false
            : null;
  }
}
