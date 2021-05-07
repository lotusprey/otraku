import 'package:get/get.dart';
import 'package:otraku/controllers/viewer.dart';
import 'package:otraku/models/notification_model.dart';
import 'package:otraku/models/page_model.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/scroll_x_controller.dart';

class Notifications extends ScrollxController {
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
            id
            type
            user {id name avatar {large}}
            createdAt
          }
          ... on ActivityMessageNotification {
            id
            type
            activityId
            user {id name avatar {large}}
            createdAt
          }
          ... on ActivityReplyNotification {
            id
            type
            activityId
            user {id name avatar {large}}
            createdAt
          }
          ... on ActivityReplySubscribedNotification {
            id
            type
            activityId
            user {id name avatar {large}}
            createdAt
          }
          ... on ThreadCommentReplyNotification {
            id
            type
            context
            commentId
            thread {title}
            user {id name avatar {large}}
            createdAt
          }
          ... on ActivityMentionNotification {
            id
            type
            activityId
            user {id name avatar {large}}
            createdAt
          }
          ... on ThreadCommentMentionNotification {
            id
            type
            commentId
            thread {title}
            user {id name avatar {large}}
            createdAt
          }
          ... on ThreadCommentSubscribedNotification {
            id
            type
            commentId
            thread {title}
            user {id name avatar {large}}
            createdAt
          }
          ... on ActivityLikeNotification {
            id
            type
            activityId
            user {id name avatar {large}}
            createdAt
          }
          ... on ActivityReplyLikeNotification {
            id
            type
            activityId
            user {id name avatar {large}}
            createdAt
          }
          ... on ThreadLikeNotification {
            id
            type
            thread {id title}
            user {id name avatar {large}}
            createdAt
          }
          ... on ThreadCommentLikeNotification {
            id
            type
            commentId
            thread {title}
            user {id name avatar {large}}
            createdAt
          }
          ... on AiringNotification {
            id
            type
            episode
            media {id type bannerImage title {userPreferred} coverImage {large}}
            createdAt
          }
          ... on RelatedMediaAdditionNotification {
            id
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

  int _unreadCount = 0;
  int _filter = 0;
  final _entries = PageModel<NotificationModel>();

  @override
  bool get hasNextPage => _entries.hasNextPage;
  int get unreadCount => _unreadCount;
  int get filter => _filter;
  set filter(int val) {
    if (val < 0 || val > _filters.length) return;
    _filter = val;
    fetch();
    scrollTo(0);
  }

  List<NotificationModel> get entries => _entries.items;

  // ***************************************************************************
  // FETCHING
  // ***************************************************************************

  Future<void> fetch() async {
    final data = await Client.request(
      _notificationQuery,
      _filter != 0 ? {'filter': _filters[_filter]} : null,
      popOnErr: false,
    );
    if (data == null) return;

    _unreadCount = _filter == 0 ? data['Viewer']['unreadNotificationCount'] : 0;

    final nl = <NotificationModel>[];
    for (final n in data['Page']['notifications'])
      try {
        nl.add(NotificationModel(n));
      } catch (_) {}

    _entries.append(nl, data['Page']['pageInfo']['hasNextPage']);
    Get.find<Viewer>().nullifyUnread();
    update();
  }

  @override
  Future<void> fetchPage() async {
    Map<String, dynamic>? data = await Client.request(
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

    final List<NotificationModel> nl = [];
    for (final n in data!['notifications']) nl.add(NotificationModel(n));

    _entries.append(nl, data['pageInfo']['hasNextPage']);
    update();
  }

  @override
  void onInit() {
    super.onInit();
    fetch();
  }
}
