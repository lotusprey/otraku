import 'package:otraku/localizations/gen.dart';

enum NotificationsFilter {
  all,
  replies,
  activity,
  forum,
  airing,
  follows,
  media;

  const NotificationsFilter();

  String localize(AppLocalizations l10n) => switch (this) {
    all => l10n.notificationsFilterAll,
    replies => l10n.notificationsFilterReplies,
    activity => l10n.notificationsFilterActivity,
    forum => l10n.notificationsFilterForum,
    airing => l10n.notificationsFilterAiring,
    follows => l10n.notificationsFilterFollows,
    media => l10n.notificationsFilterMedia,
  };

  List<String>? get vars => switch (this) {
    NotificationsFilter.all => null,
    NotificationsFilter.replies => const [
      'ACTIVITY_MESSAGE',
      'ACTIVITY_REPLY',
      'ACTIVITY_REPLY_SUBSCRIBED',
      'ACTIVITY_MENTION',
      'THREAD_COMMENT_REPLY',
      'THREAD_COMMENT_MENTION',
      'THREAD_SUBSCRIBED',
    ],
    NotificationsFilter.activity => const [
      'ACTIVITY_MESSAGE',
      'ACTIVITY_REPLY',
      'ACTIVITY_REPLY_SUBSCRIBED',
      'ACTIVITY_MENTION',
      'ACTIVITY_LIKE',
      'ACTIVITY_REPLY_LIKE',
    ],
    NotificationsFilter.forum => const [
      'THREAD_COMMENT_REPLY',
      'THREAD_COMMENT_MENTION',
      'THREAD_SUBSCRIBED',
      'THREAD_LIKE',
      'THREAD_COMMENT_LIKE',
    ],
    NotificationsFilter.airing => const ['AIRING'],
    NotificationsFilter.follows => const ['FOLLOWING'],
    NotificationsFilter.media => const [
      'RELATED_MEDIA_ADDITION',
      'MEDIA_DATA_CHANGE',
      'MEDIA_MERGE',
      'MEDIA_DELETION',
    ],
  };
}
