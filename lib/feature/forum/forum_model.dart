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
    required this.replyUserId,
    required this.replyUserName,
    required this.replyUserAvatar,
    required this.replyCreatedAt,
    required this.topics,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.createdAt,
  });

  factory ThreadItem(Map<String, dynamic> map) {
    final topics = <String>[];

    for (final c in map['categories'] ?? const []) {
      topics.add(c['name']);
    }

    for (final c in map['mediaCategories'] ?? const []) {
      topics.add(c['title']?['userPreferred'] ?? '?');
    }

    return ThreadItem._(
      id: map['id'],
      title: map['title'] ?? '?',
      viewCount: map['viewCount'] ?? 0,
      replyCount: map['replyCount'] ?? 0,
      likeCount: map['likeCount'] ?? 0,
      isSubscribed: map['isSubscribed'] ?? false,
      isPinned: map['isSticky'] ?? false,
      isLocked: map['isLocked'] ?? false,
      authorId: map['user']?['id'] ?? 0,
      authorName: map['user']?['name'] ?? '?',
      authorAvatar: map['user']?['avatar']?['large'] ?? '',
      createdAt: DateTimeExtension.fromSecondsSinceEpoch(map['createdAt']),
      replyUserId: map['replyUser']?['id'] ?? 0,
      replyUserName: map['replyUser']?['name'] ?? '?',
      replyUserAvatar: map['replyUser']?['avatar']?['large'] ?? '',
      replyCreatedAt: DateTimeExtension.fromSecondsSinceEpoch(map['repliedAt']),
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
  final int authorId;
  final String authorName;
  final String authorAvatar;
  final DateTime createdAt;
  final int replyUserId;
  final String replyUserName;
  final String replyUserAvatar;
  final DateTime replyCreatedAt;
  final List<String> topics;
}
