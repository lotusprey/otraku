import 'package:otraku/constants/explorable.dart';
import 'package:otraku/constants/notification_type.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/settings.dart';

class NotificationModel {
  final int id;
  final NotificationType type;
  final List<String> texts;
  final bool markTextOnEvenIndex;
  final String timestamp;
  final int? headId;
  final int? bodyId;
  final String? details;
  final String? imageUrl;
  final Explorable? explorable;

  NotificationModel._({
    required this.id,
    required this.type,
    required this.texts,
    required this.markTextOnEvenIndex,
    required this.timestamp,
    this.headId,
    this.bodyId,
    this.details,
    this.imageUrl,
    this.explorable,
  })  : assert((headId == null) == (imageUrl == null)),
        assert(details == null || bodyId == null);

  factory NotificationModel(Map<String, dynamic> map) {
    switch (map['type']) {
      case 'FOLLOWING':
        return NotificationModel._(
          id: map['id'],
          type: NotificationType.FOLLOWING,
          headId: map['user']['id'],
          bodyId: map['user']['id'],
          imageUrl: map['user']['avatar']['large'],
          texts: [map['user']['name'], ' followed you.'],
          markTextOnEvenIndex: true,
          timestamp: Convert.millisToStr(map['createdAt']),
          explorable: Explorable.user,
        );
      case 'ACTIVITY_MESSAGE':
        return NotificationModel._(
          id: map['id'],
          type: NotificationType.ACTIVITY_MESSAGE,
          headId: map['user']['id'],
          bodyId: map['activityId'],
          imageUrl: map['user']['avatar']['large'],
          texts: [map['user']['name'], ' sent you a message.'],
          markTextOnEvenIndex: true,
          timestamp: Convert.millisToStr(map['createdAt']),
        );
      case 'ACTIVITY_REPLY':
        return NotificationModel._(
          id: map['id'],
          type: NotificationType.ACTIVITY_REPLY,
          headId: map['user']['id'],
          bodyId: map['activityId'],
          imageUrl: map['user']['avatar']['large'],
          texts: [map['user']['name'], ' replied to your activity.'],
          markTextOnEvenIndex: true,
          timestamp: Convert.millisToStr(map['createdAt']),
        );
      case 'ACTIVITY_REPLY_SUBSCRIBED':
        return NotificationModel._(
          id: map['id'],
          type: NotificationType.ACTIVITY_REPLY_SUBSCRIBED,
          headId: map['user']['id'],
          bodyId: map['activityId'],
          imageUrl: map['user']['avatar']['large'],
          texts: [
            map['user']['name'],
            ' replied to activity you are subscribed to.',
          ],
          markTextOnEvenIndex: true,
          timestamp: Convert.millisToStr(map['createdAt']),
        );
      case 'THREAD_COMMENT_REPLY':
        return NotificationModel._(
          id: map['id'],
          type: NotificationType.THREAD_COMMENT_REPLY,
          headId: map['user']['id'],
          bodyId: map['commentId'],
          imageUrl: map['user']['avatar']['large'],
          texts: [
            map['user']['name'],
            if (map['thread'] != null) ...[
              ' replied to your comment in ',
              map['thread']['title']
            ] else
              ' replied to your comment in a subscribed thread',
          ],
          markTextOnEvenIndex: true,
          timestamp: Convert.millisToStr(map['createdAt']),
        );
      case 'ACTIVITY_MENTION':
        return NotificationModel._(
          id: map['id'],
          type: NotificationType.ACTIVITY_MENTION,
          headId: map['user']['id'],
          bodyId: map['activityId'],
          imageUrl: map['user']['avatar']['large'],
          texts: [map['user']['name'], ' mentioned you in an activity.'],
          markTextOnEvenIndex: true,
          timestamp: Convert.millisToStr(map['createdAt']),
        );
      case 'THREAD_COMMENT_MENTION':
        return NotificationModel._(
          id: map['id'],
          type: NotificationType.THREAD_COMMENT_MENTION,
          headId: map['user']['id'],
          bodyId: map['commentId'],
          imageUrl: map['user']['avatar']['large'],
          texts: [
            map['user']['name'],
            if (map['thread'] != null) ...[
              ' mentioned you in ',
              map['thread']['title']
            ] else
              ' mentioned you in a subscribed thread',
          ],
          markTextOnEvenIndex: true,
          timestamp: Convert.millisToStr(map['createdAt']),
        );
      case 'THREAD_SUBSCRIBED':
        return NotificationModel._(
          id: map['id'],
          type: NotificationType.THREAD_SUBSCRIBED,
          headId: map['user']['id'],
          bodyId: map['commentId'],
          imageUrl: map['user']['avatar']['large'],
          texts: [
            map['user']['name'],
            if (map['thread'] != null) ...[
              ' commented in ',
              map['thread']['title']
            ] else
              ' commented in a subscribed thread',
          ],
          markTextOnEvenIndex: true,
          timestamp: Convert.millisToStr(map['createdAt']),
        );
      case 'ACTIVITY_LIKE':
        return NotificationModel._(
          id: map['id'],
          type: NotificationType.ACTIVITY_LIKE,
          headId: map['user']['id'],
          bodyId: map['activityId'],
          imageUrl: map['user']['avatar']['large'],
          texts: [map['user']['name'], ' liked your activity.'],
          markTextOnEvenIndex: true,
          timestamp: Convert.millisToStr(map['createdAt']),
        );
      case 'ACTIVITY_REPLY_LIKE':
        return NotificationModel._(
          id: map['id'],
          type: NotificationType.ACTIVITY_REPLY_LIKE,
          headId: map['user']['id'],
          bodyId: map['activityId'],
          imageUrl: map['user']['avatar']['large'],
          texts: [map['user']['name'], ' liked your reply.'],
          markTextOnEvenIndex: true,
          timestamp: Convert.millisToStr(map['createdAt']),
        );
      case 'THREAD_LIKE':
        return NotificationModel._(
          id: map['id'],
          type: NotificationType.THREAD_LIKE,
          headId: map['user']['id'],
          bodyId: map['threadId'],
          imageUrl: map['user']['avatar']['large'],
          texts: [
            map['user']['name'],
            ' like your thread ',
            if (map['thread'] != null) map['thread']['title'],
          ],
          markTextOnEvenIndex: true,
          timestamp: Convert.millisToStr(map['createdAt']),
        );
      case 'THREAD_COMMENT_LIKE':
        return NotificationModel._(
          id: map['id'],
          type: NotificationType.THREAD_COMMENT_LIKE,
          headId: map['user']['id'],
          bodyId: map['commentId'],
          imageUrl: map['user']['avatar']['large'],
          texts: [
            map['user']['name'],
            if (map['thread'] != null) ...[
              ' liked your comment in ',
              map['thread']['title']
            ] else
              ' liked your comment in a subscribed thread',
          ],
          markTextOnEvenIndex: true,
          timestamp: Convert.millisToStr(map['createdAt']),
        );
      case 'RELATED_MEDIA_ADDITION':
        return NotificationModel._(
          id: map['id'],
          type: NotificationType.RELATED_MEDIA_ADDITION,
          headId: map['media']['id'],
          bodyId: map['media']['id'],
          imageUrl: map['media']['coverImage'][Settings().imageQuality],
          texts: [
            map['media']['title']['userPreferred'],
            ' was added to the site',
          ],
          markTextOnEvenIndex: true,
          timestamp: Convert.millisToStr(map['createdAt']),
          explorable: map['media']['type'] == 'ANIME'
              ? Explorable.anime
              : Explorable.manga,
        );
      case 'MEDIA_DATA_CHANGE':
        return NotificationModel._(
          id: map['id'],
          type: NotificationType.MEDIA_DATA_CHANGE,
          headId: map['media']['id'],
          imageUrl: map['media']['coverImage'][Settings().imageQuality],
          details: map['reason'],
          texts: [
            map['media']['title']['userPreferred'],
            ' received site data changes',
          ],
          markTextOnEvenIndex: true,
          timestamp: Convert.millisToStr(map['createdAt']),
          explorable: map['media']['type'] == 'ANIME'
              ? Explorable.anime
              : Explorable.manga,
        );
      case 'MEDIA_MERGE':
        final titles = List<String>.from(
          map['deletedMediaTitles'] ?? [],
          growable: false,
        );
        if (titles.isEmpty) throw ArgumentError('No titles in media merge');

        return NotificationModel._(
          id: map['id'],
          type: NotificationType.MEDIA_MERGE,
          headId: map['media']['id'],
          imageUrl: map['media']['coverImage'][Settings().imageQuality],
          details: map['reason'],
          texts: [
            '${titles.join(", ")} ${titles.length < 2 ? "was" : "were"} merged into ',
            map['media']['title']['userPreferred'],
          ],
          markTextOnEvenIndex: false,
          timestamp: Convert.millisToStr(map['createdAt']),
          explorable: map['media']['type'] == 'ANIME'
              ? Explorable.anime
              : Explorable.manga,
        );
      case 'MEDIA_DELETION':
        return NotificationModel._(
          id: map['id'],
          type: NotificationType.MEDIA_DELETION,
          details: map['reason'],
          texts: [
            map['deletedMediaTitle'],
            ' was deleted from the site',
          ],
          markTextOnEvenIndex: true,
          timestamp: Convert.millisToStr(map['createdAt']),
        );
      case 'AIRING':
        return NotificationModel._(
          id: map['id'],
          type: NotificationType.AIRING,
          headId: map['media']['id'],
          bodyId: map['media']['id'],
          imageUrl: map['media']['coverImage'][Settings().imageQuality],
          texts: [
            'Episode ',
            map['episode'].toString(),
            ' of ',
            map['media']['title']['userPreferred'],
            ' aired',
          ],
          markTextOnEvenIndex: false,
          timestamp: Convert.millisToStr(map['createdAt']),
          explorable: map['media']['type'] == 'ANIME'
              ? Explorable.anime
              : Explorable.manga,
        );
      default:
        throw ArgumentError.notNull('type');
    }
  }
}
