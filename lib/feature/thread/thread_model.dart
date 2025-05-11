import 'package:otraku/extension/date_time_extension.dart';
import 'package:otraku/feature/comment/comment_model.dart';
import 'package:otraku/feature/viewer/persistence_model.dart';
import 'package:otraku/util/markdown.dart';

class Thread {
  const Thread._({
    required this.info,
    required this.comments,
    required this.commentPage,
    required this.totalCommentPages,
  });

  factory Thread(Map<String, dynamic> map, ImageQuality imageQuality) =>
      Thread._withInfo(ThreadInfo(map['Thread'], imageQuality), map);

  factory Thread._withInfo(ThreadInfo info, Map<String, dynamic> map) {
    final comments = <Comment>[];
    for (final c in map['Page']?['threadComments'] ?? const []) {
      comments.add(Comment(c));
    }

    return Thread._(
      info: info,
      comments: comments,
      commentPage: map['Page']?['pageInfo']?['currentPage'] ?? 1,
      totalCommentPages: map['Page']?['pageInfo']?['lastPage'] ?? 1,
    );
  }

  final ThreadInfo info;
  final List<Comment> comments;
  final int commentPage;
  final int totalCommentPages;

  Thread withChangingCommentPage(int commentPage) => Thread._(
        info: info,
        comments: comments,
        commentPage: commentPage,
        totalCommentPages: totalCommentPages,
      );

  Thread withChangedCommentPage(Map<String, dynamic> map) =>
      Thread._withInfo(info, map);

  Thread withAppendedComment(Map<String, dynamic> map, int? parentCommentId) {
    if (parentCommentId == null) {
      return Thread._(
        info: info,
        commentPage: commentPage,
        totalCommentPages: totalCommentPages,
        comments: [...comments, Comment(map)],
      );
    }

    for (final comment in comments) {
      if (comment.append(map, parentCommentId)) {
        return Thread._(
          info: info,
          commentPage: commentPage,
          totalCommentPages: totalCommentPages,
          comments: [...comments],
        );
      }
    }

    return this;
  }
}

class ThreadInfo {
  ThreadInfo._({
    required this.id,
    required this.title,
    required this.body,
    required this.viewCount,
    required this.replyCount,
    required this.likeCount,
    required this.isLiked,
    required this.isSubscribed,
    required this.isPinned,
    required this.isLocked,
    required this.siteUrl,
    required this.createdAt,
    required this.categories,
    required this.media,
    required this.userId,
    required this.userName,
    required this.userAvatarUrl,
  });

  factory ThreadInfo(Map<String, dynamic> map, ImageQuality imageQuality) {
    final categories = <String>[];
    for (final c in map['categories'] ?? const []) {
      categories.add(c['name']);
    }

    final media = <ThreadMedia>[];
    for (final m in map['mediaCategories'] ?? const []) {
      media.add((
        id: m['id'] ?? 0,
        title: m['title']?['userPreferred'] ?? '',
        coverUrl: m['coverImage']?[imageQuality.value] ?? '',
      ));
    }

    return ThreadInfo._(
      id: map['id'],
      title: map['title'] ?? '?',
      body: parseMarkdown(map['body'] ?? ''),
      viewCount: map['viewCount'] ?? 0,
      replyCount: map['replyCount'] ?? 0,
      likeCount: map['likeCount'] ?? 0,
      isLiked: map['isLiked'] ?? false,
      isLocked: map['isLocked'] ?? false,
      isSubscribed: map['isSubscribed'] ?? false,
      isPinned: map['isSticky'] ?? false,
      siteUrl: map['siteUrl'] ?? '',
      createdAt: DateTimeExtension.fromSecondsSinceEpoch(map['createdAt']),
      categories: categories,
      media: media,
      userId: map['user']?['id'] ?? 0,
      userName: map['user']?['name'] ?? '?',
      userAvatarUrl: map['user']?['avatar']?['large'] ?? '',
    );
  }

  final int id;
  final String title;
  final String body;
  final int viewCount;
  int likeCount;
  final int replyCount;
  bool isLiked;
  bool isSubscribed;
  final bool isPinned;
  final bool isLocked;
  final String siteUrl;
  final DateTime createdAt;
  final List<String> categories;
  final List<ThreadMedia> media;
  final int userId;
  final String userName;
  final String userAvatarUrl;
}

typedef ThreadMedia = ({int id, String title, String coverUrl});
