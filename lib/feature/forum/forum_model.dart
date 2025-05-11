import 'package:otraku/extension/date_time_extension.dart';

class ThreadItem {
  const ThreadItem._({
    required this.id,
    required this.title,
    required this.viewCount,
    required this.replyCount,
    required this.likeCount,
    required this.isSubscribed,
    required this.isPinned,
    required this.isLocked,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.userTimestamp,
    required this.isUserReplying,
    required this.topics,
  });

  factory ThreadItem(Map<String, dynamic> map) {
    final topics = <String>[];

    for (final c in map['categories'] ?? const []) {
      topics.add(c['name']);
    }

    for (final c in map['mediaCategories'] ?? const []) {
      topics.add(c['title']?['userPreferred'] ?? '?');
    }

    final (
      int userId,
      String userName,
      String userAvatar,
      DateTime userTimestamp,
      bool isUserReplying,
    ) = map['repliedAt'] != null
        ? (
            map['replyUser']?['id'] ?? 0,
            map['replyUser']?['name'] ?? '?',
            map['replyUser']?['avatar']?['large'] ?? '',
            DateTimeExtension.fromSecondsSinceEpoch(map['repliedAt']),
            true,
          )
        : (
            map['user']?['id'] ?? 0,
            map['user']?['name'] ?? '?',
            map['user']?['avatar']?['large'] ?? '',
            DateTimeExtension.fromSecondsSinceEpoch(map['createdAt']),
            false,
          );

    return ThreadItem._(
      id: map['id'],
      title: map['title'] ?? '?',
      viewCount: map['viewCount'] ?? 0,
      replyCount: map['replyCount'] ?? 0,
      likeCount: map['likeCount'] ?? 0,
      isSubscribed: map['isSubscribed'] ?? false,
      isPinned: map['isSticky'] ?? false,
      isLocked: map['isLocked'] ?? false,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      userTimestamp: userTimestamp,
      isUserReplying: isUserReplying,
      topics: topics,
    );
  }

  final int id;
  final String title;
  final int viewCount;
  final int replyCount;
  final int likeCount;
  final bool isSubscribed;
  final bool isPinned;
  final bool isLocked;
  final int userId;
  final String userName;
  final String userAvatar;
  final DateTime userTimestamp;
  final bool isUserReplying;
  final List<String> topics;
}
