import 'package:otraku/common/utils/extensions.dart';
import 'package:otraku/modules/discover/discover_models.dart';
import 'package:otraku/common/utils/persistence.dart';

class SiteNotification {
  SiteNotification._({
    required this.id,
    required this.type,
    required this.texts,
    required this.markTextOnEvenIndex,
    required this.createdAt,
    this.headId,
    this.bodyId,
    this.details,
    this.imageUrl,
    this.discoverType,
  })  : assert((headId == null) == (imageUrl == null)),
        assert(details == null || bodyId == null);

  final int id;
  final NotificationType type;
  final List<String> texts;
  final bool markTextOnEvenIndex;
  final String createdAt;
  final int? headId;
  final int? bodyId;
  final String? details;
  final String? imageUrl;
  final DiscoverType? discoverType;

  static SiteNotification? maybe(Map<String, dynamic> map) {
    try {
      switch (map['type']) {
        case 'FOLLOWING':
          return SiteNotification._(
            id: map['id'],
            type: NotificationType.following,
            headId: map['user']['id'],
            bodyId: map['user']['id'],
            imageUrl: map['user']['avatar']['large'],
            texts: [map['user']['name'], ' followed you.'],
            markTextOnEvenIndex: true,
            createdAt: DateTimeUtil.formattedDateTimeFromSeconds(
              map['createdAt'],
            ),
            discoverType: DiscoverType.user,
          );
        case 'ACTIVITY_MENTION':
          return SiteNotification._(
            id: map['id'],
            type: NotificationType.activityMention,
            headId: map['user']['id'],
            bodyId: map['activityId'],
            imageUrl: map['user']['avatar']['large'],
            texts: [map['user']['name'], ' mentioned you in an activity.'],
            markTextOnEvenIndex: true,
            createdAt: DateTimeUtil.formattedDateTimeFromSeconds(
              map['createdAt'],
            ),
          );
        case 'ACTIVITY_MESSAGE':
          return SiteNotification._(
            id: map['id'],
            type: NotificationType.activityMessage,
            headId: map['user']['id'],
            bodyId: map['activityId'],
            imageUrl: map['user']['avatar']['large'],
            texts: [map['user']['name'], ' sent you a message.'],
            markTextOnEvenIndex: true,
            createdAt: DateTimeUtil.formattedDateTimeFromSeconds(
              map['createdAt'],
            ),
          );
        case 'ACTIVITY_REPLY':
          return SiteNotification._(
            id: map['id'],
            type: NotificationType.activityReply,
            headId: map['user']['id'],
            bodyId: map['activityId'],
            imageUrl: map['user']['avatar']['large'],
            texts: [map['user']['name'], ' replied to your activity.'],
            markTextOnEvenIndex: true,
            createdAt: DateTimeUtil.formattedDateTimeFromSeconds(
              map['createdAt'],
            ),
          );
        case 'ACTIVITY_LIKE':
          return SiteNotification._(
            id: map['id'],
            type: NotificationType.activityLike,
            headId: map['user']['id'],
            bodyId: map['activityId'],
            imageUrl: map['user']['avatar']['large'],
            texts: [map['user']['name'], ' liked your activity.'],
            markTextOnEvenIndex: true,
            createdAt: DateTimeUtil.formattedDateTimeFromSeconds(
              map['createdAt'],
            ),
          );
        case 'ACTIVITY_REPLY_LIKE':
          return SiteNotification._(
            id: map['id'],
            type: NotificationType.acrivityReplyLike,
            headId: map['user']['id'],
            bodyId: map['activityId'],
            imageUrl: map['user']['avatar']['large'],
            texts: [map['user']['name'], ' liked your reply.'],
            markTextOnEvenIndex: true,
            createdAt: DateTimeUtil.formattedDateTimeFromSeconds(
              map['createdAt'],
            ),
          );
        case 'ACTIVITY_REPLY_SUBSCRIBED':
          return SiteNotification._(
            id: map['id'],
            type: NotificationType.activityReplySubscribed,
            headId: map['user']['id'],
            bodyId: map['activityId'],
            imageUrl: map['user']['avatar']['large'],
            texts: [
              map['user']['name'],
              ' replied to activity you are subscribed to.',
            ],
            markTextOnEvenIndex: true,
            createdAt: DateTimeUtil.formattedDateTimeFromSeconds(
              map['createdAt'],
            ),
          );
        case 'THREAD_LIKE':
          return SiteNotification._(
            id: map['id'],
            type: NotificationType.threadLike,
            headId: map['user']['id'],
            imageUrl: map['user']['avatar']['large'],
            details: map['thread']?['siteUrl'],
            texts: [
              map['user']['name'],
              ' liked your thread ',
              if (map['thread'] != null) map['thread']['title'],
            ],
            markTextOnEvenIndex: true,
            createdAt: DateTimeUtil.formattedDateTimeFromSeconds(
              map['createdAt'],
            ),
          );
        case 'THREAD_SUBSCRIBED':
          return SiteNotification._(
            id: map['id'],
            type: NotificationType.threadReplySubscribed,
            headId: map['user']['id'],
            imageUrl: map['user']['avatar']['large'],
            details: map['comment']?['siteUrl'],
            texts: [
              map['user']['name'],
              if (map['thread'] != null) ...[
                ' commented in ',
                map['thread']['title']
              ] else
                ' commented in a subscribed thread',
            ],
            markTextOnEvenIndex: true,
            createdAt: DateTimeUtil.formattedDateTimeFromSeconds(
              map['createdAt'],
            ),
          );
        case 'THREAD_COMMENT_LIKE':
          return SiteNotification._(
            id: map['id'],
            type: NotificationType.threadCommentLike,
            headId: map['user']['id'],
            imageUrl: map['user']['avatar']['large'],
            details: map['comment']?['siteUrl'],
            texts: [
              map['user']['name'],
              if (map['thread'] != null) ...[
                ' liked your comment in ',
                map['thread']['title']
              ] else
                ' liked your comment in a subscribed thread',
            ],
            markTextOnEvenIndex: true,
            createdAt: DateTimeUtil.formattedDateTimeFromSeconds(
              map['createdAt'],
            ),
          );
        case 'THREAD_COMMENT_REPLY':
          return SiteNotification._(
            id: map['id'],
            type: NotificationType.threadCommentReply,
            headId: map['user']['id'],
            imageUrl: map['user']['avatar']['large'],
            details: map['comment']?['siteUrl'],
            texts: [
              map['user']['name'],
              if (map['thread'] != null) ...[
                ' replied to your comment in ',
                map['thread']['title']
              ] else
                ' replied to your comment in a subscribed thread',
            ],
            markTextOnEvenIndex: true,
            createdAt: DateTimeUtil.formattedDateTimeFromSeconds(
              map['createdAt'],
            ),
          );
        case 'THREAD_COMMENT_MENTION':
          return SiteNotification._(
            id: map['id'],
            type: NotificationType.threadCommentMention,
            headId: map['user']['id'],
            imageUrl: map['user']['avatar']['large'],
            details: map['comment']?['siteUrl'],
            texts: [
              map['user']['name'],
              if (map['thread'] != null) ...[
                ' mentioned you in ',
                map['thread']['title']
              ] else
                ' mentioned you in a subscribed thread',
            ],
            markTextOnEvenIndex: true,
            createdAt: DateTimeUtil.formattedDateTimeFromSeconds(
              map['createdAt'],
            ),
          );
        case 'AIRING':
          return SiteNotification._(
            id: map['id'],
            type: NotificationType.airing,
            headId: map['media']['id'],
            bodyId: map['media']['id'],
            imageUrl: map['media']['coverImage']
                [Persistence().imageQuality.value],
            texts: [
              'Episode ',
              map['episode'].toString(),
              ' of ',
              map['media']['title']['userPreferred'],
              ' aired',
            ],
            markTextOnEvenIndex: false,
            createdAt: DateTimeUtil.formattedDateTimeFromSeconds(
              map['createdAt'],
            ),
            discoverType: map['media']['type'] == 'ANIME'
                ? DiscoverType.anime
                : DiscoverType.manga,
          );
        case 'RELATED_MEDIA_ADDITION':
          return SiteNotification._(
            id: map['id'],
            type: NotificationType.relatedMediaAddition,
            headId: map['media']['id'],
            bodyId: map['media']['id'],
            imageUrl: map['media']['coverImage']
                [Persistence().imageQuality.value],
            texts: [
              map['media']['title']['userPreferred'],
              ' was added to the site',
            ],
            markTextOnEvenIndex: true,
            createdAt: DateTimeUtil.formattedDateTimeFromSeconds(
              map['createdAt'],
            ),
            discoverType: map['media']['type'] == 'ANIME'
                ? DiscoverType.anime
                : DiscoverType.manga,
          );
        case 'MEDIA_DATA_CHANGE':
          return SiteNotification._(
            id: map['id'],
            type: NotificationType.mediaDataChange,
            headId: map['media']['id'],
            imageUrl: map['media']['coverImage']
                [Persistence().imageQuality.value],
            details: map['reason'],
            texts: [
              map['media']['title']['userPreferred'],
              ' received site data changes',
            ],
            markTextOnEvenIndex: true,
            createdAt: DateTimeUtil.formattedDateTimeFromSeconds(
              map['createdAt'],
            ),
            discoverType: map['media']['type'] == 'ANIME'
                ? DiscoverType.anime
                : DiscoverType.manga,
          );
        case 'MEDIA_MERGE':
          final titles = List<String>.from(
            map['deletedMediaTitles'] ?? [],
            growable: false,
          );
          if (titles.isEmpty) return null;

          return SiteNotification._(
            id: map['id'],
            type: NotificationType.mediaMerge,
            headId: map['media']['id'],
            imageUrl: map['media']['coverImage']
                [Persistence().imageQuality.value],
            details: map['reason'],
            texts: [
              '${titles.join(", ")} ${titles.length < 2 ? "was" : "were"} merged into ',
              map['media']['title']['userPreferred'],
            ],
            markTextOnEvenIndex: false,
            createdAt: DateTimeUtil.formattedDateTimeFromSeconds(
              map['createdAt'],
            ),
            discoverType: map['media']['type'] == 'ANIME'
                ? DiscoverType.anime
                : DiscoverType.manga,
          );
        case 'MEDIA_DELETION':
          return SiteNotification._(
            id: map['id'],
            type: NotificationType.mediaDeletion,
            details: map['reason'],
            texts: [
              map['deletedMediaTitle'],
              ' was deleted from the site',
            ],
            markTextOnEvenIndex: true,
            createdAt: DateTimeUtil.formattedDateTimeFromSeconds(
              map['createdAt'],
            ),
          );
        default:
          return null;
      }
    } catch (_) {
      return null;
    }
  }
}

