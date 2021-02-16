import 'package:get/get.dart';
import 'package:otraku/controllers/viewer.dart';
import 'package:otraku/models/anilist/notification_model.dart';
import 'package:otraku/models/loadable_list.dart';
import 'package:otraku/helpers/graph_ql.dart';
import 'package:otraku/helpers/scroll_x_controller.dart';

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

  bool _fetching = false;
  int _unreadCount = 0;
  int _filter = 0;
  LoadableList<NotificationModel> _entries;

  int get unreadCount => _unreadCount;

  int get filter => _filter;

  set filter(int val) {
    if (val < 0 || val > _filters.length) return;
    _filter = val;
    fetchData();
    scrollTo(0);
  }

  List<NotificationModel> get entries => _entries?.items;

  // ***************************************************************************
  // FETCHING
  // ***************************************************************************

  Future<void> fetchData() async {
    _fetching = true;
    Map<String, dynamic> data = await GraphQL.request(
      _notificationQuery,
      _filter != 0 ? {'filter': _filters[_filter]} : null,
      popOnErr: false,
    );
    if (data == null) return;

    _unreadCount = _filter == 0 ? data['Viewer']['unreadNotificationCount'] : 0;
    data = data['Page'];

    final List<NotificationModel> nl = [];
    for (final n in data['notifications']) nl.add(NotificationModel(n));

    _entries = LoadableList(nl, data['pageInfo']['hasNextPage']);
    update();
    _fetching = false;
  }

  Future<void> fetchPage() async {
    if (_fetching || !_entries.hasNextPage) return;
    _fetching = true;

    Map<String, dynamic> data = await GraphQL.request(
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
    for (final n in data['notifications']) nl.add(NotificationModel(n));

    _entries.append(nl, data['pageInfo']['hasNextPage']);
    update();
    _fetching = false;
  }

  @override
  void onClose() {
    Get.find<Viewer>().nullifyUnread();
    super.onClose();
  }
}
