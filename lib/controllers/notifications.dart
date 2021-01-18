import 'package:get/get.dart';
import 'package:otraku/controllers/viewer.dart';
import 'package:otraku/models/anilist/notification_data.dart';
import 'package:otraku/models/loadable_list.dart';
import 'package:otraku/helpers/network.dart';
import 'package:otraku/helpers/scrollable_controller.dart';

class Notifications extends ScrollableController {
  // ***************************************************************************
  // CONSTANTS
  // ***************************************************************************

  static const _notificationQuery = r'''
    query ViewerData($page: Int = 1, $filter: [NotificationType]) {
      Viewer {unreadNotificationCount}
      Page(page: $page) {
        pageInfo {hasNextPage}
        notifications(type_in: $filter, resetNotificationCount: true) {
          ... on FollowingNotification {
            type
            user {id name avatar {large}}
            createdAt
          }
          ... on ActivityMessageNotification {
            type
            activityId
            user {id name avatar {large}}
            createdAt
          }
          ... on ActivityReplyNotification {
            type
            activityId
            user {id name avatar {large}}
            createdAt
          }
          ... on ActivityReplySubscribedNotification {
            type
            activityId
            user {id name avatar {large}}
            createdAt
          }
          ... on ThreadCommentReplyNotification {
            type
            context
            commentId
            thread {title}
            user {id name avatar {large}}
            createdAt
          }
          ... on ActivityMentionNotification {
            type
            activityId
            user {id name avatar {large}}
            createdAt
          }
          ... on ThreadCommentMentionNotification {
            type
            commentId
            thread {title}
            user {id name avatar {large}}
            createdAt
          }
          ... on ThreadCommentSubscribedNotification {
            type
            commentId
            thread {title}
            user {id name avatar {large}}
            createdAt
          }
          ... on ActivityLikeNotification {
            type
            activityId
            user {id name avatar {large}}
            createdAt
          }
          ... on ActivityReplyLikeNotification {
            type
            activityId
            user {id name avatar {large}}
            createdAt
          }
          ... on ThreadLikeNotification {
            type
            thread {id title}
            user {id name avatar {large}}
            createdAt
          }
          ... on ThreadCommentLikeNotification {
            type
            commentId
            thread {title}
            user {id name avatar {large}}
            createdAt
          }
          ... on AiringNotification {
            type
            episode
            media {id type bannerImage title {userPreferred} coverImage {large}}
            createdAt
          }
          ... on RelatedMediaAdditionNotification {
            type
            media {id type bannerImage title {userPreferred} coverImage {large}}
            createdAt
          }
        }
      }
    }
  ''';

  static const _filters = const [
    null,
    const [
      'ACTIVITY_MESSAGE',
      'ACTIVITY_REPLY',
      'ACTIVITY_REPLY_SUBSCRIBED',
      'ACTIVITY_MENTION',
      'ACTIVITY_LIKE',
      'ACTIVITY_REPLY_LIKE',
    ],
    const [
      'THREAD_COMMENT_REPLY',
      'THREAD_COMMENT_MENTION',
      'THREAD_SUBSCRIBED',
      'THREAD_LIKE',
      'THREAD_COMMENT_LIKE',
    ],
    const ['AIRING', 'RELATED_MEDIA_ADDITION'],
    const ['FOLLOWING'],
  ];

  // ***************************************************************************
  // DATA & GETTERS & SETTERS
  // ***************************************************************************

  bool fetching = false;
  int _unreadCount = 0;
  int _filter = 0;
  LoadableList<NotificationData> _entries;

  int get unreadCount => _unreadCount;

  int get filter => _filter;

  set filter(int val) {
    if (val < 0 || val > _filters.length) return;
    _filter = val;
    scrollToTop();
    fetchData();
  }

  List<NotificationData> get entries => _entries?.items;

  // ***************************************************************************
  // FETCHING
  // ***************************************************************************

  Future<void> fetchData() async {
    fetching = true;
    Map<String, dynamic> data = await Network.request(
      _notificationQuery,
      _filter != 0 ? {'filter': _filters[_filter]} : null,
      popOnErr: false,
    );
    if (data == null) return;

    _unreadCount = _filter == 0 ? data['Viewer']['unreadNotificationCount'] : 0;
    data = data['Page'];

    final List<NotificationData> nl = [];
    for (final n in data['notifications']) nl.add(NotificationData(n));

    _entries = LoadableList(nl, data['pageInfo']['hasNextPage']);
    update();
    fetching = false;
  }

  Future<void> fetchPage() async {
    if (fetching) return;
    fetching = true;

    Map<String, dynamic> data = await Network.request(
      _notificationQuery,
      {
        'page': _entries.nextPage,
        if (_filter != 0) 'filter': _filters[_filter],
      },
      popOnErr: false,
    );
    if (data == null) return;

    _unreadCount = data['Viewer']['unreadNotificationCount'];
    data = data['Page'];

    final List<NotificationData> nl = [];
    for (final n in data['notifications']) nl.add(NotificationData(n));

    _entries.append(nl, data['pageInfo']['hasNextPage']);
    update();
    fetching = false;
  }

  @override
  void onClose() {
    Get.find<Viewer>().nullifyUnread();
    super.onClose();
  }
}