enum NotificationType {
  following('Follows', 'FOLLOWING'),
  activityMessage('Messages', 'ACTIVITY_MESSAGE'),
  activityReply('Activity replies', 'ACTIVITY_REPLY'),
  activityReplySubscribed(
      'Subscribed activity replies', 'ACTIVITY_REPLY_SUBSCRIBED'),
  activityMention('Activity mentions', 'ACTIVITY_MENTION'),
  activityLike('Activity likes', 'ACTIVITY_LIKE'),
  acrivityReplyLike('Activity reply likes', 'ACTIVITY_REPLY_LIKE'),
  threadCommentReply('Thread comments', 'THREAD_COMMENT_REPLY'),
  threadCommentMention('Thread mentions', 'THREAD_COMMENT_MENTION'),
  threadReplySubscribed('Subscribed thread replies', 'THREAD_SUBSCRIBED'),
  threadLike('Thread likes', 'THREAD_LIKE'),
  threadCommentLike('Thread comment likes', 'THREAD_COMMENT_LIKE'),
  relatedMediaAddition('Related media additions', 'RELATED_MEDIA_ADDITION'),
  mediaDataChange('Media changes', 'MEDIA_DATA_CHANGE'),
  mediaMerge('Media merges', 'MEDIA_MERGE'),
  mediaDeletion('Media deletions', 'MEDIA_DELETION'),
  airing('Episode releases', 'AIRING');

