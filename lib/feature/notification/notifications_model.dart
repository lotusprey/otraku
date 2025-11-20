import 'package:otraku/extension/date_time_extension.dart';
import 'package:otraku/extension/iterable_extension.dart';
import 'package:otraku/feature/viewer/persistence_model.dart';

enum NotificationType {
  following('Follows', 'FOLLOWING'),
  activityMention('Activity mentions', 'ACTIVITY_MENTION'),
  activityMessage('Messages', 'ACTIVITY_MESSAGE'),
  activityLike('Activity likes', 'ACTIVITY_LIKE'),
  activityReply('Activity replies', 'ACTIVITY_REPLY'),
  acrivityReplyLike('Activity reply likes', 'ACTIVITY_REPLY_LIKE'),
  activityReplySubscribed('Subscribed activity replies', 'ACTIVITY_REPLY_SUBSCRIBED'),
  threadLike('Thread likes', 'THREAD_LIKE'),
  threadReplySubscribed('Subscribed thread replies', 'THREAD_SUBSCRIBED'),
  threadCommentMention('Thread mentions', 'THREAD_COMMENT_MENTION'),
  threadCommentReply('Thread comments', 'THREAD_COMMENT_REPLY'),
  threadCommentLike('Thread comment likes', 'THREAD_COMMENT_LIKE'),
  airing('Episode releases', 'AIRING'),
  relatedMediaAddition('Related media additions', 'RELATED_MEDIA_ADDITION'),
  mediaDataChange('Media changes', 'MEDIA_DATA_CHANGE'),
  mediaMerge('Media merges', 'MEDIA_MERGE'),
  mediaDeletion('Media deletions', 'MEDIA_DELETION');

  const NotificationType(this.label, this.value);

  final String label;
  final String value;

  static NotificationType? from(String? value) =>
      NotificationType.values.firstWhereOrNull((v) => v.value == value);
}

sealed class SiteNotification {
  SiteNotification({
    required Map<String, dynamic> map,
    required this.type,
    required this.imageUrl,
    required this.texts,
  }) : id = map['id'],
       createdAt = DateTimeExtension.fromSecondsSinceEpoch(map['createdAt'] ?? 0);

  static SiteNotification? maybe(Map<String, dynamic> map, ImageQuality imageQuality) {
    final type = NotificationType.from(map['type']);

    return switch (type) {
      null => null,
      .following => FollowNotification(map, type),
      .activityMention ||
      .activityMessage ||
      .activityLike ||
      .activityReply ||
      .acrivityReplyLike ||
      .activityReplySubscribed => ActivityNotification(map, type),
      .threadLike => ThreadNotification(map, type),
      .threadReplySubscribed ||
      .threadCommentMention ||
      .threadCommentReply ||
      .threadCommentLike => ThreadCommentNotification(map, type),
      .airing || .relatedMediaAddition => MediaReleaseNotification(map, type, imageQuality),
      .mediaDataChange || .mediaMerge => MediaChangeNotification(map, type, imageQuality),
      .mediaDeletion => MediaDeletionNotification(map, type),
    };
  }

  final int id;
  final NotificationType type;
  final DateTime createdAt;
  final String? imageUrl;
  final List<String> texts;
}

class FollowNotification extends SiteNotification {
  FollowNotification._({
    required super.map,
    required super.type,
    required super.imageUrl,
    required super.texts,
    required this.userId,
  });

  factory FollowNotification(Map<String, dynamic> map, NotificationType type) =>
      FollowNotification._(
        map: map,
        type: type,
        imageUrl: map['user']?['avatar']?['large'],
        texts: [map['user']?['name'] ?? '?', ' followed you'],
        userId: map['user']?['id'] ?? 0,
      );

  final int userId;
}

class ActivityNotification extends SiteNotification {
  ActivityNotification._({
    required super.map,
    required super.type,
    required super.imageUrl,
    required super.texts,
    required this.userId,
    required this.activityId,
  });

  factory ActivityNotification(Map<String, dynamic> map, NotificationType type) {
    final List<String> texts = switch (type) {
      .activityMention => [map['user']?['name'] ?? '?', ' mentioned you in an activity'],
      .activityMessage => [map['user']?['name'] ?? '?', ' sent you a message'],
      .activityLike => [map['user']?['name'] ?? '?', ' liked your activity'],
      .activityReply => [map['user']?['name'] ?? '?', ' replied to your activity'],
      .acrivityReplyLike => [map['user']?['name'] ?? '?', ' liked your reply'],
      .activityReplySubscribed => [
        map['user']?['name'] ?? '?',
        ' replied to a subscribed activity',
      ],
      _ => const [],
    };

    return ActivityNotification._(
      map: map,
      type: type,
      imageUrl: map['user']?['avatar']?['large'],
      texts: texts,
      userId: map['user']?['id'] ?? 0,
      activityId: map['activityId'] ?? 0,
    );
  }

  final int userId;
  final int activityId;
}

class ThreadNotification extends SiteNotification {
  ThreadNotification._({
    required super.map,
    required super.type,
    required super.imageUrl,
    required super.texts,
    required this.userId,
    required this.threadId,
    required this.threadSiteUrl,
  });

