import 'package:flutter/foundation.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/enums/notification_type.dart';
import 'package:otraku/helpers/fn_helper.dart';

class NotificationData {
  final NotificationType type;
  final int headId;
  final int bodyId;
  final String imageUrl;
  final List<String> texts;
  final bool markTextOnEvenIndex;
  final String timestamp;
  final Browsable browsable;

  NotificationData._({
    @required this.type,
    @required this.headId,
    @required this.bodyId,
    @required this.imageUrl,
    @required this.texts,
    @required this.markTextOnEvenIndex,
    @required this.timestamp,
    this.browsable,
  });

  factory NotificationData(final Map<String, dynamic> map) {
    switch (map['type']) {
      case 'FOLLOWING':
        return NotificationData._(
          type: NotificationType.FOLLOWING,
          headId: map['user']['id'],
          bodyId: map['user']['id'],
          imageUrl: map['user']['avatar']['large'],
          texts: [map['user']['name'], ' followed you.'],
          markTextOnEvenIndex: true,
          timestamp: FnHelper.millisecondsToTimeString(map['createdAt']),
          browsable: Browsable.user,
        );
      case 'ACTIVITY_MESSAGE':
        return NotificationData._(
          type: NotificationType.ACTIVITY_MESSAGE,
          headId: map['user']['id'],
          bodyId: map['activityId'],
          imageUrl: map['user']['avatar']['large'],
          texts: [map['user']['name'], ' sent you a message.'],
          markTextOnEvenIndex: true,
          timestamp: FnHelper.millisecondsToTimeString(map['createdAt']),
        );
      case 'ACTIVITY_REPLY':
        return NotificationData._(
          type: NotificationType.ACTIVITY_REPLY,
          headId: map['user']['id'],
          bodyId: map['activityId'],
          imageUrl: map['user']['avatar']['large'],
          texts: [map['user']['name'], ' replied to your activity.'],
          markTextOnEvenIndex: true,
          timestamp: FnHelper.millisecondsToTimeString(map['createdAt']),
        );
      case 'ACTIVITY_REPLY_SUBSCRIBED':
        return NotificationData._(
          type: NotificationType.ACTIVITY_REPLY_SUBSCRIBED,
          headId: map['user']['id'],
          bodyId: map['activityId'],
          imageUrl: map['user']['avatar']['large'],
          texts: [
            map['user']['name'],
            ' replied to activity you are subscribed to.',
          ],
          markTextOnEvenIndex: true,
          timestamp: FnHelper.millisecondsToTimeString(map['createdAt']),
        );
      case 'THREAD_COMMENT_REPLY':
        return NotificationData._(
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
          timestamp: FnHelper.millisecondsToTimeString(map['createdAt']),
        );
      case 'ACTIVITY_MENTION':
        return NotificationData._(
          type: NotificationType.ACTIVITY_MENTION,
          headId: map['user']['id'],
          bodyId: map['activityId'],
          imageUrl: map['user']['avatar']['large'],
          texts: [map['user']['name'], ' mentioned you in an activity.'],
          markTextOnEvenIndex: true,
          timestamp: FnHelper.millisecondsToTimeString(map['createdAt']),
        );
      case 'THREAD_COMMENT_MENTION':
        return NotificationData._(
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
          timestamp: FnHelper.millisecondsToTimeString(map['createdAt']),
        );
      case 'THREAD_SUBSCRIBED':
        return NotificationData._(
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
          timestamp: FnHelper.millisecondsToTimeString(map['createdAt']),
        );
      case 'ACTIVITY_LIKE':
        return NotificationData._(
          type: NotificationType.ACTIVITY_LIKE,
          headId: map['user']['id'],
          bodyId: map['activityId'],
          imageUrl: map['user']['avatar']['large'],
          texts: [map['user']['name'], ' liked your activity.'],
          markTextOnEvenIndex: true,
          timestamp: FnHelper.millisecondsToTimeString(map['createdAt']),
        );
      case 'ACTIVITY_REPLY_LIKE':
        return NotificationData._(
          type: NotificationType.ACTIVITY_REPLY_LIKE,
          headId: map['user']['id'],
          bodyId: map['activityId'],
          imageUrl: map['user']['avatar']['large'],
          texts: [map['user']['name'], ' liked your reply.'],
          markTextOnEvenIndex: true,
          timestamp: FnHelper.millisecondsToTimeString(map['createdAt']),
        );
      case 'THREAD_LIKE':
        return NotificationData._(
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
          timestamp: FnHelper.millisecondsToTimeString(map['createdAt']),
        );
      case 'THREAD_COMMENT_LIKE':
        return NotificationData._(
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
          timestamp: FnHelper.millisecondsToTimeString(map['createdAt']),
        );
      case 'AIRING':
        return NotificationData._(
          type: NotificationType.AIRING,
          headId: map['media']['id'],
          bodyId: map['media']['id'],
          imageUrl: map['media']['coverImage']['large'],
          texts: [
            'Episode ',
            map['episode'].toString(),
            ' of ',
            map['media']['title']['userPreferred'],
            ' aired.',
          ],
          markTextOnEvenIndex: false,
          timestamp: FnHelper.millisecondsToTimeString(map['createdAt']),
          browsable: map['media']['type'] == 'ANIME'
              ? Browsable.anime
              : Browsable.manga,
        );
      case 'RELATED_MEDIA_ADDITION':
        return NotificationData._(
          type: NotificationType.RELATED_MEDIA_ADDITION,
          headId: map['media']['id'],
          bodyId: map['media']['id'],
          imageUrl: map['media']['coverImage']['large'],
          texts: [
            map['media']['title']['userPreferred'],
            ' was added to the site.',
          ],
          markTextOnEvenIndex: true,
          timestamp: FnHelper.millisecondsToTimeString(map['createdAt']),
          browsable: map['media']['type'] == 'ANIME'
              ? Browsable.anime
              : Browsable.manga,
        );
      default:
        return NotificationData._(
          type: null,
          headId: null,
          bodyId: null,
          imageUrl: '',
          texts: const [],
          markTextOnEvenIndex: false,
          timestamp: '',
        );
    }
  }
}
