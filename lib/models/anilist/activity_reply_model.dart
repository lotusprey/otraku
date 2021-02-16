import 'package:flutter/cupertino.dart';
import 'package:otraku/helpers/fn_helper.dart';

class ActivityReplyModel {
  final int id;
  final int likeCount;
  final bool isLiked;
  final int userId;
  final String userName;
  final String userImage;
  final String text;
  final String createdAt;

  ActivityReplyModel._({
    @required this.id,
    @required this.likeCount,
    @required this.isLiked,
    @required this.userId,
    @required this.userName,
    @required this.userImage,
    @required this.text,
    @required this.createdAt,
  });

  factory ActivityReplyModel(final Map<String, dynamic> map) =>
      ActivityReplyModel._(
        id: map['id'],
        likeCount: map['likeCount'],
        isLiked: map['isLiked'],
        userId: map['user']['id'],
        userName: map['user']['name'],
        userImage: map['user']['avatar']['large'],
        text: map['text'],
        createdAt: FnHelper.millisecondsToTimeString(map['createdAt']),
      );
}
