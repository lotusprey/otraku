enum NotificationType {
  FOLLOWING,
  ACTIVITY_MESSAGE,
  ACTIVITY_REPLY,
  ACTIVITY_REPLY_SUBSCRIBED,
  ACTIVITY_MENTION,
  ACTIVITY_LIKE,
  ACTIVITY_REPLY_LIKE,
  THREAD_COMMENT_REPLY,
  THREAD_COMMENT_MENTION,
  THREAD_SUBSCRIBED,
  THREAD_LIKE,
  THREAD_COMMENT_LIKE,
  RELATED_MEDIA_ADDITION,
  MEDIA_DATA_CHANGE,
  MEDIA_MERGE,
  MEDIA_DELETION,
  AIRING,
}

extension NotificationTypeExtension on NotificationType {
  static const _notificationNames = const {
    NotificationType.FOLLOWING: 'New followers',
    NotificationType.ACTIVITY_MESSAGE: 'New messages',
    NotificationType.ACTIVITY_REPLY: 'Replies to my activities',
    NotificationType.ACTIVITY_REPLY_SUBSCRIBED:
        'Replies to subscribed activities',
    NotificationType.ACTIVITY_MENTION: 'Activity mentions',
    NotificationType.ACTIVITY_LIKE: 'Likes on my activities',
    NotificationType.ACTIVITY_REPLY_LIKE: 'Likes on my activity replies',
    NotificationType.THREAD_COMMENT_REPLY: 'Replies to my forum comments',
    NotificationType.THREAD_COMMENT_MENTION: 'Forum mentions',
    NotificationType.THREAD_SUBSCRIBED: 'Comments on a subscribed thread',
    NotificationType.THREAD_LIKE: 'Likes on my forum threads',
    NotificationType.THREAD_COMMENT_LIKE: 'Likes on my forum comments',
    NotificationType.RELATED_MEDIA_ADDITION: 'New media related to me',
    NotificationType.MEDIA_DATA_CHANGE: 'Modified media in my lists',
    NotificationType.MEDIA_MERGE: 'Merged media in my lists',
    NotificationType.MEDIA_DELETION: 'Deleted media in my lists',
    NotificationType.AIRING: 'Airings of anime I am watching',
  };

  String get text => _notificationNames[this]!;
}
