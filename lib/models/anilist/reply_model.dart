import 'package:flutter/cupertino.dart';
import 'package:otraku/helpers/fn_helper.dart';

class ReplyModel {
  final int id;
  final int userId;
  final String userName;
  final String userImage;
  final String text;
  final String createdAt;
  int _likeCount;
  bool _isLiked;

  ReplyModel._({
    @required this.id,
    @required this.userId,
    @required this.userName,
    @required this.userImage,
    @required this.text,
    @required this.createdAt,
    @required likes,
    @required liked,
  }) {
    _likeCount = likes;
    _isLiked = liked;
  }

  factory ReplyModel(final Map<String, dynamic> map) => ReplyModel._(
        id: map['id'],
        likes: map['likeCount'],
        liked: map['isLiked'],
        userId: map['user']['id'],
        userName: map['user']['name'],
        userImage: map['user']['avatar']['large'],
        text: map['text'],
        createdAt: FnHelper.millisecondsToTimeString(map['createdAt']),
      );

  int get likeCount => _likeCount;
  bool get isLiked => _isLiked;

  void toggleLike(final Map<String, dynamic> map) {
    _likeCount = map['likeCount'];
    _isLiked = map['isLiked'];
  }
}
