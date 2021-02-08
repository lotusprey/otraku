import 'package:flutter/foundation.dart';

class ReviewTileData {
  final int reviewId;
  final int userId;
  final String avatar;
  final String username;
  final String summary;
  final String rating;

  ReviewTileData._({
    @required this.reviewId,
    @required this.userId,
    @required this.avatar,
    @required this.username,
    @required this.summary,
    @required this.rating,
  });

  factory ReviewTileData(Map<String, dynamic> map) => ReviewTileData._(
        reviewId: map['id'],
        userId: map['user']['id'],
        username: map['user']['name'],
        summary: map['summary'],
        avatar: map['user']['avatar']['large'],
        rating: '${map['rating']}/${map['ratingAmount']}',
      );
}
