import 'package:otraku/extension/date_time_extension.dart';
import 'package:otraku/util/markdown.dart';

class Comment {
  Comment._({
    required this.id,
    required this.text,
    required this.likeCount,
    required this.isLiked,
    required this.isLocked,
    required this.createdAt,
    required this.siteUrl,
    required this.userId,
    required this.userName,
    required this.userAvatarUrl,
    required this.threadId,
    required this.threadTitle,
    required this.childComments,
  });

  factory Comment(Map<String, dynamic> map) {
    final childComments = <Comment>[];
    for (final c in map['childComments'] ?? const []) {
      childComments.add(Comment(c));
    }

    return Comment._(
      id: map['id'],
      text: parseMarkdown(map['comment'] ?? ''),
      likeCount: map['likeCount'] ?? 0,
      isLiked: map['isLiked'] ?? false,
      isLocked: map['isLocked'] ?? false,
      createdAt: DateTimeExtension.fromSecondsSinceEpoch(map['createdAt']),
      siteUrl: map['siteUrl'] ?? '',
      userId: map['user']?['id'] ?? 0,
      userName: map['user']?['name'] ?? '?',
      userAvatarUrl: map['user']?['avatar']?['large'] ?? '',
      threadId: map['thread']?['id'] ?? 0,
      threadTitle: map['thread']?['title'] ?? '',
      childComments: childComments,
    );
  }

  final int id;
  final String text;
  int likeCount;
  bool isLiked;
  final bool isLocked;
  final DateTime createdAt;
  final String siteUrl;
  final int userId;
  final String userName;
  final String userAvatarUrl;
  final int threadId;
  final String threadTitle;
  final List<Comment> childComments;

  Comment _copyWith({String? text, List<Comment>? childComments}) => Comment._(
        id: id,
        text: text ?? this.text,
        likeCount: likeCount,
        isLiked: isLiked,
        isLocked: isLocked,
        createdAt: createdAt,
        siteUrl: siteUrl,
        userId: userId,
        userName: userName,
        userAvatarUrl: userAvatarUrl,
        threadId: threadId,
        threadTitle: threadTitle,
        childComments: childComments ?? this.childComments,
      );

  Comment withEditedText(String text) => _copyWith(text: text);

  Comment withAppendedChildComment(
    Map<String, dynamic> map,
    int parentCommentId,
  ) {
    if (id == parentCommentId) {
      return _copyWith(childComments: [...childComments, Comment(map)]);
    }

    for (final comment in childComments) {
      if (comment.append(map, parentCommentId)) {
        return _copyWith(childComments: [...childComments]);
      }
    }

    return this;
  }

  bool append(Map<String, dynamic> map, int parentCommentId) {
    for (final comment in childComments) {
      if (comment.id == parentCommentId) {
        comment.childComments.add(Comment(map));
        return true;
      }

      if (comment.append(map, parentCommentId)) {
        return true;
      }
    }

    return false;
  }
}