  factory ThreadNotification(Map<String, dynamic> map, NotificationType type) =>
      ThreadNotification._(
        map: map,
        type: type,
        imageUrl: map['user']?['avatar']?['large'],
        texts: [map['user']?['name'] ?? '?', ' liked your thread ', map['thread']?['title'] ?? ''],
        userId: map['user']?['id'] ?? 0,
        threadId: map['thread']?['id'] ?? 0,
        threadSiteUrl: map['thread']?['siteUrl'],
      );

  final int userId;
  final int threadId;
  final String? threadSiteUrl;
}

class ThreadCommentNotification extends SiteNotification {
  ThreadCommentNotification._({
    required super.map,
    required super.type,
    required super.imageUrl,
    required super.texts,
    required this.userId,
    required this.commentId,
    required this.commentSiteUrl,
  });

  factory ThreadCommentNotification(Map<String, dynamic> map, NotificationType type) {
    final List<String> texts = switch (type) {
      .threadReplySubscribed => [
        map['user']?['name'] ?? '?',
        if (map['thread']?['title'] != null) ...[
          ' commented in ',
          map['thread']['title'],
        ] else
          ' commented in a subscribed thread',
      ],
      .threadCommentMention => [
        map['user']?['name'] ?? '?',
        if (map['thread']?['title'] != null) ...[
          ' mentioned you in ',
          map['thread']['title'],
        ] else
          ' mentioned you in a subscribed thread',
      ],
      .threadCommentReply => [
        map['user']?['name'] ?? '?',
        if (map['thread']?['title'] != null) ...[
          ' replied to your comment in ',
          map['thread']['title'],
        ] else
          ' replied to your comment in a subscribed thread',
      ],
      .threadCommentLike => [
        map['user']?['name'] ?? '?',
        if (map['thread']?['title'] != null) ...[
          ' liked your comment in ',
          map['thread']['title'],
        ] else
          ' liked your comment in a subscribed thread',
      ],
      _ => const [],
    };

    return ThreadCommentNotification._(
      map: map,
      type: type,
      imageUrl: map['user']?['avatar']?['large'],
      texts: texts,
      userId: map['user']?['id'] ?? 0,
      commentId: map['comment']?['id'] ?? 0,
      commentSiteUrl: map['comment']?['siteUrl'],
    );
  }

  final int userId;
  final int commentId;
  final String? commentSiteUrl;
}

class MediaReleaseNotification extends SiteNotification {
  MediaReleaseNotification._({
    required super.map,
    required super.type,
    required super.imageUrl,
    required super.texts,
    required this.mediaId,
  });

  factory MediaReleaseNotification(
    Map<String, dynamic> map,
    NotificationType type,
    ImageQuality imageQuality,
  ) {
    final List<String> texts = switch (type) {
      .airing => [
        map['media']?['title']?['userPreferred'] ?? '?',
        ' episode ',
        map['episode']?.toString() ?? '?',
        ' aired',
      ],
      .relatedMediaAddition => [
        map['media']?['title']?['userPreferred'] ?? '?',
        ' got added to the site',
      ],
      _ => const [],
    };

    return MediaReleaseNotification._(
      map: map,
      type: type,
      imageUrl: map['media']?['coverImage']?[imageQuality.value],
      texts: texts,
      mediaId: map['media']?['id'] ?? 0,
    );
  }

  final int mediaId;
}

class MediaChangeNotification extends SiteNotification {
  MediaChangeNotification._({
    required super.map,
    required super.type,
    required super.imageUrl,
    required super.texts,
    required this.mediaId,
    required this.reason,
  });

  factory MediaChangeNotification(
    Map<String, dynamic> map,
    NotificationType type,
    ImageQuality imageQuality,
  ) {
    final List<String> texts = switch (type) {
      .mediaDataChange => [
        map['media']?['title']?['userPreferred'] ?? '?',
        ' got site data changes',
      ],
      .mediaMerge => [
        List<String>.from(map['deletedMediaTitles'] ?? const [], growable: false).join(", "),
        ' got merged into ',
        map['media']?['title']?['userPreferred'] ?? '?',
      ],
      _ => const [],
    };

    return MediaChangeNotification._(
      map: map,
      type: type,
      imageUrl: map['media']?['coverImage']?[imageQuality.value],
      texts: texts,
      mediaId: map['media']?['id'] ?? 0,
      reason: map['reason'] ?? '',
    );
  }

  final int mediaId;
  final String reason;
}

class MediaDeletionNotification extends SiteNotification {
  MediaDeletionNotification._({
    required super.map,
    required super.type,
    required super.imageUrl,
    required super.texts,
    required this.reason,
  });

  factory MediaDeletionNotification(Map<String, dynamic> map, NotificationType type) =>
      MediaDeletionNotification._(
        map: map,
        type: type,
        imageUrl: null,
        texts: [map['deletedMediaTitle'] ?? '?', ' got deleted from the site'],
        reason: map['reason'] ?? '',
      );

  final String reason;
}
