import 'package:flutter/foundation.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/helpers/fn_helper.dart';

class ReviewData {
  final int id;
  final int userId;
  final int mediaId;
  final String userName;
  final String userAvatar;
  final String mediaTitle;
  final String mediaCover;
  final String banner;
  final String summary;
  final String text;
  final String createdAt;
  final int score;
  final int rating;
  final int totalRating;
  final bool viewerRating;
  final Browsable browsable;

  ReviewData._({
    @required this.id,
    @required this.userId,
    @required this.mediaId,
    @required this.userName,
    @required this.userAvatar,
    @required this.mediaTitle,
    @required this.mediaCover,
    @required this.banner,
    @required this.summary,
    @required this.text,
    @required this.createdAt,
    @required this.score,
    @required this.rating,
    @required this.totalRating,
    @required this.viewerRating,
    @required this.browsable,
  });

  factory ReviewData(Map<String, dynamic> map) => ReviewData._(
        id: map['id'],
        userId: map['user']['id'],
        mediaId: map['media']['id'],
        userName: map['user']['name'],
        userAvatar: map['user']['avatar']['large'],
        mediaTitle: map['media']['title']['userPreferred'],
        mediaCover: map['media']['coverImage']['large'],
        banner: map['media']['bannerImage'],
        summary: map['summary'],
        text: FnHelper.clearHtml(map['body']),
        createdAt: FnHelper.millisecondsToDateString(map['createdAt']),
        score: map['score'],
        rating: map['rating'],
        totalRating: map['ratingAmount'],
        viewerRating: map['userRating'] == 'UP_VOTE'
            ? true
            : map['userRating'] == 'DOWN_VOTE'
                ? false
                : null,
        browsable:
            map['media']['type'] == 'ANIME' ? Browsable.anime : Browsable.manga,
      );
}
