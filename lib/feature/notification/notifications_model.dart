import 'package:otraku/extension/date_time_extension.dart';
import 'package:otraku/extension/iterable_extension.dart';
import 'package:otraku/feature/discover/discover_models.dart';
import 'package:otraku/util/persistence.dart';

class SiteNotification {
  SiteNotification._({
    required this.id,
    required this.type,
    required this.texts,
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
            texts: [map['user']['name'], ' followed you'],
            createdAt: DateTimeExtension.formattedDateTimeFromSeconds(
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
            texts: [map['user']['name'], ' mentioned you in an activity'],
            createdAt: DateTimeExtension.formattedDateTimeFromSeconds(
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
            texts: [map['user']['name'], ' sent you a message'],
            createdAt: DateTimeExtension.formattedDateTimeFromSeconds(
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
            texts: [map['user']['name'], ' replied to your activity'],
            createdAt: DateTimeExtension.formattedDateTimeFromSeconds(
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
            texts: [map['user']['name'], ' liked your activity'],
            createdAt: DateTimeExtension.formattedDateTimeFromSeconds(
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
            texts: [map['user']['name'], ' liked your reply'],
            createdAt: DateTimeExtension.formattedDateTimeFromSeconds(
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
              ' replied to a subscribed activity',
            ],
            createdAt: DateTimeExtension.formattedDateTimeFromSeconds(
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
            createdAt: DateTimeExtension.formattedDateTimeFromSeconds(
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
            createdAt: DateTimeExtension.formattedDateTimeFromSeconds(
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
            createdAt: DateTimeExtension.formattedDateTimeFromSeconds(
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
            createdAt: DateTimeExtension.formattedDateTimeFromSeconds(
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
            createdAt: DateTimeExtension.formattedDateTimeFromSeconds(
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
              map['media']['title']['userPreferred'],
              ' episode ',
              map['episode'].toString(),
              ' aired',
            ],
            createdAt: DateTimeExtension.formattedDateTimeFromSeconds(
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
              ' got added to the site',
            ],
            createdAt: DateTimeExtension.formattedDateTimeFromSeconds(
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
              ' got site data changes',
            ],
            createdAt: DateTimeExtension.formattedDateTimeFromSeconds(
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
              titles.join(", "),
              ' got merged into ',
              map['media']['title']['userPreferred'],
            ],
            createdAt: DateTimeExtension.formattedDateTimeFromSeconds(
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
              ' got deleted from the site',
            ],
            createdAt: DateTimeExtension.formattedDateTimeFromSeconds(
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
