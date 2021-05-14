import 'package:otraku/utils/convert.dart';

class ReplyModel {
  final int id;
  final int userId;
  final String userName;
  final String? userImage;
  final String text;
  final String createdAt;
  int likeCount;
  bool isLiked;

  ReplyModel._({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.text,
    required this.createdAt,
    this.likeCount = 0,
    this.isLiked = false,
  });

  factory ReplyModel(final Map<String, dynamic> map) {
    if (map['id'] == null || map['user']?['id'] == null)
      throw ArgumentError.notNull('id/userId');

    return ReplyModel._(
      id: map['id'],
      likeCount: map['likeCount'] ?? 0,
      isLiked: map['isLiked'] ?? false,
      userId: map['user']['id'],
      userName: map['user']['name'] ?? '',
      userImage: map['user']['avatar']['large'],
      text: map['text'] ?? '',
      createdAt: Convert.millisToTimeStr(map['createdAt']),
    );
  }

  void toggleLike() {
    if (isLiked) {
      isLiked = false;
      likeCount--;
    } else {
      isLiked = true;
      likeCount++;
    }
  }
}