  const NotificationType(this.label, this.value);

  final String label;
  final String value;

  static NotificationType? from(String? value) =>
      NotificationType.values.firstWhereOrNull((v) => v.value == value);
}

enum NotificationFilter {
  all('All'),
  replies('Replies'),
  activity('Activity'),
  forum('Forum'),
  airing('Airing'),
  follows('Follows'),
  media('Media');

  const NotificationFilter(this.label);

  final String label;

  List<String>? get vars => switch (this) {
        NotificationFilter.all => null,
        NotificationFilter.replies => const [
            'ACTIVITY_MESSAGE',
            'ACTIVITY_REPLY',
            'ACTIVITY_REPLY_SUBSCRIBED',
            'ACTIVITY_MENTION',
            'THREAD_COMMENT_REPLY',
            'THREAD_COMMENT_MENTION',
            'THREAD_SUBSCRIBED',
          ],
        NotificationFilter.activity => const [
            'ACTIVITY_MESSAGE',
            'ACTIVITY_REPLY',
            'ACTIVITY_REPLY_SUBSCRIBED',
            'ACTIVITY_MENTION',
            'ACTIVITY_LIKE',
            'ACTIVITY_REPLY_LIKE',
          ],
        NotificationFilter.forum => const [
            'THREAD_COMMENT_REPLY',
            'THREAD_COMMENT_MENTION',
            'THREAD_SUBSCRIBED',
            'THREAD_LIKE',
            'THREAD_COMMENT_LIKE',
          ],
        NotificationFilter.airing => const ['AIRING'],
        NotificationFilter.follows => const ['FOLLOWING'],
        NotificationFilter.media => const [
            'RELATED_MEDIA_ADDITION',
            'MEDIA_DATA_CHANGE',
            'MEDIA_MERGE',
            'MEDIA_DELETION',
          ],
      };
}
