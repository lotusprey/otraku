import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/constants/notification_type.dart';
import 'package:otraku/models/pagination.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/settings.dart';

final notificationFilterProvider = StateProvider.autoDispose(
  (ref) => NotificationFilterType.all,
);

final notificationsProvider = ChangeNotifierProvider.autoDispose(
  (ref) => NotificationsNotifier(ref.watch(notificationFilterProvider)),
);

class NotificationsNotifier extends ChangeNotifier {
  NotificationsNotifier(this.filter) {
    _fetch();
  }

  final NotificationFilterType filter;

  var _pages = Pages<Notification>();
  AsyncValue<void> _dataState = const AsyncValue.loading();
  int _unreadCount = 0;

  Pages get pages => _pages;
  AsyncValue<void> get dataState => _dataState;
  int get unreadCount => _unreadCount;

  Future<void> _fetch({bool refresh = false}) async {
    if (_dataState is AsyncLoading) return;
    if (refresh) _pages = Pages();
    _dataState = const AsyncValue.loading();
    notifyListeners();

    _dataState = await AsyncValue.guard(() async {
      final data = await Client.get(GqlQuery.notifications, {
        'page': _pages.next,
        if (filter.index < 1) ...{
          'withCount': true,
          'resetCount': true,
        } else
          'filter': _filterTypeItems[filter.index],
      });

      _unreadCount = 0;
      if (filter.index < 1)
        _unreadCount = data['Viewer']?['unreadNotificationCount'] ?? 0;

      if (data['Page']?['notifications'] == null) return;

      final bool hasNext = data['Page']['pageInfo']?['hasNextPage'] ?? false;
      final items = <Notification>[];
      for (final n in data['Page']['notifications']) {
        final item = Notification.maybe(n);
        if (item != null) items.add(item);
      }

      _pages = _pages.remakeWith(items, hasNext);
    });

    notifyListeners();
  }
}

const _filterTypeItems = [
  null,
  ['AIRING'],
  [
    'ACTIVITY_MESSAGE',
    'ACTIVITY_REPLY',
    'ACTIVITY_REPLY_SUBSCRIBED',
    'ACTIVITY_MENTION',
    'ACTIVITY_LIKE',
    'ACTIVITY_REPLY_LIKE',
  ],
  [
    'THREAD_COMMENT_REPLY',
    'THREAD_COMMENT_MENTION',
    'THREAD_SUBSCRIBED',
    'THREAD_LIKE',
    'THREAD_COMMENT_LIKE',
  ],
  ['FOLLOWING'],
  [
    'RELATED_MEDIA_ADDITION',
    'MEDIA_DATA_CHANGE',
    'MEDIA_MERGE',
    'MEDIA_DELETION',
  ],
];

enum NotificationFilterType {
  all,
  airing,
  activity,
  forum,
  follows,
  media,
}

class Notification {
  Notification._({
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

  static Notification? maybe(Map<String, dynamic> map) {
    switch (map['type']) {
      case 'FOLLOWING':
        return Notification._(
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
        return Notification._(
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
        return Notification._(
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
        return Notification._(
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
        return Notification._(
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
        return Notification._(
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
        return Notification._(
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
        return Notification._(
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
        return Notification._(
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
        return Notification._(
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
        return Notification._(
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
        return Notification._(
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
        return Notification._(
          id: map['id'],
          type: NotificationType.RELATED_MEDIA_ADDITION,
          headId: map['media']['id'],
          bodyId: map['media']['id'],
          imageUrl: Settings().getCover(map['media']['coverImage']),
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
        return Notification._(
          id: map['id'],
          type: NotificationType.MEDIA_DATA_CHANGE,
          headId: map['media']['id'],
          imageUrl: Settings().getCover(map['media']['coverImage']),
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
        if (titles.isEmpty) return null;

        return Notification._(
          id: map['id'],
          type: NotificationType.MEDIA_MERGE,
          headId: map['media']['id'],
          imageUrl: Settings().getCover(map['media']['coverImage']),
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
        return Notification._(
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
        return Notification._(
          id: map['id'],
          type: NotificationType.AIRING,
          headId: map['media']['id'],
          bodyId: map['media']['id'],
          imageUrl: Settings().getCover(map['media']['coverImage']),
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
        return null;
    }
  }
}
