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
    fetch();
  }

  final NotificationFilterType filter;

  var _pages = const AsyncValue<Pages<NotificationItem>>.loading();
  int _unreadCount = 0;

  AsyncValue<Pages<NotificationItem>> get pages => _pages;
  int get unreadCount => _unreadCount;

  Future<void> fetch() async {
    _pages = const AsyncValue.loading();
    notifyListeners();

    _pages = await AsyncValue.guard(() async {
      final data = await Client.get(GqlQuery.notifications, {
        'page': 1,
        if (filter.index < 1) ...{
          'withCount': true,
          'resetCount': true,
        } else
          'filter': _filterTypeItems[filter.index],
      });

      _unreadCount = 0;
      if (filter.index < 1)
        _unreadCount = data['Viewer']?['unreadNotificationCount'] ?? 0;

      if (data['Page']?['notifications'] == null) return Pages();

      final bool hasNext = data['Page']['pageInfo']?['hasNextPage'] ?? false;
      final items = <NotificationItem>[];
      for (final n in data['Page']['notifications']) {
        final item = NotificationItem.maybe(n);
        if (item != null) items.add(item);
      }

      return Pages.from(items: items, hasNext: hasNext);
    });

    notifyListeners();
  }

  Future<void> fetchNext() async {
    final value = _pages.value;
    if (value == null) return;
    _pages = _pages.copyWithPrevious(const AsyncValue.loading());
    notifyListeners();

    _pages = await AsyncValue.guard(() async {
      final data = await Client.get(GqlQuery.notifications, {
        'page': value.next,
        if (filter.index > 0) 'filter': _filterTypeItems[filter.index],
      });

      if (data['Page']?['notifications'] == null) return value;

      final bool hasNext = data['Page']['pageInfo']?['hasNextPage'] ?? false;
      final items = <NotificationItem>[];
      for (final n in data['Page']['notifications']) {
        final item = NotificationItem.maybe(n);
        if (item != null) items.add(item);
      }

      return value.remakeWith(items, hasNext);
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

const notificationFilterNames = [
  'All',
  'Airing',
  'Activity',
  'Forum',
  'Follows',
  'Media',
];

enum NotificationFilterType {
  all,
  airing,
  activity,
  forum,
  follows,
  media,
}

class NotificationItem {
  NotificationItem._({
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

  static NotificationItem? maybe(Map<String, dynamic> map) {
    switch (map['type']) {
      case 'FOLLOWING':
        return NotificationItem._(
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
        return NotificationItem._(
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
        return NotificationItem._(
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
        return NotificationItem._(
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
        return NotificationItem._(
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
        return NotificationItem._(
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
        return NotificationItem._(
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
        return NotificationItem._(
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
        return NotificationItem._(
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
        return NotificationItem._(
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
        return NotificationItem._(
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
        return NotificationItem._(
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
        return NotificationItem._(
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
        return NotificationItem._(
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
        if (titles.isEmpty) return null;

        return NotificationItem._(
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
        return NotificationItem._(
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
        return NotificationItem._(
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
        return null;
    }
  }
}
