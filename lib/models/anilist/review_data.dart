import 'package:flutter/foundation.dart';
import 'package:otraku/helpers/model_helper.dart';

class ReviewData {
  final int id;
  final int userId;
  final int mediaId;
  final String userName;
  final String mediaTitle;
  final String mediaType;
  final String banner;
  final String summary;
  final String text;
  final int score;
  final int rating;
  final int totalRating;
  final bool viewerRating;

  ReviewData._({
    @required this.id,
    @required this.userId,
    @required this.mediaId,
    @required this.userName,
    @required this.mediaTitle,
    @required this.mediaType,
    @required this.banner,
    @required this.summary,
    @required this.text,
    @required this.score,
    @required this.rating,
    @required this.totalRating,
    @required this.viewerRating,
  });

  factory ReviewData(Map<String, dynamic> map) => ReviewData._(
        id: map['id'],
        userId: map['user']['id'],
        mediaId: map['media']['id'],
        userName: map['user']['name'],
        mediaTitle: map['media']['title']['userPreferred'],
        mediaType: map['media']['type'],
        banner: map['media']['bannerImage'],
        summary: map['summary'],
        text: ModelHelper.clearHtml(map['body']),
        score: map['score'],
        rating: map['rating'],
        totalRating: map['ratingAmount'],
        viewerRating: map['userRating'] == 'UP_VOTE'
            ? true
            : map['userRating'] == 'DOWN_VOTE'
                ? false
                : null,
      );
}
