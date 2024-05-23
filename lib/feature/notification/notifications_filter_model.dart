enum NotificationsFilter {
  all('All'),
  replies('Replies'),
  activity('Activity'),
  forum('Forum'),
  airing('Airing'),
  follows('Follows'),
  media('Media');

  const NotificationsFilter(this.label);

  final String label;

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
