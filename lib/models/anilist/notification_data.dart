import 'package:flutter/foundation.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/enums/notification_type.dart';
import 'package:otraku/helpers/model_helper.dart';

class NotificationData {
  final NotificationType type;
  final int headId;
  final int bodyId;
  final String imageUrl;
  final List<String> texts;
  final bool markTextOnEvenIndex;
  final String timestamp;
  final Browsable mediaType;

  NotificationData._({
    @required this.type,
    @required this.headId,
    @required this.bodyId,
    @required this.imageUrl,
    @required this.texts,
    @required this.markTextOnEvenIndex,
    @required this.timestamp,
    this.mediaType,
  });

  factory NotificationData(Map<String, dynamic> data) {
    final date = DateTime.fromMillisecondsSinceEpoch(data['createdAt'] * 1000);
    switch (data['type']) {
      case 'FOLLOWING':
        return NotificationData._(
          type: NotificationType.FOLLOWING,
          headId: data['user']['id'],
          bodyId: data['user']['id'],
          imageUrl: data['user']['avatar']['large'],
          texts: [data['user']['name'], ' followed you.'],
          markTextOnEvenIndex: true,
          timestamp: ModelHelper.dateTimeToString(date),
        );
      case 'ACTIVITY_MESSAGE':
        return NotificationData._(
          type: NotificationType.ACTIVITY_MESSAGE,
          headId: data['user']['id'],
          bodyId: data['activityId'],
          imageUrl: data['user']['avatar']['large'],
          texts: [data['user']['name'], ' sent you a message.'],
          markTextOnEvenIndex: true,
          timestamp: ModelHelper.dateTimeToString(date),
        );
      case 'ACTIVITY_REPLY':
        return NotificationData._(
          type: NotificationType.ACTIVITY_REPLY,
          headId: data['user']['id'],
          bodyId: data['activityId'],
          imageUrl: data['user']['avatar']['large'],
          texts: [data['user']['name'], ' replied to your activity.'],
          markTextOnEvenIndex: true,
          timestamp: ModelHelper.dateTimeToString(date),
        );
      case 'ACTIVITY_REPLY_SUBSCRIBED':
        return NotificationData._(
          type: NotificationType.ACTIVITY_REPLY_SUBSCRIBED,
          headId: data['user']['id'],
          bodyId: data['activityId'],
          imageUrl: data['user']['avatar']['large'],
          texts: [
            data['user']['name'],
            ' replied to activity you are subscribed to.',
          ],
          markTextOnEvenIndex: true,
          timestamp: ModelHelper.dateTimeToString(date),
        );
      case 'THREAD_COMMENT_REPLY':
        return NotificationData._(
          type: NotificationType.THREAD_COMMENT_REPLY,
          headId: data['user']['id'],
          bodyId: data['commentId'],
          imageUrl: data['user']['avatar']['large'],
          texts: [
            data['user']['name'],
            ' replied to your comment in ',
            data['thread']['title'],
          ],
          markTextOnEvenIndex: true,
          timestamp: ModelHelper.dateTimeToString(date),
        );
      case 'ACTIVITY_MENTION':
        return NotificationData._(
          type: NotificationType.ACTIVITY_MENTION,
          headId: data['user']['id'],
          bodyId: data['activityId'],
          imageUrl: data['user']['avatar']['large'],
          texts: [data['user']['name'], ' mentioned you in an activity.'],
          markTextOnEvenIndex: true,
          timestamp: ModelHelper.dateTimeToString(date),
        );
      case 'THREAD_COMMENT_MENTION':
        return NotificationData._(
          type: NotificationType.THREAD_COMMENT_MENTION,
          headId: data['user']['id'],
          bodyId: data['commentId'],
          imageUrl: data['user']['avatar']['large'],
          texts: [
            data['user']['name'],
            ' mentioned you in ',
            data['thread']['title'],
          ],
          markTextOnEvenIndex: true,
          timestamp: ModelHelper.dateTimeToString(date),
        );
      case 'THREAD_SUBSCRIBED':
        return NotificationData._(
          type: NotificationType.THREAD_SUBSCRIBED,
          headId: data['user']['id'],
          bodyId: data['commentId'],
          imageUrl: data['user']['avatar']['large'],
          texts: [
            data['user']['name'],
            ' commented in ',
            data['thread']['title'],
          ],
          markTextOnEvenIndex: true,
          timestamp: ModelHelper.dateTimeToString(date),
        );
      case 'ACTIVITY_LIKE':
        return NotificationData._(
          type: NotificationType.ACTIVITY_LIKE,
          headId: data['user']['id'],
          bodyId: data['activityId'],
          imageUrl: data['user']['avatar']['large'],
          texts: [data['user']['name'], ' liked your activity.'],
          markTextOnEvenIndex: true,
          timestamp: ModelHelper.dateTimeToString(date),
        );
      case 'ACTIVITY_REPLY_LIKE':
        return NotificationData._(
          type: NotificationType.ACTIVITY_REPLY_LIKE,
          headId: data['user']['id'],
          bodyId: data['activityId'],
          imageUrl: data['user']['avatar']['large'],
          texts: [data['user']['name'], ' liked your reply.'],
          markTextOnEvenIndex: true,
          timestamp: ModelHelper.dateTimeToString(date),
        );
      case 'THREAD_LIKE':
        return NotificationData._(
          type: NotificationType.THREAD_LIKE,
          headId: data['user']['id'],
          bodyId: data['threadId'],
          imageUrl: data['user']['avatar']['large'],
          texts: [
            data['user']['name'],
            ' like your thread ',
            data['thread']['title'],
          ],
          markTextOnEvenIndex: true,
          timestamp: ModelHelper.dateTimeToString(date),
        );
      case 'THREAD_COMMENT_LIKE':
        return NotificationData._(
          type: NotificationType.THREAD_COMMENT_LIKE,
          headId: data['user']['id'],
          bodyId: data['commentId'],
          imageUrl: data['user']['avatar']['large'],
          texts: [
            data['user']['name'],
            ' liked your comment in ',
            data['thread']['title'],
          ],
          markTextOnEvenIndex: true,
          timestamp: ModelHelper.dateTimeToString(date),
        );
      case 'AIRING':
        return NotificationData._(
          type: NotificationType.AIRING,
          headId: data['media']['id'],
          bodyId: data['media']['id'],
          imageUrl: data['media']['coverImage']['large'],
          texts: [
            'Episode ',
            data['episode'].toString(),
            ' of ',
            data['media']['title']['userPreferred'],
            ' aired.',
          ],
          markTextOnEvenIndex: false,
          timestamp: ModelHelper.dateTimeToString(date),
          mediaType: data['media']['type'] == 'ANIME'
              ? Browsable.anime
              : Browsable.manga,
        );
      case 'RELATED_MEDIA_ADDITION':
        return NotificationData._(
          type: NotificationType.RELATED_MEDIA_ADDITION,
          headId: data['media']['id'],
          bodyId: data['media']['id'],
          imageUrl: data['media']['coverImage']['large'],
          texts: [
            data['media']['title']['userPreferred'],
            ' was added to the site.',
          ],
          markTextOnEvenIndex: true,
          timestamp: ModelHelper.dateTimeToString(date),
          mediaType: data['media']['type'] == 'ANIME'
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
